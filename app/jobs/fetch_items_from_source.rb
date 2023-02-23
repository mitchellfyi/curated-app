class FetchItemsFromSource < Que::Job
  include Que::Unique

  self.priority = 20

  def run(source_id)
    Source.find(source_id).fetch!
  end
end