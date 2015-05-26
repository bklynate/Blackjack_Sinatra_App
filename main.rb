require 'rubygems'
require 'sinatra'
require 'pry'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => '19874310BKLYN'

get '/' do
  if session[:username]
    redirect '/game'
  else  
    redirect '/form'
  end
end

get '/form' do
  erb :form
end

post '/form' do
  session[:username] = params[:username]
  redirect '/game'
end

post '/hit' do
  new_card = session[:deck].pop 
  session[:player_cards] << new_card
  erb :game
end


get '/game' do
  session[:player_cards] = []
  session[:dealer_cards] = []
  suits = ["Clubs :","Diamonds :","Spades :","Hearts :"]
  card_values = [2,3,4,5,6,7,8,9,10,"King","Queen","Jack","Ace"]
  session[:deck] = suits.product(card_values).shuffle!
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  erb :game
end
