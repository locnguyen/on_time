require 'sinatra'
require 'mongoid'
require 'logger'
require './flight'

class OnTime < Sinatra::Base

  configure do
    enable :logging, :dump_errors, :raise_errors

    Log = Logger.new('sinatra.log')
    Log.datetime_format = '%Y-%m-%d %H:%M '
    Log.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime}: #{msg}\n"
    end
    Log.level = Logger::DEBUG

    Mongoid.logger.level = Logger::DEBUG
    Moped.logger.level = Logger::DEBUG
    Mongoid.load!('mongoid.yml', :development)
  end

  before do
    content_type :json
    @api = API
  end

  API = {
    root: '/',
    flights: '/flights',
    delays: '/delays'
  }

  get '/' do
    Log.debug 'Loading index view'
    content_type :html
    erb :index
  end

  get '/flights' do
    limit = params['limit'] || 100
    flights = Flight.limit(limit)
    Log.debug flights.to_json
    status 200
    flights.to_json
  end


  get '/delays' do
    # db.flights.aggregate({ $group: { _id: "$Carrier", avgDelay: { $avg : "$ArrDelayMinutes" }}})

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
    Log.debug results.to_json
    results.to_json

    ## - for faster dev - replace with memcached?
    #results = %Q{
    #  [{"_id":"YV","avg_delay":7.251684076930586},{"_id":"VX","avg_delay":12.363816659321287},{"_id":"UA","avg_delay":8.415542946970255},{"_id":"HA","avg_delay":4.774862109309711},{"_id":"FL","avg_delay":5.136833582461385},{"_id":"DL","avg_delay":5.5645155888952145},{"_id":"F9","avg_delay":9.216181643748001},{"_id":"EV","avg_delay":9.715029824414014},{"_id":"US","avg_delay":5.531366106795222},{"_id":"B6","avg_delay":10.755254200659138},{"_id":"OO","avg_delay":9.872369047372668},{"_id":"MQ","avg_delay":8.574229313142238},{"_id":"AS","avg_delay":7.1158835151619275},{"_id":"WN","avg_delay":7.895442778075344},{"_id":"AA","avg_delay":10.90068839358783}]
    #}
    #results
  end
end
