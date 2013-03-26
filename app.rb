require 'sinatra'
require 'redis'
require 'json'

## Not required
require 'postmark'
require 'mail'

####
# /email-validation/:key/pixel
# /email-validation/:key/activated
####

###############################
## Helpers                   ##
###############################
helpers do  
  def random_string(length)  
    rand(36**length).to_s(36)  
  end  
end 
################################ 

redis = Redis.new

get '/' do
	erb :index
end

post '/register' do
	@tracking_key = random_string 10

	image_source = "<img src='http://localhost:9292/email-validation/#{@tracking_key}/pixel.gif' />"
	tracking_key = @tracking_key

	to_email = params[:email]
	api_key = ''
	from_email = ''

	message = Mail.new do
		from            from
		to              "Leonard Hofstadter <#{to_email}>"
		subject         'Re: What, to you, is a large crowd?'

		content_type    'text/html; charset=UTF-8'
		body            "<p>Your account should be validated.</p> Hello #{image_source}"

		delivery_method Mail::Postmark, :api_key => api_key
	end

	message.deliver

	# 'test'
	erb :validate
end

get '/email-validation/:key/validated' do
	validated = redis.get "keys:#{params[:key]}:validated"

	{:validated => (validated || false)}.to_json
end

get '/email-validation/:key/pixel.gif' do
	redis.set "keys:#{params[:key]}:validated", true

	send_file 'public/img/pixel.gif'
end