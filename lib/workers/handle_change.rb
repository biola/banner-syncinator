module Workers
  class HandleChange
    class TrogdirAPIError < StandardError; end
    class BannerError < StandardError; end
    include Sidekiq::Worker

    sidekiq_options retry: false

    def perform(change_hash)
      change = TrogdirChange.new(change_hash)
      action = :skip

      begin
        if change.netid_creation? || change.netid_update?
          person = Trogdir::APIClient::People.new.show(uuid: change.person_uuid).perform.parse
          pidm = person['ids'].find { |id| id['type'] == 'banner' }.try(:[], 'identifier').try(:to_i)

          if pidm.present?
            conn = Banner::DB.connection
            cursor = conn.parse 'BEGIN :return_value := BANINST1.BGF_INSERT_GOBTPAC(:pidm); END;'
            cursor.bind_param(':pidm', pidm, Integer)
            cursor.bind_param(':return_value', nil, String)
            cursor.exec

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

            cursor.close
            conn.logoff

            Log.info "Writing NetID for person #{change.person_uuid}"
            action = :create
          else
            Log.info "No pidm found for  #{change.person_uuid}"
            Workers::ChangeFinish.perform_async change.sync_log_id, action
          end
        end

        Log.info "No changes needed for person #{change.person_uuid}" if action == :skip
        Workers::ChangeFinish.perform_async change.sync_log_id, action
      rescue StandardError => err
        Workers::ChangeError.perform_async change.sync_log_id, err.message
        Raven.capture_exception(err) if defined? Raven
        raise err
      end
    end
  end
end
