require 'rubygems'
require 'sinatra'
require 'erb'

require 'sequel'
DB = Sequel.connect(ENV['DATABASE_URL'] || "sqlite://app.db")
Sequel::Model.strict_param_setting = false
require 'user'
require 'secret'

require 'helpers'

enable :sessions

get "/" do
  @secrets = Secret.all
  erb :home
end

# RESTful konvenciók
# GET    /users           => összes user
# GET    /users/new       => új user form
# GET    /users/42        => 42 id-jű user oldala
# POST   /users           => létrehoz usert
# GET    /users/42/edit   => 42-es user szerkesztése
# PUT    /users/42        => módosítja a 42-es usert
# GET    /users/42/delete => 42-es user törlésének megerősítése
# DELETE /users/42        => törli a 42-es usert

get "/users/?" do
  require_user
  @users = User.all
  erb :"users/index"
end

get "/users/new" do
  unless logged_in?
    @user = User.new(params[:user] || {})
    erb :"users/new"
  else
    redirect "/users/#{current_user.id}"
  end
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

get "/users/:id" do
  require_user
  not_found unless @user = User[params[:id]]
  erb :"users/show"
end

get "/users/:id/edit" do
  require_user
  not_found unless @user = User[params[:id]]
  if @user == current_user
    erb :"users/edit"
  else
    session[:error] = "Csak a saját adataidat szerkesztheted!"
    redirect "/users/#{@user.id}"
  end
end

put "/users/:id" do
  require_user
  not_found unless @user = User[params[:id]]
  if @user == current_user
    begin
      @user.update_except(params[:user], :login)
      session[:notice] = "Sikeres módosítás!"
      redirect "/users/#{@user.id}"
    rescue Sequel::ValidationFailed
      session[:error] = "Hiba az űrlapban"
      erb :"users/edit"
    end
  else
    session[:error] = "Csak a saját adataidat szerkesztheted!"
    redirect "/users/#{@user.id}"
  end
end

get "/users/:id/delete" do
  require_user
  not_found unless @user = User[params[:id]]
  if @user == current_user
    erb :"users/delete"
  else
    session[:error] = "Mit gondolsz, csak úgy kitörölhetsz akárkit?"
    redirect "/users/#{@user.id}"
  end
end

delete "/users/:id" do
  require_user
  not_found unless @user = User[params[:id]]
  if @user == current_user
    @user.delete
    session[:current_user_id] = nil
    session[:notice] = "Sikeresen törölted magad!"
    redirect "/"
  else
    session[:error] = "Mit gondolsz, csak úgy kitörölhetsz akárkit?"
    redirect "/users/#{@user.id}"
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

get "/secrets/?" do
  require_user
  @secrets = Secret.filter(:user_id => current_user.id)
  erb :"secrets/index"
end

get "/secrets/new" do
  require_user
  @secret = Secret.new(params[:secret] || {})
  erb :"secrets/new"
end

post "/secrets" do
  require_user
  begin
    @secret = Secret.new(params[:secret] || {})
    @secret.user_id = current_user.id
    @secret.save
    session[:notice] = "Biztonságosan lejegyezted a kis titkodat..."
    redirect "/secrets/#{@secret.id}"
  rescue Sequel::ValidationFailed
    session[:error] = "Hiba az űrlapban"
    erb :"secrets/new"
  end
end

get "/secrets/:id" do
  require_user
  not_found unless @secret = Secret[params[:id]]
  error(403, "Nincs ehhez jogosultságod") unless @secret.allowed_to_view?(current_user)
  erb :"secrets/show"
end

get "/secrets/:id/edit" do
  require_user
  not_found unless @secret = Secret[params[:id]]
  error(403, "Nincs ehhez jogosultságod") unless @secret.allowed_to_update?(current_user)
  erb :"secrets/edit"
end

put "/secrets/:id" do
  require_user
  not_found unless @secret = Secret[params[:id]]
  error(403, "Nincs ehhez jogosultságod") unless @secret.allowed_to_update?(current_user)
  begin
    @secret.update(params[:secret])
    session[:notice] = "Sikeres módosítás!"
    redirect "/secrets/#{@secret.id}"
  rescue Sequel::ValidationFailed
    session[:error] = "Hiba az űrlapban"
    erb :"secrets/edit"
  end
end

get "/secrets/:id/delete" do
  require_user
  not_found unless @secret = Secret[params[:id]]
  error(403, "Nincs ehhez jogosultságod") unless @secret.allowed_to_update?(current_user)
  erb :"secrets/delete"
end

delete "/secrets/:id" do
  require_user
  not_found unless @secret = Secret[params[:id]]
  error(403, "Nincs ehhez jogosultságod") unless @secret.allowed_to_update?(current_user)
  @secret.delete
  session[:notice] = "Sikeresen törölted a kis titkodat... de ne hidd, hogy így nem jönnek majd rá!"
  redirect "/secrets"
end

