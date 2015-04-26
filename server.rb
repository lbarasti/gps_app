#!/usr/bin/env ruby
require 'sinatra'
require 'json'
require 'open-uri'
require 'thread'
#set :bind, '192.168.42.110'
#set :server, :thin
#enable :lock

HEADERS_HASH = {"User-Agent" => "Ruby/#{RUBY_VERSION}"}

@@data_lock = Mutex.new
@@max_history = 10

@@data = {
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
                serverseconds: 1418902684
            },
            strawberry: {
                route: 'strawberry',
                longitude: -0.15,
                latitude: 54.22,
                timestamp: 'Thu Oct 17 21:52:11 GMT+01:00 2013',
                serverseconds: 1418902684
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
                    serverseconds: 1418902674
                }, {
                    route: 'blackberry',
                    longitude: -0.245,
                    latitude: 51.7645,
                    timestamp: 'Thu Oct 17 21:51:45 GMT+01:00 2013',
                    serverseconds: 1418896929
                }, {
                    route: 'blackberry',
                    longitude: -0.240,
                    latitude: 51.7640,
                    timestamp: 'Thu Oct 17 21:51:40 GMT+01:00 2013',
                    serverseconds: 1418896159
                }
            ],
            strawberry: [
                {
                    route: 'strawberry',
                    longitude: -0.220,
                    latitude: 51.76400,
                    timestamp: 'Thu Oct 17 21:52:11 GMT+01:00 2013',
                    serverseconds: 1418900000
                }, {
                    route: 'strawberry',
                    longitude: -0.250,
                    latitude: 51.76395,
                    timestamp: 'Thu Oct 17 21:53:11 GMT+01:00 2013',
                    serverseconds: 1418899000
                }
            ]
        }
    }
}

def get_time
    Time.now.utc.to_i # time in SECONDS
end

def add_age(route_segment, time)
    route_segment.merge({:age => (time - route_segment[:serverseconds])})
end

def get_channel_data(params)
    output = @@data[params[:channel].to_sym]
    halt(404) if output.nil?
    output
end

def serve_file(path)
    send_file File.join settings.public_folder, path
end

def create_response(data_array)
    content_type :json
    Hash[data_array].to_json
end


def respond(params, &block)
   create_response yield get_time, get_channel_data(params)
end


get '/channels' do
    @@data.keys.to_json
end

get '/getdata/:channel' do
    respond params do |time, channel_data|
        channel_data[:routes].map do |k, v|
            [k, add_age(v, time)]
        end
    end
end

get '/gethistory/:channel' do
    #ugly insertion of age
    respond params do |time, channel_data|
        channel_data[:history].map do |k, v|
            newv = v.map do |n|
                add_age n, time
            end
            [k, newv]
        end
    end
end


post '/post/:channel' do
    respond params do |time, channel_data|

        return if params[:accuracy].to_f > 100

        route_id = params[:route]

        reading = {
            longitude: params[:longitude],
            latitude: params[:latitude],
            timestamp: params[:timestamp],
            last_restarted: params[:last_restarted],
            accuracy: params[:accuracy],
            serverseconds: time
        }

        @@data_lock.synchronize do

            #DATA
            channel_data[:routes][route_id] = reading

            #HISTORY
            #set to empty array if not exist...
            history_data = channel_data[:history]
            history_data[route_id] ||= []
            history_data[route_id].unshift reading

            #TODO: limit the size of the history array. 
            #the stuff below crashes the server...
            l = route_history.length
            if l > @@max_history
                route_history = route_history.take @@max_history
            end
        end
        []
    end
end

# Will still be in the public folder even if this get is not forwarded
get '/form/:channel' do
    serve_file '/html/backdoor.html'
end

get '/display/:channel' do
    serve_file '/html/bustracker.html'
end

get '/' do
    serve_file '/html/bustracker.html'
end

