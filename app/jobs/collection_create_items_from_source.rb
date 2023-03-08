class CollectionCreateItemsFromSource < Que::Job
  include Que::Unique

  self.priority = 10

  def run(id, source_id)
    source = Source.find(source_id)
    Collection.find(id).create_items_from_source!(source)
  end
end
