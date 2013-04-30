require 'rubygems'
require 'bundler/setup'

Bundler.require

ENV['MEMCACHE_SERVERS'] = 'localhost'
if memcache_servers = ENV['MEMCACHE_SERVERS']
  use Rack::Cache,
      verbose: true,
      metastore: "memcached://#{memcache_servers}",
      entitystore: "memcached://#{memcache_servers}"
end

require './on_time'

run OnTime
