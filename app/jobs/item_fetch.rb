class ItemFetch < Que::Job
  include Que::Unique

  self.priority = 10

  def run(id)
    Item.find(id).fetch!
  end
end
