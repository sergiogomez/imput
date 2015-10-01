run_sidekiq_in_this_thread = %w(development staging production).include?(ENV['RAILS_ENV'])

if ENV["RAILS_ENV"] == "development"
  worker_processes 1
else
  worker_processes Integer(ENV["WEB_CONCURRENCY"] || (run_sidekiq_in_this_thread ? 1 : 2))
end
timeout 15
preload_app true

@sidekiq_pid = nil

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  if run_sidekiq_in_this_thread
    @resque_pid ||= spawn("bundle exec sidekiq -q mailer -q default")
    Rails.logger.info("Spawned sidekiq #{@request_pid}")
  end

end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end