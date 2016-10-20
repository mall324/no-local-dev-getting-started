# app.rb

require 'sinatra'
require 'sinatra/activerecord'
require './environments'
require "omniauth"
require "omniauth-salesforce"

configure do
  enable :logging
  enable :sessions
  set :show_exceptions, false
  set :session_secret, ENV['SECRET']
end

use OmniAuth::Builder do
  provider :salesforce, ENV['SALESFORCE_KEY'], ENV['SALESFORCE_SECRET']
end

get '/auth/salesforce/callback' do
  logger.info "#{env["omniauth.auth"]["extra"]["display_name"]} just authenticated"
  credentials = env["omniauth.auth"]["credentials"]
  session['token'] = credentials["token"]
  session['refresh_token'] = credentials["refresh_token"]
  session['instance_url'] = credentials["instance_url"]
  redirect '/'
end

helpers do
  def client
    @client ||= Force.new instance_url:  session['instance_url'],
                          oauth_token:   session['token'],
                          refresh_token: session['refresh_token'],
                          client_id:     ENV['SALESFORCE_KEY'],
                          client_secret: ENV['SALESFORCE_SECRET']
  end
end

get '/' do
  logger.info "Visited home page"
  @accounts= client.query("select Id, Name from Account")
  erb :index
end

<table>
<tr><th>Account</th><th>ID</th></tr>
<% @accounts.each do |account| %>
  <tr>
     <td><%= account.Name %></td>
     <td><%= account.Id %></td>
  </tr>
<% end %>
</table>

class Contact < ActiveRecord::Base
  self.table_name = 'salesforce.contact'
end

get "/contacts" do
  @contacts = Contact.all
  erb :index
end


get "/" do
  erb :home
end


class Contact < ActiveRecord::Base
  self.table_name = 'salesforce.contact'
end

#get "/contacts" do
#  @contacts = Contact.all
#  erb :index
#end

get "/create" do
  dashboard_url = 'https://dashboard.heroku.com/'
  match = /(.*?)\.herokuapp\.com/.match(request.host)
  dashboard_url << "apps/#{match[1]}/resources" if match && match[1]
  redirect to(dashboard_url)
end
