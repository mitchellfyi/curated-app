class SourceItemsFetch < Que::Job
  include Que::Unique

  self.priority = 20

  def run(source_id)
    Source.find(source_id).fetch_items!
  end
end