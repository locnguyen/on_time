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
    flights = Flight.limit(limit)
    status 200
    flights.to_json
  end

  get '/delays' do
    # db.flights.aggregate({ $group: { _id: "$Carrier", avgDelay: { $avg : "$ArrDelayMinutes" }}})

    map = %Q{
      function() {
        var flight = this;
        var value = { delay: flight.ArrDelayMinutes };
        emit(this.Carrier, value);
      }
    }

    reduce = %Q{
      function(key, values) {
        var i = 0, len = values.length, total = 0;

        for (i=0; i<len; i++) {
            var value = values[i];
        if (isNaN(value.delay)) {
            continue;
        }
        total += parseInt(value.delay);
        }
        return { totalDelayMinutes: total, count: values.length };
      }
    }

    finalize = %Q{
      function(key, reducedValue) {
        return reducedValue.totalDelayMinutes / reducedValue.count;
      }
    }

    results = Flight.map_reduce(map, reduce).out(inline: 1).finalize(finalize)

    #db.flights.mapReduce(map, reduce, { finalize: finalize, out: { inline: 1 }, query: { ArrDelayMinutes: {$gt: 5}}})
  end
end
