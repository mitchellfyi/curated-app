class AccountItemsFromSource < Que::Job
  include Que::Unique

  self.priority = 10

  def run(id, source_id)
    source = Source.find(source_id)
    Account.find(id).items_from_source(source)
  end
end
