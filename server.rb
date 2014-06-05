require 'sinatra'
require_relative 'helpers'

use Rack::Session::Cookie, :expire_after => 10, # in seconds
                           :secret => ENV['SECRET_TOKEN']


helpers do
  def logged_in
    if session[:user_id] != nil
      return check_user(session[:user_id])
    end
    false
  end
end

get '/' do
  @username = logged_in
  if @username != false
    erb :index
  else
    redirect '/login'
  end
end

get '/logout' do
  session[:user_id] = nil
  redirect '/login'
end

get '/login/?' do
  @username = logged_in
  if @username != false
    redirect '/'
  end
  @title = "Login"
  erb :login
end

post '/login' do
  @username = params["user"]
  @password = params["password"]
  @userinfo = login(@username, @password)
  if @userid != false
    session[:user_id] = @userinfo[0]["id"]
    session[:business_name] = @userinfo[0]["business_name"]
    session[:user_role] = @userinfo[0]["role_name"]
    redirect '/'
  else
    erb :login
  end
end

get '/signup/?' do
  @username = logged_in
  if @username != false
    redirect '/'
  end
  @title = "Sign Up"
  erb :signup
end

post '/signup' do
  @username = params["user"]
  @password = params["password"]
  @role = 4
  sign_up(@username, @password)
  redirect '/login'
end

get '/signup_business' do
  @username = logged_in
  if @username != false
    redirect '/'
  end
  @title = "Sign Up"
  erb :signup_bus
end

post '/signup_business' do
  @username = params["user"]
  @password = params["password"]
  @role = 3
  @business_name = params["business_name"]
  sign_up(@username, @password, @role, @business_name)
  redirect '/login'
end
