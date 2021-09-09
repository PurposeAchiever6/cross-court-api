release: rake db:migrate
web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -c 5 -v -q default,2 -q mailers
