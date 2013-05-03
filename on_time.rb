require 'sinatra'
require 'sinatra/config_file'
require 'mongoid'
require 'logger'
require 'dalli'
require 'rack-cache'
require './flight'
require './airline'
require './routes'

class OnTime < Sinatra::Base
  register Sinatra::ConfigFile
  include Airline
  extend Routes

  configure do
    enable :logging, :dump_errors, :raise_errors

    config_file 'settings.yml'

    Log = Logger.new('sinatra.log')
    Log.datetime_format = '%Y-%m-%d %H:%M '
    Log.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime} : #{severity} : #{msg}\n"
    end
    Log.level = Logger::DEBUG

    Mongoid.logger.level = Logger::DEBUG
    Moped.logger.level = Logger::DEBUG
    Mongoid.load!('mongoid.yml', :development)

    set :cache, Dalli::Client.new
    cache.flush
  end

  helpers do
    def api
      OnTime.ROUTES
    end
  end

  before do
    cache_control :public, max_age: settings.browser_cache_expires
    content_type :json
  end

  get '/' do
    Log.debug 'Loading index view'
    cache_control :public, max_age: 15
    content_type :html
    erb :index
  end

  get Routes::ROOT do
    OnTime.ROUTES.to_json
  end

  get Routes::AIRLINES do
    request_url = request.url
    cache = settings.cache.get(request_url)
    cache unless cache.nil?
    Log.debug "Storing Airlines in cache @ #{request_url}"
    json = Airline::CODE.to_json
    settings.cache.set(request_url, json, ttl = settings.memcache_expires)
    json
  end

  get Routes::FLIGHTS do
    limit = params['limit'] || 100
    flights = Flight.limit(limit)
    Log.debug flights.to_json
    status 200
    flights.to_json
  end

  get Routes::DELAYS do
    request_url = request.url
    Log.debug request_url
    cached_result = settings.cache.get(request_url)

    return cached_result unless cached_result.nil?

    Log.debug "Storing query in cache @ #{request_url}"

    airline_codes = params['airlines']
    dest_codes = params['destinations']
    origin_codes = params['origins']

    pipeline = []

    if airline_codes
      pipeline << { "$match" => { "Carrier" => { "$in" => airline_codes.split(',') } }}
    end

    if dest_codes
      pipeline << { "$match" => { "Dest" => { "$in" => dest_codes.split(',') } }}
    end

    if origin_codes
      pipeline << { "$match" => { "Origin" => { "$in" => origin_codes.split(',') } }}
    end

    pipeline << { "$group" => { "_id" => "$Carrier", "avg_delay" => { "$avg" => "$ArrDelayMinutes"}}}

    results = Flight.collection.aggregate(pipeline)
    json = results.to_json
    settings.cache.set(request_url, json, ttl = settings.memcache_expires)

    Log.debug json
    json
  end
end
