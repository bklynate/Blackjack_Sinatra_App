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

  def who_won?(player_total,dealer_total)
    if dealer_total > player_total 
      @error = "Dealer Wins!!"
    elsif dealer_total < player_total 
      @success = "#{player_name} Wins!!"
    elsif dealer_total == player_total
      @error = "It's a tie....."  
    end
  end

  def blackjack_at_beginning_of_game?
    if hand_value(session[:player_cards]) == 21
      @success = "#{session[:player_name]} hit blackjack! " \
                 "#{session[:player_name]} now has #{pay_winning_hand}$."
      @show_hit_or_stay_buttons = false
      @play_again = true
    end
  end
end

before do
  @show_hit_and_stay = true
  @show_dealer_information = false
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
  session[:username] = params[:username].capitalize
  redirect '/game'
end

post '/hit' do 
  session[:player_cards] << session[:deck].pop
  player_total = hand_value(session[:player_cards])
  if player_total > 21
    @error = "Looks like you have busted."
    @show_hit_and_stay = false
  end
  if player_total == 21
    @winner = "You have hit '21' - YOU WIN!!"
    @show_hit_and_stay = false
  end
  erb :game
end

post '/stay' do
  @success = 'You have chosen to stay.'
  @show_hit_and_stay = false

  if hand_value(session[:dealer_cards]) < 17
    @dealer_turn_to_play = true
  else
    who_won?(hand_value(session[:player_cards]),hand_value(session[:dealer_cards]))
  end
  erb :game
end

get '/dealer_turn' do
  @show_dealer_information = true
  dealer_total = hand_value(session[:dealer_cards])
  player_total = hand_value(session[:player_cards])
  @show_hit_or_stay_buttons = false

  if dealer_total >= 17
    @dealer_turn_to_play = false
    display_end_results(player_total, dealer_total)
  else
    @dealer_turn_to_play = true
  end

  erb :game
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
  erb :game
end