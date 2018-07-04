# link to index page
get '/' do 
    redirect '/raffle'
end

get '/success' do
	session[:current_user_id] = nil
	erb :success
end

get '/closed' do
	session[:current_user_id] = nil
	if $active_raffle
        redirect '/raffle'
    end
	erb :closed
end

get '/admin' do
	session[:current_user_id] = nil
	erb :admin_login
end

get '/unapproved' do
	erb :unapproved
end

get '/cookie' do
	erb :cookie
end

not_found do
  erb :error
end