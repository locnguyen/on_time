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
  end

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
    results = Flight.collection.aggregate({ "$group" => { "_id" => "$Carrier", "avgDelay" => { "$avg" => "$ArrDelayMinutes"}}})
    Log.debug results.to_json
    results.to_json
  end
end
