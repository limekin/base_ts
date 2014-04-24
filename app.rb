helpers do 

	def oauth(method, path)

		SimpleOAuth::Header.new(method.upcase,"https://api.twitter.com/" + path, {}, oauth_details).to_s
	
	end

	def oauth_details

		{ 
		:consumer_key => "mZ0Z083rZhp9vAhimXdIInP7l",
		:consumer_secret => "sXqKUuKRobRHVckZhMDzzYmOuEX1VvouS1yZ7oPK36sqA51tFs",
		:callback => "oob"
		}
	end

	def http_client
		Net::HTTP.new("api.twitter.com", 443)
	end

end

	

get '/' do

	erb :index

end


get '/auth' do


	auth_request = Net::HTTP::Post.new(URI("https://api.twitter.com/oauth/request_token"))
	auth_request["Authorization"] = oauth("POST", "oauth/request_token")
	
	httpc = Net::HTTP.new("api.twitter.com", 443)
	httpc.use_ssl = true
	

	auth_response = httpc.request(auth_request)

	redirect to('/failure') if auth_response.code.to_i != 200 

	oauth_token = Hash[URI.decode_www_form(auth_response.body)]["oauth_token"]

	redirect_uri = URI("https://api.twitter.com/oauth/authenticate?oauth_token=#{oauth_token}")
	redirect to(redirect_uri.to_s)
		

end

get '/failure' do

	erb :failure

end

	

