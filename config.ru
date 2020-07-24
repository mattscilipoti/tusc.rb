# tus server for testing
# start via $ `rackup`
# see: https://github.com/janko/tus-ruby-server
require 'tus/server'

map '/files' do
  run Tus::Server
end
