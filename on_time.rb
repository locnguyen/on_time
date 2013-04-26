require 'sinatra'
require 'mongoid'
require 'logger'
require './flight'

class OnTime < Sinatra::Base

  configure do
    enable :logging, :dump_errors, :raise_errors

    Log = Logger.new('sinatra.log')
    Log.datetime_format = '%Y-%m-%d %H:%M '
    Log.level = Logger::DEBUG


    Mongoid.logger.level = Logger::DEBUG
    Moped.logger.level = Logger::DEBUG
    Mongoid.load!('mongoid.yml', :development)
  end

  before do
    content_type :json
  end

  get '/' do
    content_type :html
    erb :index
  end

  get '/flights' do
    limit = params['limit'] || 100
    status 200
    flights = Flight.limit(limit)
    flights.to_json
  end
end
