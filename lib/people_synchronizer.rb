class PeopleSynchronizer
  attr_reader :affiliation

  def initialize(affiliation)
    @affiliation = Affiliation.find(affiliation)
  end

  def sync!
    Log.info "Begin sync of #{affiliation.to_s.pluralize}"

    comparer.changed.each do |person_change|
      PersonSynchronizer.new(person_change, affiliation).call
    end

    count = comparer.changed.count
    Log.info "Finished syncing #{count} #{affiliation.to_s.pluralize(count)}"
  end

  private

  def trogdir_people
    @trogdir_people ||= affiliation.trogdir_person.collection
  end

  def banner_people
    @banner_people ||= affiliation.banner_person.collection
  end

  def comparer
    # Returns an array of PersonChanges for each person that was added, updated, or removed.
    @comparer ||= PersonCollectionComparer.new(trogdir_people, banner_people, affiliation)
  end
end
