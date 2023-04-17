require 'net/http'

# USA Only
ZIP_CODE = 98438

# create free account on https://docs.airnowapi.org/
API_KEY = '9F289D79-9CA9-46A0-B3DB-CCD47CAE36A8'

SCHEDULER.every '1m', :first_in => 0 do |job|

  http = Net::HTTP.new('www.airnowapi.org')
  response = http.request(Net::HTTP::Get.new("/aq/forecast/zipCode/?format=application/json&zipCode=#{ZIP_CODE}&distance=10&API_KEY=9F289D79-9CA9-46A0-B3DB-CCD47CAE36A8"))

  next unless '200'.eql? response.code

  air_data     = JSON.parse(response.body)
  location     = air_data[0]['ReportingArea']
  dateForecast = air_data[0]['DateForecast']
  aqiName      = air_data[0]["Category"]['Name']
  aqi          = air_data[0]['AQI']

  send_event('airnow',  { :aqi          => aqi,
                          :location     => location,
                          :aqiName      => aqiName,
                          :dateForecast => dateForecast,
                          :color        => aqi_color(aqi),
                          :icon         => aqi_icon(aqi), })
end


def aqi_color(aqi)
  case aqi.to_i
  when 0..50
    'YellowGreen'
  when 51..100
    'gold'
  when 101..150
    'orange'
  when 151..200
    'red'
  when 201..300
    'darkred'
  else
    'maroon'
  end
end

def aqi_icon(aqi)
  case aqi.to_i
  when 0..50
    'icon-smile'
  when 51..100
    'icon-stethoscope'
  when 101..150
    'icon-ambulance'
  when 151..200
    'icon-frown'
  when 201..300
    'icon-meh'
  else
    'icon-trash'
  end
end