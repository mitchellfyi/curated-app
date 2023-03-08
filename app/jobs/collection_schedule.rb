class CollectionSchedule < Que::Job
  include Que::Unique

  self.priority = 20

  def run
    Collection.find_each do |collection|
      collection.sources.has_new_items.find_each do |source|
        CollectionCreateItemsFromSource.enqueue(collection.id, source.id)
      end
    end
  end
end
