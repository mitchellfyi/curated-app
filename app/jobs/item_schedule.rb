class ItemSchedule < Que::Job
  include Que::Unique

  self.priority = 20

  def run
    Item.ready_to_fetch.find_each do |item|
      ItemFetch.enqueue(item.id)
    end
  end
end
