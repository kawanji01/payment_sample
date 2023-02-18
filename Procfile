release: bin/rails db:migrate

web: bundle exec puma -C config/puma.rb
web: bin/rails server -p $PORT -e $RAILS_ENV
