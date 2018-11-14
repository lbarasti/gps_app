#!/usr/bin/env ruby
require 'sinatra'
require 'json'

MAX_HISTORY = 10
DATA_LOCK = Mutex.new

INIT_STATE = {
  ocado: {
    routes: {},
    history: {}
  },
  demo: {
    routes: {
      blackberry: {
        route: 'blackberry',
        longitude: -0.03,
        latitude: 51.64,
        timestamp: 'Thu Oct 17 21:51:10 GMT+01:00 2013',
        serverseconds: 1_418_902_684
      },
      strawberry: {
        route: 'strawberry',
        longitude: -0.15,
        latitude: 54.22,
        timestamp: 'Thu Oct 17 21:52:11 GMT+01:00 2013',
        serverseconds: 1_418_902_684
      }
    },
    history: {
      blackberry: [
        {
          route: 'blackberry',
          longitude: -0.235,
          latitude: 51.7635,
          timestamp: 'Thu Oct 17 21:51:35 GMT+01:00 2013',
          serverseconds: Time.now.utc.to_i
        }, {
          route: 'blackberry',
          longitude: -0.230,
          latitude: 51.7630,
          timestamp: 'Thu Oct 17 21:51:30 GMT+01:00 2013',
          serverseconds: 1_418_902_674
        }, {
          route: 'blackberry',
          longitude: -0.245,
          latitude: 51.7645,
          timestamp: 'Thu Oct 17 21:51:45 GMT+01:00 2013',
          serverseconds: 1_418_896_929
        }, {
          route: 'blackberry',
          longitude: -0.240,
          latitude: 51.7640,
          timestamp: 'Thu Oct 17 21:51:40 GMT+01:00 2013',
          serverseconds: 1_418_896_159
        }
      ],
      strawberry: [
        {
          route: 'strawberry',
          longitude: -0.220,
          latitude: 51.76400,
          timestamp: 'Thu Oct 17 21:52:11 GMT+01:00 2013',
          serverseconds: 1_418_900_000
        }, {
          route: 'strawberry',
          longitude: -0.250,
          latitude: 51.76395,
          timestamp: 'Thu Oct 17 21:53:11 GMT+01:00 2013',
          serverseconds: 1_418_899_000
        }
      ]
    }
  }
}

class Array
  def create_response
    Hash[self].to_json
  end
end

class Channels
  def initialize(data)
    @data = data
  end

  def respond(params)
    (yield(Time.now.utc.to_i, get_channel_data(params)) || []).create_response
  end

  def channels
    @data.keys.to_json
  end

  private

  def get_channel_data(params)
    @data[params[:channel].to_sym] || halt(404)
  end
end

def serve_file(path)
  send_file File.join settings.public_folder, path
end

class Hash
  def add_age(time)
    merge age: (time - self[:serverseconds])
  end
end

DATA = Channels.new(INIT_STATE)


get '/channels' do
  DATA.channels
end

get '/getdata/:channel' do
  DATA.respond params do |time, channel_data|
    channel_data[:routes].map do |k, v|
      [k, v.add_age(time)]
    end
  end
end

get '/gethistory/:channel' do
  # ugly insertion of age
  DATA.respond params do |time, channel_data|
    channel_data[:history].map do |k, v|
      newv = v.map do |n|
        n.add_age(time)
      end
      [k, newv]
    end
  end
end

post '/post/:channel' do
  DATA.respond params do |time, channel_data|
    unless params[:accuracy].to_f > 100

      route_id = params[:route]

      reading = {
        longitude: params[:longitude],
        latitude: params[:latitude],
        timestamp: params[:timestamp],
        serverseconds: time
      }

      DATA_LOCK.synchronize do
        # DATA
        channel_data[:routes][route_id] = reading

        # HISTORY
        # set to empty array if not exist...
        history_data = channel_data[:history]
        history_data[route_id] ||= []
        route_history = history_data[route_id]
        route_history.unshift reading

        # TODO: limit the size of the history array.
        # the stuff below crashes the server!
        if route_history.length > MAX_HISTORY
          history_data[route_id] = route_history.take MAX_HISTORY
        end
      end
    end
  end
end

# Will still be in the public folder even if this get is not forwarded
get '/form/:channel' do
  serve_file '/html/backdoor.html'
end

get '/display/:channel' do
  serve_file '/html/bustracker.html'
end

get '/beta/' do
  serve_file '/html/bustracker2.html'
end

get '/' do
  serve_file '/html/bustracker.html'
end
