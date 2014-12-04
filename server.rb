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

@@data[:ocado] = {
	routes: {},
	info: {},
	history: {}
}

# hatfield centre: 51.7639267,-0.2135151
@@data[:demo] = {
	routes: {
		blackberry: {route: 'blackberry', longitude: -0.03, latitude: 51.64, timestamp: 'Thu Oct 17 21:51:10 GMT+01:00 2013'},
		strawberry: {route: 'strawberry', longitude: -0.15, latitude: 54.22, timestamp: 'Thu Oct 17 21:52:11 GMT+01:00 2013'}
	},
	info: {a: 'Station', b: 'Ocado'},
	history: {
		blackberry: [
		    {route: 'blackberry', longitude: -0.235, latitude: 51.7635, timestamp: 'Thu Oct 17 21:51:35 GMT+01:00 2013'},
		    {route: 'blackberry', longitude: -0.230, latitude: 51.7630, timestamp: 'Thu Oct 17 21:51:30 GMT+01:00 2013'},
		    {route: 'blackberry', longitude: -0.245, latitude: 51.7645, timestamp: 'Thu Oct 17 21:51:45 GMT+01:00 2013'},
		    {route: 'blackberry', longitude: -0.240, latitude: 51.7640, timestamp: 'Thu Oct 17 21:51:40 GMT+01:00 2013'}
		],
		strawberry: [
		    {route: 'strawberry', longitude: -0.220, latitude: 51.76400, timestamp: 'Thu Oct 17 21:52:11 GMT+01:00 2013'},
		    {route: 'strawberry', longitude: -0.250, latitude: 51.76395, timestamp: 'Thu Oct 17 21:53:11 GMT+01:00 2013'}
		]
	},
} #if settings.environment == :development

get '/getdata/:channel' do
	halt(404) if @@data[params[:channel].to_sym].nil?
	data = @@data[params[:channel].to_sym][:routes].values.to_json
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
	data = @@data[params[:channel].to_sym][:history].values.to_json
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
		#@@data[params[:channel].to_sym] ||= {routes:{}, info:{}} # we'll deal with initialisation elsewhere
		reading = {
			route: params[:route],
			longitude: params[:longitude],
			latitude: params[:latitude],
			timestamp: params[:timestamp],
			last_restarted: params[:last_restarted],
			accuracy: params[:accuracy]
		}
		@@data[params[:channel].to_sym][:routes][params[:route]] = reading
		#TODO: push the data above into the history array, which should be some sort of rotating array to some sort of maximum number of readings

		@@data[params[:channel].to_sym][:history][params[:route]] ||= []
		@@data[params[:channel].to_sym][:history][params[:route]] << reading
	}
end

get '/displayJS' do
  send_file File.join(settings.public_folder, 'bustracker.html')
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
    # redirect '/getdata/#{params[:channel]}'
end

get '/display/:channel' do
	@data = {}
	source = @@data[params[:channel].to_sym][:routes].values.first || {}

	@data[:longitude] = source[:longitude]
	@data[:latitude] = source[:latitude]
	@data[:timestamp] = source[:timestamp]

	@data[:img_src] = "/map.png"
	img_url = "http://maps.googleapis.com/maps/api/staticmap?center=51.76714,-0.230977&zoom=14&size=450x250&maptype=roadmap&markers=color:red%7Clabel:B%7C#{@data[:latitude]},#{@data[:longitude]}&markers=color:blue%7C51.76326,-0.216651&markers=color:blue%7C51.762481,-0.243476&markers=color:blue%7C51.770688,-0.243632&sensor=false"

	if @@last_img_url != img_url
		@data[:img_src] = img_url
		if settings.environment != :development
			begin
				response = open(img_url, HEADERS_HASH)
				if response.status.first == "200"
					open File.join('public', 'map.png'),'w' do |file|
						file << response.read
					end
					@@last_img_url = img_url
				end
			rescue
				@data[:error] = "Google doesn't want to serve you this image. Please, try again later."
			end
		end
	end
	haml :display
end



