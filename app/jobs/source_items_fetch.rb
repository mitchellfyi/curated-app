class SourceItemsFetch < Que::Job
  include Que::Unique

  self.priority = 10

  def run(id)
    Source.find(id).fetch_items!
  end
end