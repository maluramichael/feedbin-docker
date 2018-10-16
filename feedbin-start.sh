sleep 10
if psql -h postgres -U feedbin -lqt | cut -d \| -f 1 | grep -qw feedbin_production; then
  echo "Not running db:setup"
else
  echo "Running db:setup"
  bundle exec rake db:setup
fi

bundle exec foreman start &
rackup -o 0.0.0.0