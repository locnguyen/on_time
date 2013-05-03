module Routes
  ROOT = '/api'
  FLIGHTS =  '/api/flights'
  DELAYS = '/api/delays'
  AIRLINES = '/api/airlines'

  def ROUTES
    map = {}
    Routes.constants.each { |c| map[c.downcase] = Routes.const_get "#{c}" }
    map
  end
end

