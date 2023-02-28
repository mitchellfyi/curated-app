class SourceSchedule < Que::Job
  include Que::Unique

  self.priority = 20

  def run
    Source.ready_to_fetch.find_each do |source|
      SourceItemsFetch.enqueue(source.id)
    end
  end
end
