require 'rubygems'
require 'sinatra'
require 'erb'

require 'sequel'
DB = Sequel.sqlite("app.db")
require 'user'

require 'helpers'

enable :sessions

get "/" do
  erb :home
end

# RESTful konvenciók
# GET    /users         => összes user
# GET    /users/new     => új user form
# GET    /users/42      => 42 id-jű user oldala
# POST   /users         => létrehoz usert
# GET    /users/42/edit => 42-es user szerkesztése
# PUT    /users/42      => módosítja a 42-es usert
# DELETE /users/42      => törli a 42-es usert

get "/users/?" do
  @users = User.all
  erb :"users/index"
end

get "/users/:id" do
  if @user = User[params[:id]]
    erb :"users/show"
  else
    pass
  end
end

get "/users/new" do
  @user = User.new(params[:user] || {})
  erb :"users/new"
end

post "/users" do
  begin
    @user = User.new(params[:user] || {})
    @user.save
    session[:current_user_id] = @user.id
    session[:notice] = "Sikeres regisztráció, be is vagy már jelentkezve!"
    redirect "/users/#{@user.id}"
  rescue Sequel::ValidationFailed
    session[:error] = "Hiba az űrlapban"
    erb :"users/new"
  end
end

post "/login" do
  if user = User.authenticate(params[:user], params[:pass])
    session[:current_user_id] = user.id
    session[:notice] = "Sikeres bejelentkezés!"
    redirect "/users/#{user.id}"
  else
    session[:error] = "Hibás felhasználónév vagy jelszó"
    redirect "/"
  end
end

get "/logout" do
  session[:current_user_id] = nil
  session[:notice] = "Sikeres kijelentkezés!"
  redirect "/"
end
