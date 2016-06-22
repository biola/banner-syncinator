class Person
  # Attributes that are common to all types of people
  ATTRS = [
    :banner_id, :biola_id, :banner_udcid,
    :last_name, :first_name, :middle_name, :preferred_name,
    :gender, :privacy,
    :street_1, :street_2, :city, :state, :zip
  ]

  ATTRS.each do |attr|
    define_method(attr) do
      raise NotImplementedError, "##{attr} should be overridden in sub classes"
    end
  end

  def initialize(raw_attributes)
    @raw_attributes = raw_attributes
  end

  def attributes
    self.class::ATTRS.each_with_object({}) { |att, hash| hash[att] = send(att) }
  end

  # I'm preferring is? over eql? because I feel it better represents what we're checking.
  # Which is that they have the same banner_id not that they are the same object or even
  # have the same attributes. But we're also using it for eql? for simple array comparisons.
  def is?(other)
    return false unless other.respond_to? :banner_id

    other.banner_id.to_i == banner_id.to_i
  end
  alias :eql? :is?

  def hash
    banner_id.to_i.hash
  end

  def ==(other)
    return false unless other.is_a? Person

    # attributes that are common between the two
    attrs = self.class::ATTRS & other.class::ATTRS

    attrs.all? { |att| other.send(att) == send(att) }
  end

  def to_s
    "#{first_name} #{last_name}"
  end

  def self.collection
    raise NotImplementedError, '.collection should be overridden in sub classes'
  end

  def self.affiliation
    class_name = self.to_s.demodulize

    if class_name == 'Person'
      raise NotImplementedError, '.affiliation should be overridden in sub classes'
    end

    slug = class_name.underscore
    name = slug.humanize.downcase

    Affiliation.new(slug, name)
  end

  protected

  attr_reader :raw_attributes

  def self.default_readers(attribute_mappings)
    attribute_mappings.each do |common_attr, raw_attr|
      define_method(common_attr) do
        raw_attributes[raw_attr]
      end
    end
  end
end
