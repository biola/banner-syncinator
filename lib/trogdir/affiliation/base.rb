module Trogdir
  module Affiliation
    class Base
      FIELD_MAPPINGS = Trogdir::Person::FIELD_MAPPINGS

      def self.collection
        affiliation = self.to_s.demodulize.underscore

        person_hashes = Trogdir::API.call :index, affiliation: affiliation
        people = person_hashes.map { |h| Person.import(h) }

        Trogdir::PersonCollection.new people
      end
    end
  end
end