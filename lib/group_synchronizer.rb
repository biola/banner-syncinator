class GroupSynchronizer
  attr_reader :group, :sql

  # The only column returned in the SQL should be a PIDM
  def initialize(group, sql)
    @group = group
    @sql = sql
  end

  def call
    Log.info "Begin sync of #{group} group"

    trogdir_people = get_trogdir_people_by_group
    banner_people = get_banner_people_by_group

    if banner_people.nil? # this doesn't work yet, I don't know what banner returns on fail
      Log.error "Could not finish #{group} group sync. There was a problem connecting to Banner."
    elsif trogdir_people.nil?
      Log.error "Could not finish #{group} group sync. There was a problem connecting to TrogdirAPI."
    else

      (banner_people - trogdir_people).each do |person|
        update :add, person
      end

      (trogdir_people - banner_people).each do |person|
        update :remove, person
      end

      Log.info "Finished syncing of #{group} group"

    end
  end

  private

  def get_banner_people_by_group
    [].tap do |people|
      Banner::DB.exec(sql) do |row|
        col ||= row.keys.first
        people << Banner::Person.new(PIDM: row[col])
      end
    end
  end

  def get_trogdir_people_by_group
    # Weary::Request
    request = Trogdir::APIClient::Groups.new.send(:people, group: group)
    # Weary::Response
    response = request.perform

    if response.success?
      person_hashes = JSON.parse(response.body, symbolize_names: true)
      person_hashes.map { |h| Trogdir::Person.new(h) }
    else
      Log.error "There was a problem connecting to TrogdirAPI in #{__FILE__}#get_trogdir_people_by_group METHOD=#{request.method} URI=#{request.uri} STATUS=#{response.status} BODY=#{response.body}"
      nil
    end
  end

  def update(method, person)
    # Weary::Request
    request = Trogdir::APIClient::Groups.new.send(method, group: group, identifier: person.banner_id.to_s, type: 'banner')
    # Weary::Response
    response = request.perform
    response_body = JSON.parse(response.body, symbolize_names: true)

    message = "#{method.to_s.titleize} user with PIDM #{person.banner_id} to #{group} group"

    if response.success? && response_body[:result] == true
      Log.info message
    else
      Log.error "Unable to #{message} in #{__FILE__}#update METHOD=#{request.method} URI=#{request.uri} STATUS=#{response.status} BODY=#{response.body}"
    end
  end
end
