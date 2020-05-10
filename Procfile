web: bundle exec puma -p ${PORT:-3000} -e ${RACK_ENV:-development}
worker: bundle exec sidekiq -t 25 -c 1 -q default -q mailers
