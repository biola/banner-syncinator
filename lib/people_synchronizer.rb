class PeopleSynchronizer
  attr_reader :affiliation

  def initialize(affiliation)
    @affiliation = Affiliation.find(affiliation)
  end

  def sync!
    Log.info "Begin sync of #{affiliation.to_s.pluralize}"

    # These will be nil if they could not connect for whatever reason.
    # Otherwise they will be a PersonCollection of Trogdir::Person or Banner::Person
    banner_people = affiliation.banner_person.collection
    trogdir_people = affiliation.trogdir_person.collection

    if banner_people.nil?
      Log.error "Could not finish sync. There was a problem connecting to Banner."
    elsif trogdir_people.nil?
      Log.error "Could not finish sync. There was a problem connecting to TrogdirAPI."
    else

      # Returns an array of PersonChanges for each person that was added, updated, or removed.
      comparer = PersonCollectionComparer.new(trogdir_people, banner_people, affiliation)

      comparer.changed.each do |person_change|
        PersonSynchronizer.new(person_change, affiliation).call
      end

      count = comparer.changed.count
      Log.info "Finished syncing #{count} #{affiliation.to_s.pluralize(count)}"

    end
  end

end
