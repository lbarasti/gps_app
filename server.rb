#!/usr/bin/env ruby
require 'sinatra'
require 'haml'
require 'json'
require 'open-uri'
require 'thread'
#set :bind, '192.168.42.110'
#set :server, :thin
#enable :lock

HEADERS_HASH = {"User-Agent" => "Ruby/#{RUBY_VERSION}"}

@@data_lock = Mutex.new
@@data = {}
@@last_img_url = nil
@@max_history = 10

@@data[:ocado] = {
	routes: {},
	info: {},
	history: {}
}

# hatfield centre: 51.7639267,-0.2135151
@@data[:demo] = {
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
	info: {
    a: 'Station',
    b: 'Ocado'
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
	},
}

get '/getdata/:channel' do
	halt(404) if @@data[params[:channel].to_sym].nil?
	data = @@data[params[:channel].to_sym][:routes].values.map {|x|
    x.map {|n|
      n.merge({:age => (thetime-n[:serverseconds])})}
  }.to_json
	if request["callback"]
		content_type 'text/plain'
		"#{request["callback"]}(#{data})"
	else
		content_type :json
		data
	end
end

get '/gethistory/:channel' do
	halt(404) if @@data[params[:channel].to_sym].nil?

	thetime = Time.now.utc.to_i # time in SECONDS
	#ugly insertion of age
	data = Hash[@@data[params[:channel].to_sym][:history].map { |k, v|
    newv = v.map { |n|
      n.merge({:age => (thetime-n[:serverseconds])})
    }
    [k, newv]
  }].to_json
	if request["callback"]
		content_type 'text/plain'
		"#{request["callback"]}(#{data})"
	else
		content_type :json
		data
	end
end

post '/post/:channel' do
	halt(404) if @@data[params[:channel].to_sym].nil?
	return if params[:accuracy].to_f > 100

	@@data_lock.synchronize{
		thetime = Time.now.utc.to_i # time in SECONDS
		reading = {
			route: params[:route],
			longitude: params[:longitude],
			latitude: params[:latitude],
			timestamp: params[:timestamp],
			last_restarted: params[:last_restarted],
			accuracy: params[:accuracy],
			serverseconds: thetime
		}

		#DATA
		@@data[params[:channel].to_sym][:routes][params[:route]] = reading

		#HISTORY
		#set to empty array if not exist...
		@@data[params[:channel].to_sym][:history][params[:route]] ||= []
		@@data[params[:channel].to_sym][:history][params[:route]].unshift(reading)

		#TODO: limit the size of the history array. the stuff below crashes the server...
		l = @@data[params[:channel].to_sym][:history][params[:route]].length
		if (l > @@max_history)
			ch = @@data[params[:channel].to_sym][:history]
      ch[params[:route]] = (ch[params[:route]]).take(@@max_history)
		end
	}
end

get '/display/:channel' do
  send_file File.join(settings.public_folder, '/html/bustracker.html')
end

get '/' do
  send_file File.join(settings.public_folder, '/html/bustracker.html')
end

get '/form/:channel' do
	content_type :html
	<<-END
	<form action="/post/#{params[:channel]}" method="post">
    	<label for="route">route</label>: <input type="text" name="route"><br>
    	<label for="longitude">longitude</label>: <input type=
    	"text" name="longitude"><br>
    	<label for="latitude">latitude</label>: <input type="text" name="latitude"><br>
    	<label for="timestamp">timestamp</label>: <input type="text" name="timestamp"><br>
    	<input type="submit">
    </form>
    END
end
