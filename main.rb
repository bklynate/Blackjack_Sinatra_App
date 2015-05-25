require 'rubygems'
require 'sinatra'
require 'pry'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => '19874310BKLYN'

get '/' do  
  erb :set_name
end

get '/form' do
  erb :form
end

post '/set_name' do
  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/game' do
  session[:player_cards] = []
  session[:suits] = ["Clubs :","Diamonds :","Spades :","Hearts :"]
  session[:card_values] = [2,3,4,5,6,7,8,9,10,"King","Queen","Jack","Ace"]

  session[:deck] = session[:suits].product(session[:card_values])
  session[:deck].shuffle!
  session[:player_cards] << session[:deck].pop 
  erb :game
end
