# start puma with: bundle exec puma -C config/puma.rb
environment ENV['RAILS_ENV'] || 'development'
# daemonize

workers    2 # should be same number of your CPU core
threads    0, 3
port 3000

# pidfile    "/var/run/puma_app1.pid"