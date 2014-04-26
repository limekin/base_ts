configure do

	enable :sessions
end

helpers CustomTwitter

before do

	@user = session[:user]

end

get '/' do

	erb :index

end

get '/auth' do

	oauth_start_flow

end


get '/auth_callback' do

	oauth_access_token(params)
	session[:user] = get_user
	redirect to('/')

end

get '/failure' do

	session[:oauth] = nil
	session[:user] = nil

	erb :failure

end

	

