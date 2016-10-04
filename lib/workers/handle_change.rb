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
        skip("No pidm found for  #{change.person_uuid}")
        return
      end

      perform_change
    end

    private

    attr_reader :pidm, :person, :change

    def perform_change
      self.send(change.event || :skip)
    end

    def netid_creation
      with_logging(action: :create) do
        create_and_update_gobtpac_record
        "Writing NetID for person #{change.person_uuid}"
      end
    end
    alias_method :netid_update, :netid_creation

    def employee_termination
      with_logging(action: :update) do
        deactivate_office_phones
        "Updating Office Phone for person #{change.person_uuid}"
      end
    end

    def email_creation
      with_logging(action: :create) do
        create_or_update_email_address
        "Writing UNIV email address in Banner for person #{change.person_uuid}"
      end
    end
    alias_method :email_update, :email_creation

    def email_destroy
      with_logging(action: :destroy) do
        delete_univ_email
        "Deleting UNIV email address in Banner for person #{change.person_uuid}"
      end
    end

    def skip(message = nil)
      with_logging(action: :skip) do
        message || "No changes needed for person #{change.person_uuid}"
      end
    end

    def create_or_update_email_address
      if univ_email_exists?
        update_goremal_record
      else
        create_goremal_record
      end
    end

    def delete_univ_email
      with_banner_connection do |conn|
        conn.exec "DELETE FROM GOREMAL
                   WHERE GOREMAL_EMAL_CODE = 'UNIV'
                   AND GOREMAL_PIDM = :1",
                   pidm
        conn.commit
      end
    end

    def deactivate_univ_email
      with_banner_connection do |conn|
        conn.exec "UPDATE GOREMAL
                   SET GOREMAL_ACTIVITY_DATE = SYSDATE, GOREMAL_STATUS_IND = 'I',
                   GOREMAL_PREFERRED_IND = 'N', GOREMAL_DATA_ORIGIN = 'Trogdir',
                   GOREMAL_USER_ID = 'APPSJOB'
                   WHERE GOREMAL_EMAL_CODE = 'UNIV'
                   AND GOREMAL_PIDM = :1",
                   pidm
        conn.commit
      end
    end

    def univ_email_exists?
      retval = false
      with_banner_connection do |conn|
        sql = "SELECT 'Y' FROM goremal WHERE goremal_pidm = :pidm
               AND goremal_emal_code = 'UNIV'"
        cursor = conn.exec(sql, pidm)
        retval = true if Array(cursor.fetch).first == 'Y'
      end
      retval
    end

    def create_goremal_record
      with_banner_connection do |conn|
        sql = "INSERT INTO GOREMAL
               (GOREMAL_PIDM, GOREMAL_EMAL_CODE, GOREMAL_EMAIL_ADDRESS,
               GOREMAL_STATUS_IND, GOREMAL_PREFERRED_IND, GOREMAL_ACTIVITY_DATE,
               GOREMAL_USER_ID, GOREMAL_DISP_WEB_IND, GOREMAL_DATA_ORIGIN)
               VALUES (:1, 'UNIV', :2, 'A', 'Y', sysdate, 'APPSJOB', 'Y', 'Trogdir')"
        conn.exec(sql, pidm, change.email_address)
        conn.commit
      end

      unprefer_non_univ_emails
    end

    def unprefer_non_univ_emails
      with_banner_connection do |conn|
        # unset preferred for non-UNIV email addresses
        conn.exec "UPDATE GOREMAL
                   SET GOREMAL_ACTIVITY_DATE = SYSDATE, GOREMAL_PREFERRED_IND = 'N'
                   WHERE GOREMAL_EMAL_CODE != 'UNIV'
                   AND GOREMAL_PIDM = :1",
                   pidm
        conn.commit
      end
    end

    def update_goremal_record
      with_banner_connection do |conn|
        conn.exec "UPDATE GOREMAL
                   SET GOREMAL_EMAIL_ADDRESS = :1, GOREMAL_ACTIVITY_DATE = SYSDATE,
                   GOREMAL_PREFERRED_IND = 'Y', GOREMAL_STATUS_IND = 'A',
                   GOREMAL_DATA_ORIGIN = 'Trogdir', GOREMAL_USER_ID = 'APPSJOB'
                   WHERE GOREMAL_EMAL_CODE = 'UNIV'
                   AND GOREMAL_PIDM = :2",
                   change.email_address, pidm
        conn.commit
      end

      unprefer_non_univ_emails
    end

    def deactivate_office_phones
      with_banner_connection do |conn|
        conn.exec "UPDATE BGV_PHONES
                   SET ACTIVITY_DATE = SYSDATE, STATUS_IND = 'I',
                   USER_ID = 'APPSJOB', DATA_ORIGIN = 'Trogdir'
                   WHERE TELE_CODE in ('OCM','OCE')
                   AND PIDM = :1",
                   pidm
        conn.commit
      end
    end

    def create_and_update_gobtpac_record
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
                    SET GOBTPAC_EXTERNAL_USER = :1, GOBTPAC_ACTIVITY_DATE = SYSDATE,
                    GOBTPAC_USER = 'APPSJOB', GOBTPAC_DATA_ORIGIN = 'Trogdir'
                    WHERE GOBTPAC_PIDM = :2",
                    change.netid, pidm

        conn.exec  "INSERT INTO GORPAUD (GORPAUD_PIDM, GORPAUD_ACTIVITY_DATE, GORPAUD_USER,
                    GORPAUD_EXTERNAL_USER, GORPAUD_CHG_IND)
                    VALUES (:1, SYSDATE, :2, :3, 'I')",
                    pidm, conn.username, change.netid

        # The inserted row is invisible from other connections unless the transaction is committed.
        #
        conn.commit
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
      error_message = e.backtrace[0..4].unshift(e.message).join(',')
      Workers::ChangeError.perform_async(change.sync_log_id, error_message)
      Raven.capture_exception(e) if defined? Raven
      raise e
    end
  end
end
