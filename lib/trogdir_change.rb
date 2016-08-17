class TrogdirChange
  attr_reader :hash

  def initialize(hash)
    @hash = hash
  end

  def sync_log_id
    hash['sync_log_id']
  end

  def person_uuid
    hash['person_id']
  end

  def netid
    modified['identifier']
  end

  def event
    return :netid_creation if netid_creation?
    return :netid_update if netid_update?
    return :employee_termination if employee_termination?
  end

  private

  def netid_creation?
    id? && create? && modified['type'] == 'netid'
  end

  def netid_update?
    id? && update? && modified['type'] == 'netid'
  end

  def employee_termination?
    removed = Array(original['affiliations']) - Array(modified['affiliations'])
    removed.include? "employee"
  end

  def id?
    hash['scope'] == 'id'
  end

  def affiliation_change?
    modified.key? 'affiliations'
  end

  def create?
    hash['action'] == 'create'
  end

  def update?
    hash['action'] == 'update'
  end

  def modified
    hash['modified']
  end

  def original
    hash['original']
  end
end
