class AccountSchedule < Que::Job
  include Que::Unique

  self.priority = 20

  def run
    Account.ready_for_items.find_each do |account|
      account.sources.has_new_items.find_each do |source|
        AccountItemsFromSource.enqueue(account.id, source.id)
      end
    end
  end
end
