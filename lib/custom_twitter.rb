module CustomTwitter

	def oauth_header(method, path, oauth_params = {})

		SimpleOAuth::Header.new(method.upcase,"https://api.twitter.com/" + path, {}, oauth_params).to_s
	
	end

	def oauth_details(params = {})

		{ 
		:consumer_key => CONSUMER_KEY_HERE,
		:consumer_secret => CONSUMER_SECRET_HERE,
		}.merge(params)
	end

	def https_client

		client = Net::HTTP.new("api.twitter.com", 443)
		client.use_ssl = true
		client

	end

	def http_post(url)

		Net::HTTP::Post.new(URI(url))

	end

	def http_get(url)

		Net::HTTP::Get.new(URI(url))

	end

	def res_to_h(res)

		Hash[URI.decode_www_form(res)]

	end

	def api_get(end_point, params = {})

		client = https_client
		end_point += ".json"

		request = http_get("https://api.twitter.com/" + end_point)
		oauth_params = {
			token: session[:oauth][:oauth_token],
			token_secret: session[:oauth][:oauth_token_secret]
		}
		request["Authorization"] = oauth_header("GET", end_point , oauth_details(oauth_params))
			
		JSON( client.request( request ).body )
	end

	def oauth_start_flow

		session[:oauth] = {}

		oauth_request_token
		oauth_authenticate

	end

	def oauth_request_token


		client = https_client
		request = http_post("https://api.twitter.com/oauth/request_token")
		oauth_params = {
			callback: CALLBACK_HERE
		}	
		request["Authorization"] = oauth_header("POST", "oauth/request_token", oauth_details(oauth_params))
		response = client.request(request)
		unless response.code == "200"
			redirect to('/failure')
		end
		res_body = res_to_h(response.body)
		
		session[:oauth][:oauth_token] = res_body["oauth_token"]
		session[:oauth][:oauth_token_secret] = res_body["oauth_token_secret"]

	end

	def oauth_authenticate

		redirect to("https://api.twitter.com/oauth/authenticate?oauth_token=#{session[:oauth][:oauth_token]}")
	
	end


	def oauth_access_token(res)

		unless res[:oauth_token] == session[:oauth][:oauth_token]
			redirect to('failure')
		end

		client = https_client

		session[:oauth][:oauth_verifier] = res[:oauth_verifier]
		request = http_post("https://api.twitter.com/oauth/access_token")
		oauth_params = {
			token: session[:oauth][:oauth_token],
			token_secret: session[:oauth][:oauth_token_secret]
		}
		request["Authorization"] = oauth_header("POST","oauth/access_token", oauth_details(oauth_params))
		request.body = "oauth_verifier=" + session[:oauth][:oauth_verifier]
		response = client.request(request)
		
		unless response.code == "200"
			redirect to('/failure')
		end
		res_body = res_to_h(response.body)

		session[:oauth][:oauth_token] = res_body["oauth_token"]
		session[:oauth][:oauth_token_secret] = res_body["oauth_token_secret"]

	end

	def get_user

		api_get("/1.1/account/verify_credentials")

	end
end


	





	


