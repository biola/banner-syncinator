module Workers
  class HandleChange
    class TrogdirAPIError < StandardError; end
    class BannerError < StandardError; end
    include Sidekiq::Worker

    sidekiq_options retry: false

    def perform(change_hash)
      @change = TrogdirChange.new(change_hash)
      @person = Trogdir::APIClient::People.new.show(uuid: change.person_uuid).perform.parse
      @pidm = person['ids'].find { |id| id['type'] == 'banner' }.try(:[], 'identifier').try(:to_i)

      unless pidm.present?
        with_logging(action: :skip) do
          message = "No pidm found for  #{change.person_uuid}"
        end
        return
      end

      perform_change(change)
    end

    private

    attr_reader :pidm, :person, :change

    def perform_change(change)
      case change.event
      when :netid_creation, :netid_update
        with_logging(action: :create) do
          create_gobtpac_record
          message = "Writing NetID for person #{change.person_uuid}"
        end
      when :employee_termination
        with_logging(action: :update) do
          remove_office_phones
          message = "Updating Office Phone for person #{change.person_uuid}"
        end
      else
        with_logging(action: :skip) do
          message = "No changes needed for person #{change.person_uuid}"
        end
      end
    end

    def remove_office_phones
      with_banner_connection do |conn|
        conn.exec "UPDATE BGV_PHONES
                   SET ACTIVITY_DATE = SYSDATE, STATUS_IND = 'I'
                   WHERE TELE_CODE in ('OCM','OCE')
                   AND PIDM = :1",
                   pidm
        conn.commit
      end
    end

    def create_gobtpac_record
      with_banner_connection do |conn|
        sql = 'BEGIN :return_value := BANINST1.BGF_INSERT_GOBTPAC(:pidm); END;'

        using_cursor(statement: sql, connection: conn) do |cursor|
          cursor.bind_param(':pidm', pidm, Integer)
          cursor.bind_param(':return_value', nil, String)
          cursor.exec

          update_gobtpac_netid(conn, cursor)
        end
      end
    end

    def update_gobtpac_netid(conn, cursor)
      if ['CREATED', 'EXISTS'].include? cursor[':return_value']
        conn.exec  "UPDATE GOBTPAC
                    SET GOBTPAC_EXTERNAL_USER = :1, GOBTPAC_ACTIVITY_DATE = SYSDATE
                    WHERE GOBTPAC_PIDM = :2",
                    change.netid, pidm

        conn.exec  "INSERT INTO GORPAUD (GORPAUD_PIDM, GORPAUD_ACTIVITY_DATE, GORPAUD_USER, GORPAUD_EXTERNAL_USER, GORPAUD_CHG_IND)
                    VALUES (:1, SYSDATE, :2, :3, 'I')",
                    pidm, conn.username, change.netid
        conn.commit # The inserted row is invisible from other connections unless the transaction is committed.
      else
        raise BannerError, "Query failed: #{cursor[':return_value']}"
      end
    end

    def with_banner_connection(&block)
      conn = Banner::DB.connection
      block.call(conn)
      conn.logoff
    end

    def using_cursor(statement:, connection:, &block)
      cursor = connection.parse(statement)
      block.call(cursor)
      cursor.close
    end

    def with_logging(action:, &block)
      message = block.call
      Log.info message
      Workers::ChangeFinish.perform_async(change.sync_log_id, action)
    rescue StandardError => e
      Workers::ChangeError.perform_async(change.sync_log_id, e.message)
      Raven.capture_exception(e) if defined? Raven
      raise err
    end
  end
end
