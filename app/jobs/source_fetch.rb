class SourceFetch < Que::Job
  include Que::Unique

  self.priority = 10

  def run
    Source.where(fetched_at: ...1.hour.ago).find_each do |source|
      SourceItemsFetch.enqueue(source.id)
    end
  end
end