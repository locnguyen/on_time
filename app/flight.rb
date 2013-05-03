require 'mongoid'

class Flight
  include Mongoid::Document

  field :Year, type: Integer
  field :Quarter, type: Integer
  field :Month, type: Integer
  field :DayofMonth, type: Integer
  field :DayOfWeek, type: Integer
  field :FlightDate, type: String
  field :UniqueCarrier, type: String
  field :AirlineID, type: Integer
  field :Carrier, type: String
  field :TailNum, type: Integer
  field :FlightNum, type: Integer
  field :OriginAirportID, type: Integer
  field :OriginAirportSeqID, type: Integer
  field :OriginCityMarketID, type: Integer
  field :Origin, type: String
  field :OriginCityName, type: String
  field :OriginState, type: String
  field :OriginStateFips, type: String
  field :OriginStateName, type: String
  field :OriginWac, type: String
  field :DestAirportID, type: Integer
  field :DestAirportSeqID, type: Integer
  field :DestCityMarketID, type: Integer
  field :Dest, type: String
  field :DestCityName, type: String
  field :DestState, type: String
  field :DestStateFips, type: String
  field :DestStateName, type: String
  field :DestWac, type: String
  field :CRSDepTime, type: Integer
  field :DepTime, type: Integer
  field :DepDelay, type: Integer
  field :DepDelayMinutes, type: Integer
  field :DepDel15, type: Boolean
  field :DepTimeBlk, type: Integer
  field :TaxiOut, type: Float
  field :WheelsOff, type: Integer
  field :WheelsOn, type: Integer
  field :TaxiIn, type: Float
  field :CRSArrTime, type: Integer
  field :ArrTime, type: Float
  field :ArrDelay, type: Float
  field :ArrDelayMinutes, type: Float
  field :ArrDel15, type: Float
  field :ArrivalDelayGroups, type: Integer
  field :ArrTimeBlk, type: String
  field :Cancelled, type: Float
  field :CancellationCode, type: String
  field :Diverted, type: Float
  field :CRSElapsedTime, type: Float
  field :ActualElapsedTime, type: Float
  field :AirTime, type: Float
  field :Flights, type: Float
  field :Distance, type: String
  field :DistanceGroup, type: Integer
  field :CarrierDelay, type: Float
  field :WeatherDelay, type: Float
  field :NASDelay, type: Float
  field :SecurityDelay, type: Float
  field :LateAircraftDelay, type: Float
  field :FirstDepTime, type: String
  field :TotalAddGTime, type: String
end
