class PersonCollectionComparer
  attr_reader :old_collection, :new_collection, :affiliation

  def initialize(old_collection, new_collection, affiliation)
    @old_collection = old_collection  # array of Trogdir people
    @new_collection = new_collection  # array of Banner people
    @affiliation = affiliation
  end

  def added
    @added ||= (new_collection - old_collection).map { |new_person|
      # Returns nil if there was an error from TrogdirAPI
      # Returns NullPerson if there was a 404 response from TrogdirAPI
      # Returns actual person record if a person was fround in Trogdir
      #   this record will be one of the affiliation subclasses of Trogdir::Person
      old_person = affiliation.trogdir_person.find(new_person.biola_id)

      # NullPerson.present? evaluates to false, so we need to explicitly check for nil here
      # since we want to create a PersonChange for NullPerson
      if old_person.nil?
        Log.error "Skipping person with ID=#{new_person.biola_id} in #{__FILE__}#add"
        nil
      else
        PersonChange.new(old_person, new_person)
      end
    }.compact # remove nils
  end

  def updated
    @updated ||= new_collection.people.map { |new_person|
      # Get the Trogdir::Person that matches the banner_id of new_person
      old_person = old_collection[new_person]

      if old_person && old_person != new_person
        PersonChange.new(old_person, new_person)
      end
    }.compact # remove nils
  end

  def removed
    @removed ||= (old_collection - new_collection).map { |person|
      PersonChange.new(person, NullPerson.new(person))
    }.compact # remove nils
  end

  def changed
    @changed ||= added + updated + removed
  end
end
