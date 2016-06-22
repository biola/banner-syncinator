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

    def self.collection
      # Weary::Request
      request = Trogdir::APIClient::People.new.send(:index, affiliation: affiliation.name)
      # Weary::Response
      response = request.perform

      if response.success?
        person_hashes = JSON.parse(response.body, symbolize_names: true)
        people = person_hashes.map { |h| new(h) }
        PersonCollection.new people
      else
        Log.error "There was a problem connecting to TrogdirAPI in #{__FILE__}#self.collection METHOD=#{request.method} URI=#{request.uri} STATUS=#{response.status} BODY=#{response.body}"
        nil
      end
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
  end
end
