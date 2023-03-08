return if Rails.env.production?

if Rails.env.staging?
  confirm_token = 'reset'

  $stdout.puts "Confirm data reset by entering '#{confirm_token}' to confirm (hit enter to keep existing data):"

  input = $stdin.gets.chomp

  pp 'Skipping data reset.' and return unless input == confirm_token
end

# Que.clear!

pp %i[db reset]
Rake::Task['db:migrate:reset'].invoke
