require 'rubygems'
require 'bundler/setup'
require 'rack/contrib'
require './on_time'

Bundler.require

ENV['MEMCACHE_SERVERS'] = 'localhost'
if memcache_servers = ENV['MEMCACHE_SERVERS']
  use Rack::Cache,
      verbose: true,
      metastore: "memcached://#{memcache_servers}",
      entitystore: "memcached://#{memcache_servers}"
end

run OnTime
