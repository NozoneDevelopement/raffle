before do
    #Open the database
    $DB = Sequel.sqlite('eurusraffle.sqlite')
end

get '/raffle' do
    session[:current_user_id] = nil
    if !$active_raffle
        redirect '/closed'
    end
    $shoe_sizes = $DB[:Sizes].all

    erb :raffle
end

get '/admin_logged_in' do
    if !session[:admin]
        redirect '/admin'
    end

    $users = $DB[:Users].all
    $new_users = $DB[:New_Users].all
    $shoe_sizes = $DB[:Sizes].order(Sequel.asc(:shoe_size))

    erb :admin_logged_in
end

get '/wait' do
    if session[:current_user_id] == nil
        remove_new_user
        redirect '/unapproved'
    end

    if $DB[:New_Users].where(:new_user_id => session[:current_user_id]).get(:approved)
        new_name = $DB[:New_Users].where(:new_user_id => session[:current_user_id]).get(:name)
        new_size = $DB[:New_Users].where(:new_user_id => session[:current_user_id]).get(:shoe_size)
        new_email = $DB[:New_Users].where(:new_user_id => session[:current_user_id]).get(:paypal_email)
        new_handle = $DB[:New_Users].where(:new_user_id => session[:current_user_id]).get(:instagram_handle)

        $DB[:Users].insert(name: new_name, shoe_size: new_size, paypal_email: new_email, instagram_handle: new_handle)

        $DB[:New_Users].where(:new_user_id => session[:current_user_id]).delete
        session[:current_user_id] = nil

        redirect '/success'

    elsif $DB[:New_Users].where(:new_user_id => session[:current_user_id]).get(:approved) == false
        remove_new_user

        redirect '/unapproved'
    end

    erb :wait
end

post '/submit_data' do
    puts params[:shoe_size]
    $error_message = validate(params[:name], params[:shoe_size], params[:paypal_email], params[:confirm_paypal_email], params[:instagram_handle])

    if $error_message == ""
        if session[:current_user_id] == nil
            $DB[:New_Users].insert(name: params[:name], shoe_size: params[:shoe_size], paypal_email: params[:paypal_email], instagram_handle: params[:instagram_handle], approved: nil)
            session[:current_user_id] = $DB[:New_Users].where(:instagram_handle => params[:instagram_handle]).get(:new_user_id)
            redirect '/wait'
        else
            redirect '/unapproved'
        end
    end

    redirect '/raffle'
end

post '/admin_login' do
    if !check_password(params[:password])
        redirect '/admin'
    end

    session[:admin] = true
    redirect '/admin_logged_in'
end

post '/remove_user' do
    $DB[:Users].where(:user_id => params[:user_to_remove]).delete

    redirect '/admin_logged_in'
end


post '/clear_database' do
    $DB[:Users].delete
    $DB[:New_Users].delete
    redirect '/admin_logged_in'
end

post '/add_size' do
    $DB[:Sizes].insert(shoe_size: params[:shoe_size])

    redirect '/admin_logged_in'
end

post '/remove_size' do
    $DB[:Users].where(:shoe_size => params[:size_to_remove]).delete
    $DB[:Sizes].where(:shoe_size => params[:size_to_remove]).delete

    redirect '/admin_logged_in'
end

post '/toggle_raffle' do
    $active_raffle = !$active_raffle

    redirect '/admin_logged_in'
end

post '/approve_user' do
    $DB[:New_Users].where(:new_user_id => params[:user_to_approve]).update(:approved => 1)

    redirect '/admin_logged_in'
end

post '/unapprove_user' do
    $DB[:New_Users].where(:new_user_id => params[:user_to_unapprove]).update(:approved => 0)

    redirect '/admin_logged_in'
end

post '/shoe_name' do
    $shoe_name = params[:shoe_name]

    redirect '/admin_logged_in'
end

def validate(u_name, shoe_size, paypal_email, confirm_paypal_email, instagram_handle)
    error_message = ""

    error_message = "No size selected" if shoe_size == nil
    error_message = "Instagram handle invalid" if !(instagram_handle =~ /^(@[A-Za-z0-9_](?:(?:[A-Za-z0-9_]|(?:\.(?!\.))){0,28}(?:[A-Za-z0-9_]))?)$/)
    error_message = "Instagram handle must include an @ symbol" if instagram_handle[0] != '@'
    error_message = "Instagram handle not entered" if instagram_handle == ""
    error_message = "PayPal emails don't match" if paypal_email != confirm_paypal_email
    error_message = "PayPal email invalid" if !(paypal_email =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/) 
    error_message = "No PayPal email entered" if paypal_email == ""
    error_message = "No shoe size selected" if shoe_size == ""
    error_message = "Name not entered" if u_name == ""

    $DB[:Users].select(:instagram_handle).all do |handle|
        error_message = "Instagram handle has already been used" if handle[:instagram_handle] == instagram_handle || handle[:instagram_handle] == '@' + instagram_handle
    end

    $DB[:New_Users].select(:instagram_handle).all do |handle|
        error_message = "Instagram handle has already been used" if handle[:instagram_handle] == instagram_handle || handle[:instagram_handle] == '@' + instagram_handle
    end

    $DB[:Users].select(:paypal_email).all do |email|
        error_message = "Email has already been used" if email[:paypal_email] == paypal_email
    end

    $DB[:New_Users].select(:paypal_email).all do |email|
        error_message = "Email has already been used" if email[:paypal_email] == paypal_email
    end

    return error_message
end

def remove_new_user()
    $DB[:New_Users].where(:new_user_id => session[:current_user_id]).delete
    session[:current_user_id] = nil
end

def check_password(password)
    File.open("passwords.txt").each do |line|
        if (Digest::SHA1.hexdigest password.chomp) == line
            return true    
        end
    end

    return false
end