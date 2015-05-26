require 'rubygems'
require 'sinatra'
require 'pry'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => '19874310BKLYN'

helpers do
  def hand_value(cards)
    arr = cards.map{ |value| value[1] }
    total = 0

    arr.each do |value|
      if value == 'A'
        total += 11
      elsif value.to_i == 0
        total += 10
      else
        total += value
      end
    end

    arr.select { |value| value == 'A'}.count.times do
      total -= 10 if total > 21
    end

    total
  end
end

before do
  @show_hit_and_stay = true
end

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
  session[:player_cards] << session[:deck].pop
  if hand_value(session[:player_cards]) > 21
    @error = "Looks like you have busted."
    @show_hit_and_stay = false
  end
  erb :game
end

post '/stay' do
  @success = 'You have chosen to stay.'
  @show_hit_and_stay = false
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
