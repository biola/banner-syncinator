module Trogdir
  class Person < ::Person
    ATTRS = superclass::ATTRS + [
      :uuid, :affiliations,

      # Things everyone has in Trogdir but not Banner
      :partial_ssn, :birth_date, :country, :personal_email,

      # IDs needed to do updates and destroys against the Trogdir API
      :banner_id_id, :biola_id_id, :banner_udcid_id, :address_id, :personal_email_id
    ]

    default_readers({
      uuid:                 :uuid,
      last_name:            :last_name,
      first_name:           :first_name,
      middle_name:          :middle_name,
      preferred_name:       :preferred_name,
      partial_ssn:          :partial_ssn,
      affiliations:         :affiliations
    })

    def banner_id
      find(:ids, :banner)[:identifier].try :to_i
    end

    def biola_id
      find(:ids, :biola_id)[:identifier].try :to_i
    end

    def banner_udcid
      find(:ids, :banner_udcid)[:identifier]
    end

    def gender
      raw_attributes[:gender].to_sym if raw_attributes[:gender]
    end

    def birth_date
      dob = raw_attributes[:birth_date]
      Date.strptime(dob, '%Y-%m-%d') unless dob.blank?
    end

    def privacy
      raw_attributes[:privacy] == true
    end

    [:street_1, :street_2, :city, :state, :zip, :country].each do |att|
      define_method(att) do
        home_address[att]
      end
    end

    def personal_email
      find(:emails, :personal)[:address]
    end

    def banner_id_id
      find(:ids, :banner)[:id]
    end

    def biola_id_id
      find(:ids, :biola_id)[:id]
    end

    def banner_udcid_id
      find(:ids, :banner_udcid)[:id]
    end

    def address_id
      home_address[:id]
    end

    def personal_email_id
      find(:emails, :personal)[:id]
    end

    def self.find(biola_id)
      # Weary::Request
      request = Trogdir::APIClient::People.new.send(:by_id, id: biola_id, type: :biola_id)
      # Weary::Response
      response = request.perform

      if response.success?
        new(JSON.parse(response.body, symbolize_names: true))
      elsif response.status == 404
        NullPerson.new(self)
      else
        Log.error "There was a problem connecting to TrogdirAPI in #{__FILE__}#self.find METHOD=#{request.method} URI=#{request.uri} STATUS=#{response.status} BODY=#{response.body}"
        nil
      end
    end

    #
    # Returns a collection of all people matching the given affiliation
    # from Trogdir.
    #
    # @return [PersonCollection,nil]
    #   Will return nil if there was a problem connecting to TrogdirAPI
    #
    def self.collection
      people = batch_request_people
      PersonCollection.new(people) if people
    end

    private

    def find(things, type)
      Array(raw_attributes[things]).find do |thing|
        thing[:type] == type.to_s
      end || {}
    end

    def home_address
      @home_address ||= find(:addresses, :home)
    end

    #
    # Request paginated list of people. When we weren't paginating the
    # request would take too long and time out. This method handles
    # making multiple paginated requests and returns a complete array of
    # all the people for the given affiliation.
    #
    # @return [Array<Person>,nil]
    #   Will return nil if one of the API requests was not successful.
    #
    def self.batch_request_people
      all_people = []
      page = 1
      per_page = 1000

      loop do
        # Weary::Request
        request =
          Trogdir::APIClient::People.new.send(
            :index,
            affiliation: affiliation.name,
            page: page,
            per_page: per_page
          )
        # Weary::Response
        response = request.perform

        if response.success?
          Log.debug "Success loading people from TrogdirAPI AFFILIATION:#{affiliation.name} PAGE:#{page}"
          person_hashes = JSON.parse(response.body, symbolize_names: true)
          people = person_hashes.map { |h| new(h) }
          all_people += people
          page += 1

          # Keep looping until no more people are returned. Meaning we
          # reached the last page +1.
          return all_people if people.empty?
        else
          Log.error "There was a problem connecting to TrogdirAPI in #{__FILE__}#self.collection METHOD=#{request.method} URI=#{request.uri} STATUS=#{response.status} BODY=#{response.body}"
          return nil
        end
      end
    end
  end
end
