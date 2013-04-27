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
  end
end
