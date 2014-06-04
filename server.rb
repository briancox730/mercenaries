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
  @userid = login(@username, @password)
  if @userid != false
    session[:user_id] = @userid
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
  sign_up(@username, @password)
  redirect '/login'
end
