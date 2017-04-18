class TrogdirChange
  attr_reader :hash

  EVENTS = :netid_creation, :netid_update, :employee_termination, :email_creation, :email_update, :email_destroy

  def initialize(hash)
    @hash = hash
  end

  def sync_log_id
    hash['sync_log_id']
  end

  def person_uuid
    hash['person_id']
  end

  def email_address
    modified['address']
  end

  def original_email_address
    original['address']
  end

  def netid
    modified['identifier']
  end

  def event
    EVENTS.each do |e|
      return e if self.send("#{e}?".to_sym)
    end
    nil
  end

  private

  def netid_creation?
    scope == 'id'  && action == 'create'  && modified_type  == 'netid'
  end

  def netid_update?
    scope == 'id' && action == 'update' && modified_type  == 'netid'
  end

  def employee_termination?
    removed = Array(original['affiliations']) - Array(modified['affiliations'])
    removed.include? "employee"
  end

  def email_creation?
    scope == 'email' && action == 'create' &&
    modified_type  == 'university' && !modified['address'].to_s.empty?
  end

  def email_update?
    scope == 'email' && action == 'update' &&
    modified_type  == 'university'  && !modified['address'].to_s.empty?
  end

  def email_destroy?
    scope == 'email' && action == 'destroy' && original_type == 'university'
  end

  def scope
    hash['scope']
  end

  def action
    hash['action']
  end

  def affiliation_change?
    modified.key? 'affiliations'
  end

  def modified
    hash['modified']
  end

  def modified_type
    modified['type']
  end

  def original_type
    original['type']
  end

  def original
    hash['original']
  end
end
