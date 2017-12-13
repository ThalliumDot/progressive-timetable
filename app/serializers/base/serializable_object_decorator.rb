class SerializableObjectDecorator < SimpleDelegator

  def initialize(resource, unique_hash)
    @unique_hash = unique_hash
    super(resource)
  end

  def replace_with_hash(hash)
    __setobj__ hash
  end

  def self.wrap(collection, unique_hash)
    collection.map { |obj| new(obj, unique_hash) }
  end

  def self.all
    ObjectSpace.each_object(self).to_a
  end

  def self.each_of(unique_hash)
    all.map do |sod|
      if sod.instance_variable_get(:@unique_hash) == unique_hash
        yield(sod)
      end
    end
  end

end