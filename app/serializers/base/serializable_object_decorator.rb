class SerializableObjectDecorator < SimpleDelegator

  def initialize(resource, unique_hash)
    @unique_hash = unique_hash
    super(resource)
  end

  def self.wrap(collection, unique_hash)
    collection.map { |obj| new(obj, unique_hash) }
  end

end