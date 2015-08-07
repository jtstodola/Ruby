require 'open-uri'
require 'json'
require 'sinatra'

class Weather
  attr_reader :city, :state, :temperature_f, :error_message
  
  def initialize(city, state, zipcode)
    @city = city
    @state = state
    @zipcode = zipcode
  end

  def url
    api_key = ''
    
    if @zipcode == nil
      url = "http://api.wunderground.com/api/#{api_key}/conditions/q/#{@state}/#{@city}.json"
    else
      url = "http://api.wunderground.com/api/#{api_key}/conditions/q/#{@zipcode}.json"
    end
  end
  
  def fetch
    @error_message = nil

    begin
      raw_data = open(url).read
      weather_data = JSON.parse(raw_data)
      
      @temperature_f = weather_data["current_observation"]["temp_f"]
      @city = weather_data["current_observation"]["display_location"]["city"]
      @state = weather_data["current_observation"]["display_location"]["state"]
      @zipcode = weather_data["current_observation"]["display_location"]["zip"]
    rescue
      @error_message = "I don't seem to be able to grab the weather for you."
    end
  end
end


class Alerts
  attr_reader :city, :state, :zone, :message, :expires, :description, :alerts
   
  def initialize(city, state, zipcode)
    @city = city
    @state = state
    @zipcode = zipcode
  end  

  def url
    api_key = '1d8a0f026c48e89a'

    if @zipcode == nil
      url = "http://api.wunderground.com/api/#{api_key}/alerts/q/#{@state}/#{@city}.json"
    else
      url = "http://api.wunderground.com/api/#{api_key}/alerts/q/#{@zipcode}.json"
    end
  end
  
  def fetch

    begin
      raw_data = open(url).read
      weather_data = JSON.parse(raw_data)
      
      @zone = weather_data["query_zone"]
      @alerts = weather_data["alerts"]
      @description = weather_data["alerts"].first["description"]
      @expires = weather_data["alerts"].first["expires"]
      @message = weather_data["alerts"].first["message"] 
    rescue
      @error_message = "I don't seem to be able to grab any alerts for you."
    end
  end
end


get '/weather/:state/:city' do
  zipcode = params['zip']
  city = params['city']
  state = params['state']

  weather = Weather.new(city, state, zipcode)

  if weather.fetch
    "The temperature in #{weather.city}, #{weather.state} is #{weather.temperature_f} degrees." 
  else
    "#{weather.error_message}"
  end
end


get '/weather/:zip' do
  zipcode = params['zip']
  city = params['city']
  state = params['state']

  weather = Weather.new(city, state, zipcode)

  if weather.fetch
    "The temperature in #{weather.city}, #{weather.state} is #{weather.temperature_f} degrees." 
  else
    "#{weather.error_message}"
  end
end


get '/alerts/:zip' do
  zipcode = params['zip']
  city = params['city']
  state = params['state']
  
  alerts = Alerts.new(city, state, zipcode)
  
  if alerts.fetch
    if alerts.alerts != []
      "Zone: #{alerts.zone}<br>Type: #{alerts.description}<br>Expires: #{alerts.expires}<br>Message: #{alerts.message}" 
    else
      "There are no alerts at this time."
    end
  else
    "#{weather.error_message}"
  end
end

get '/alerts/:state/:city' do
  zipcode = params['zip']
  city = params['city']
  state = params['state']
  
  alerts = Alerts.new(city, state, zipcode)
  
  if alerts.fetch
    if alerts.alerts != []
      "Zone: #{alerts.zone}<br>Type: #{alerts.description}<br>Expires: #{alerts.expires}<br>Message: #{alerts.message}" 
    else
      "There are no alerts at this time."
    end
  else
    "#{weather.error_message}"
  end
end