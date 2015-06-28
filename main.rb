require 'rubygems'
require 'sinatra'
require 'pry'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => '19874310BKLYN'

BLACKJACK = 21
DEALER_MIN_HIT_REQUIREMENTS = 17

before do
  @show_hit_and_stay = true
  @show_dealer_information = false
  @show_dealer_hit_button = false
  @show_play_again = false
end

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

    #-corrects the issue with Aces
    arr.select { |value| value == 'A'}.count.times do
      total -= 10 if total > BLACKJACK
    end

    total
  end

  #-display card images in the browser
  def card_image(card)
    suit = case card[0]
      when 'H' then 'hearts'
      when 'S' then 'spades'
      when 'C' then 'clubs'
      when 'D' then 'diamonds'
    end

    value = card[1]
    if ['J','Q','K','A'].include?(value)
      value = case card[1]
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'A' then 'ace'
        when 'K' then 'king'
      end
    end

    "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
  end

  def hidden_dealer_card
    "<img src='/images/cards/cover.jpg' class='card_image'>"
  end

  def who_won?(player_total,dealer_total)
    if dealer_total > player_total 
      loser!("Dealer has won, better luck next time!")
    elsif dealer_total < player_total 
      winner!("#{session[:username].downcase} has won!!")
    elsif dealer_total == player_total
      tie!("No one truly wins in a time, play again for a win!!") 
    end
  end

  def blackjack?
    if hand_value(session[:dealer_cards]) == BLACKJACK
      @show_dealer_information = true
      loser!("DEALER HAS HIT BLACKJACK!!")
    end
    if hand_value(session[:player_cards]) == BLACKJACK
      winner!("BLACKJACK, #{session[:username]} HAS WON!!")
    end
  end

  def winner!(msg)
    @show_play_again = true
    @show_hit_and_stay = false
    @show_dealer_hit_button = false
    @success = "<strong>#{session[:username]} wins!</strong> #{msg}"
    session[:player_money] += session[:bet]
  end

  def loser!(msg)
    @show_play_again = true
    @show_hit_and_stay = false
    @show_dealer_hit_button = false
    @error = "<strong>#{session[:username]} loses.</strong> #{msg}"
    session[:player_money] -= session[:bet]
  end

  def tie!(msg)
    @show_play_again = true
    @show_hit_and_stay = false
    @show_dealer_hit_button = false
    @success = "<strong>It's a tie!</strong> #{msg}"
  end
end

get '/' do
  if session[:username] && session[:bet]
    redirect '/game'
  else  
    redirect '/username'
  end
end

get '/username' do
  erb :form
end

post '/username' do
  session[:player_money] = 1000
  session[:username] = params[:username]
  if session[:username].empty?
    @error = "<strong>Please provide your name..</strong>"
  elsif session[:username].to_i > 0
    @error = "<strong>No numbers allowed in this field</strong>"
  elsif session[:username].length > 13
    @error = "<strong>Too many characters..</strong>"
  else
    session[:username] = params[:username].capitalize
    redirect '/bet'
  end

  erb :form
end

get '/bet' do
  if session[:player_money] == 0
    @error = "Looks like you are out of money... <a href='/username'>start over</a>"
  end

  erb :bet
end

post '/bet' do
  session[:bet] = params[:bet].to_i

  if session[:bet].to_i == 0 || session[:bet] < 0
    @error = "Please, input a whole number integer"
    halt erb(:bet)
  elsif session[:bet] > session[:player_money]
    @error = "You can't bet more than what's in your wallet."
    halt erb(:bet)
  end

  redirect '/game'
end

post '/hit' do 
  session[:player_cards] << session[:deck].pop
  player_total = hand_value(session[:player_cards])

  if player_total > BLACKJACK
    loser!("Awww shucks #{session[:username].downcase} you busted - You Lose.")
  end

  if player_total == BLACKJACK
    winner!("#{session[:username].downcase }has hit '21' - YOU WIN!!")
  end

  erb :game
end

post '/stay' do
  @success = 'You have chosen to stay.'
  redirect '/dealer_turn'
end

get '/dealer_turn' do
  @show_dealer_information = true
  @show_hit_and_stay = false
  dealer_total = hand_value(session[:dealer_cards])
  player_total = hand_value(session[:player_cards])
  
  blackjack?

  if dealer_total > BLACKJACK
    winner!('The dealer has busted!')
  elsif dealer_total >= DEALER_MIN_HIT_REQUIREMENTS
    @show_hit_and_stay = false
    @show_dealer_hit_button = false
    redirect '/who_won'
  elsif dealer_total < DEALER_MIN_HIT_REQUIREMENTS
    redirect '/dealer_hit'
  end

  erb :game
end

get '/who_won' do
  @show_dealer_information = true
  dealer_total = hand_value(session[:dealer_cards])
  player_total = hand_value(session[:player_cards])
  who_won?(player_total,dealer_total)
  @show_play_again = true
  erb :game
end


get '/dealer_hit' do
  @show_dealer_information = true
  @show_dealer_hit_button = true
  @show_hit_and_stay = false
  erb :game
end

post '/dealer_hit' do
    session[:dealer_cards] << session[:deck].pop
    redirect '/dealer_turn'
    erb :game
end  

post '/play_again' do
  @show_play_again = true
  redirect '/bet'
end

get '/game' do
  session[:player_cards] = []
  session[:dealer_cards] = []
  
  suits = ['C','D','S','H']
  card_values = [2,3,4,5,6,7,8,9,10,'K','Q','J','A']
  
  session[:deck] = suits.product(card_values).shuffle!

  2.times do
    session[:player_cards] << session[:deck].pop
    session[:dealer_cards] << session[:deck].pop
  end

  blackjack?
  
  erb :game
end