

helpers do 

	def oauth(method, path, oauth_params = {})

		SimpleOAuth::Header.new(method.upcase,"https://api.twitter.com/" + path, {}, oauth_params).to_s
	
	end

	def oauth_details(params = {})

		{ 
		:consumer_key => "mZ0Z083rZhp9vAhimXdIInP7l",
		:consumer_secret => "sXqKUuKRobRHVckZhMDzzYmOuEX1VvouS1yZ7oPK36sqA51tFs",
		}.merge(params)
	end

	def https_client

		ret = Net::HTTP.new("api.twitter.com", 443)
		ret.use_ssl = true
		ret

	end

	def exchange_request_token(request_token)
	end


end

	

get '/' do


	if session[:oauth]
		@user = "YoYO"
	end
	erb :index

end


get '/auth' do


	session[:oauth] = {} 

	auth_request = Net::HTTP::Post.new(URI("https://api.twitter.com/oauth/request_token"))
	auth_request["Authorization"] = oauth("POST", "oauth/request_token", oauth_details({:callback => "http://polar-wave-5903.herokuapp.com/auth_callback"}))
	
	client = https_client
	
	auth_response = client.request(auth_request)
	redirect to('/failure') if auth_response.code.to_i != 200 
	auth_response = Hash[URI.decode_www_form(auth_response.body)]

	redirect to('/failure') if auth_response["oauth_callback_confirmed"] != "true"
	session[:oauth][:oauth_token] = auth_response["oauth_token"]
        session[:oauth][:oauth_token_secret] = auth_response["oauth_token_secret"]

	redirect_uri = URI("https://api.twitter.com/oauth/authenticate?oauth_token=#{session[:oauth][:oauth_token]}")
	redirect to(redirect_uri.to_s)
		

end


get '/auth_callback' do
	
	redirect to('/failure') unless params[:oauth_token] == session[:oauth][:oauth_token]

	session[:oauth][:oauth_verifier] = params[:oauth_verifier]

	client = https_client


	auth_request = Net::HTTP.Post.new(URI("https://api.twitter.com/oauth/access_token"))
	auth_request.body = "oauth_verifier=" + session[:oauth][:oauth_verifier].to_s
	auth_request["Authorization"] = oauth("POST", "oauth/access_token",oauth_details({:token => session[:oauth][:oauth_token],:token_secret => session[:oauth][:oauth_token_secret]}))
	
	auth_response = client.request(auth_request)

	redirect to('/failure') unless auth_response.code.to_i == 200

	auth_response = Hash[URI.decode_www_form(auth_response.body)]
	session[:oauth][:oauth_token] = auth_response["oauth_token"]
	session[:oauth][:oauth_token_secret] = auth_response["oauth_token_secret"]

	redirect to('/')


end

get '/failure' do

	session[:oauth] = nil

	erb :failure

end

	

