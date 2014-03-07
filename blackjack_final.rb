NUMBERCARDS = ["2","3","4","5","6","7","8","9","10"]
FACECARDS = ["J", "K", "Q", "A"]

#Class representing a card to be used in the game
class Card
	#only allow the card to be seen
	attr_reader :card_number, :hidden
	def initialize(card_number, hidden = false)
		@card_number = card_number
		@hidden = hidden
	end

	def to_s
		if @hidden
			return "Card hidden"
		end
		@card_number
	end

	def value
		#this will allow splitting of two aces or an ace and a 1.
		if @card_number == "A"
			return 1
		elsif FACECARDS.include? (@card_number)
			return 10
		else
			return @card_number.to_i
		end
	end

	def unhide
		@hidden = false
	end
end


#Class representing a player's hand. A player can have more than one hand if he splits.
#A hand is made up of many cards.
class Hand
	attr_accessor :current_value, :cards, :bust, :bet, :has_ace, :value_without_ace, :number_of_aces
	def initialize
		@current_value = 0
		@cards = Array.new
		@bust = false
		@bet = 0.00
		@has_ace = false
		@value_without_ace = 0
		@number_of_aces = 0
	end

	def hit(card_number, hidden = false)
		@cards.push(Card.new(card_number, hidden))
		if !@value_without_ace or !@current_value or !@number_of_aces
			@value_without_ace = 0
			@current_value = 0
			@number_of_aces = 0
		end
		if card_number == "A"
			@has_ace = true
			@number_of_aces += 1
		else
			if NUMBERCARDS.include? (card_number)
				@value_without_ace += card_number.to_i
			else
				@value_without_ace += 10
			end
		end
		@current_value = @value_without_ace
		if @has_ace
			i = 0
			while i < @number_of_aces
				if @current_value + 11 > 21
					@current_value += 1
				else
					@current_value += 11
				end
				i += 1
			end
		end
		if @current_value > 21
			@bust = true
		end
	end

	def get_cards(player_number, hand)
		print "Player #{player_number}'s current cards for hand #{hand} are: "
		@cards.each do |c|
			print "#{c.card_number} "
		end
		puts "With a value of #{@current_value}"
	end

	def was_split(card_number)
		@current_value = 0
		@cards = Array.new
		@has_ace = false
		@value_without_ace = 0
		@number_of_aces = 0
		hit(card_number)
	end
end

#A class representing a player. Each game has a certain number of players.
class Player
	#only allow the player number and amount of money to be read
	attr_reader :player_number, :money, :cards, :bet, :hands, :initial_bet
	def initialize(player_number)
		@player_number = player_number
		@money = 1000.00
		@cards = Array.new
		@bust = false
		@bet = 0.00
		@has_ace = false
		@value_without_ace = 0
		@number_of_aces = 0
		@hands = Array.new
		@hands.push(Hand.new)
		@initial_bet = 0
	end

	def hit(card_number, hand = 0, hidden = false)
		if !@hands[hand]
			@hands[hand] = Hand.new
		end
		@hands[hand].hit(card_number, hidden)
	end

	def first_hit(card1_number, card2_number)
		hit(card1_number)
		hit(card2_number)
	end

	def get_cards(hand = 0)
		if @hands.length > 1
			@hands[hand].get_cards(@player_number, hand)
		else
			print "Player #{@player_number}'s current cards are: "
			@hands[0].cards.each do |c|
				print "#{c} "
			end
			puts "With a value of #{@hands[0].current_value}"
		end
	end

	def place_bet(bet, hand = 0)
		if (bet > @money || bet < 0.1)
			return false
		else
			if @initial_bet == 0
				@initial_bet = bet
			end
			@hands[hand].bet += bet
			@money -= bet
			return true
		end
	end

	def reset
		@cards = Array.new
		@bust = false
		@bet = 0.0
		@contains_ace = false
		@value_without_ace = 0
		@number_of_aces = 0
		@hands = Array.new
		@hands.push(Hand.new)
		@initial_bet = 0
	end

	def win(hand = 0)
		@money += @hands[hand].bet * 2
		if number_of_hands > 1
			puts "Player #{@player_number} won on hand #{hand}!"
		else
			puts "Player #{@player_number} won!"
		end
	end

	def lose(hand = 0)
		if number_of_hands > 1
			puts "Player #{@player_number} lost on hand #{hand}!"
		else
			puts "Player #{@player_number} lost!"
		end
	end

	def push(hand = 0)
		@money += @hands[hand].bet
		if number_of_hands > 1
			puts "Player #{@player_number} pushed on hand #{hand}!"
		else
			puts "Player #{@player_number} pushed!"
		end
	end

	def win_blackjack
		@money += @hands[0].bet*2.5
		puts "Player #{@player_number} won!"
	end

	def is_broke?
		if @money < 0.1
			return true
		else
			return false
		end
	end

	def has_natural?
		if number_of_hands == 1 and @hands[0].current_value == 21 and cards_in_hand(0) == 2
			return true
		end
	end

	def has_21?(hand = 0)
		if @hands[hand].current_value == 21 and @hands[hand].cards.length > 2
			return true
		end
	end

	def can_split?(hand = 0)
		if @hands[hand].cards.length == 2
			if @hands[hand].cards[0].value == @hands[hand].cards[1].value and @money >= @initial_bet
				return true
			end
		end
		return false
	end

	def split(hand)
		new_hand = Hand.new
		new_hand.bet = @initial_bet
		@money -= @initial_bet
		new_hand.hit(@hands[hand].cards.pop.card_number)
		@hands.push(new_hand)
		new_hand2 = Hand.new
		new_hand2.hit(@hands[hand].cards.pop.card_number)
		@hands[hand] = new_hand2
	end

	def number_of_hands
		return @hands.length
	end

	def current_value(hand)
		return @hands[hand].current_value
	end

	def bust(hand)
		return @hands[hand].bust
	end

	def cards_in_hand(hand)
		return @hands[hand].cards.length
	end

	def has_money
		puts "Player #{player_number}'s current money is now #{@money}"
	end

end

#Class representing the dealer - the dealer is a special type of player and so
#inherits from the Player class.
class Dealer < Player
	attr_reader :current_value, :bust
	def initialize()
		@player_number = 0
		@cards = Array.new
		@current_value
	end
	def hit(card_number, hidden = false, hand = 0)
		@cards.push(Card.new(card_number, hidden))
		# #This statement exists because @current_value, @value_without_ace and
		# #number of aces were undefined otherwise.
		if !@value_without_ace or !@current_value or !@number_of_aces
			@value_without_ace = 0
			@current_value = 0
			@number_of_aces = 0
		end
		if card_number == "A"
			@has_ace = true
			@number_of_aces += 1
		else
			if NUMBERCARDS.include? (card_number)
				@value_without_ace += card_number.to_i
			else
				@value_without_ace += 10
			end
		end
		@current_value = @value_without_ace
		if @has_ace
			i = 0
			while i < @number_of_aces
				if @current_value + 11 > 21
					@current_value += 1
				else
					@current_value += 11
				end
				i += 1
			end
		end
		if @current_value > 21
			@bust = true
		end
	end
	def first_hit(card1_number, card2_number)
		hit(card1_number, true)
		hit(card2_number)
	end
	def get_cards
		puts "Dealer's current cards are: "
		@cards.each do |c|
			print "#{c} "
		end
		puts
		puts "With a value of #{@current_value}"
	end
	def unhide_card
		@cards.each do |c|
			if c.hidden
				c.unhide
				return
			end
		end
	end
	def has_natural?
		if @cards.length == 2 and @current_value == 21
			return true
		else
			return false
		end
	end
end


#A class representing the actual game - when it is initialized, the game begins.
#The game ends when all of the players quit or run out of money.
class Game

	def initialize

		@numplayers = 0
		get_num_players
		@players = Array.new
		(1..@numplayers).each do |i|
			@player = Player.new(i)
			@players.push(@player)
		end
		@dealer = Dealer.new

		@deck = Array.new
		add_cards

		while !(@players.empty?)
			get_all_bets
			first_round
			player_cards
			dealer_cards
			all_player_turns
			dealer_turn
			evaluate_game
			play_or_quit
		end
		puts "Game over!"
	end


	def get_num_players
		players_valid = false
		while !players_valid do
			puts "Input the number of players"
			@numplayers = gets.to_i
			if @numplayers <= 0
				puts "Error! Please enter a number of players higher than 0"
			else
				players_valid = true
				return
			end
		end
	end


	def add_cards
		(4*(@numplayers)).times do
			@deck += NUMBERCARDS
			@deck += FACECARDS
		end
		@deck.shuffle!
	end


	def get_all_bets
		@players.each do |p|
			bet(p)
		end
	end

	def bet(player, hand = 0)
		while true
			puts "Player #{player.player_number}, your current money is #{player.money}. Please enter a bet"
			bet = gets.to_f
			if (player.place_bet(bet, hand))
				puts "You bet #{player.hands[hand].bet}. Your current money is #{player.money}."
				break
			end
			puts "Enter a valid bet."
		end
	end

	def first_round
		@dealer.first_hit(@deck.pop, @deck.pop)
		@players.each do |p|
			p.first_hit(@deck.pop, @deck.pop)
		end
	end

	def player_cards(hand = 0)
		@players.each do |p|
			p.get_cards(hand)
		end
	end

	def dealer_cards
		print "Dealer has: "
		@dealer.cards.each do |c|
			print "#{c} "
		end
		puts""
	end

	def all_player_turns
		@players.each do |p|
			player_turn(p)
		end
	end

	def player_turn (player, hand = 0)
		if (hand >= player.number_of_hands)
			return
		end
		puts "Player #{player.player_number}'s turn"
		player.get_cards(hand)
		if player.has_natural?
			puts "Contratulations! Blackjack."
			return
		end

		if split(player, hand)
			return
		end

		if double_down(player, hand)
			return
		end

		while true
			puts "Enter hit to hit or stay to stay"
			move = gets.chomp
			if move == "hit"
				if hit(player, hand)
					break
				end
				if split(player, hand)
					return
				end

				if double_down(player, hand)
					return
				end
			elsif move == "stay"
				puts "You stayed at score #{player.current_value(hand)}"
				break
			end
		end
		player_turn(player, hand + 1)
	end

	def hit(player, hand)
		card = @deck.pop
		puts "You got #{card}!"
		player.hit(card, hand)
		puts "Your new score is #{player.current_value(hand)}"
		if player.has_21?(hand)
			return true
		end
		if @deck.size < 21
			add_cards
		end
		if player.bust(hand)
			puts "Bust!"
			return true
		end
		return false
	end

	def split(player, hand)
		if player.can_split?(hand)
			puts "Type split to split or anything else to continue"
			split = gets.chomp
			if split == "split"
				player.split(hand)
				player_turn(player, hand)
				return true
			end
		end
	end

	def double_down(player, hand)
		if player.cards_in_hand(hand) != 2
			return
		end
		puts "Type yes to double down or anything else to continue."
		choice = gets.chomp
		if choice == "yes"
			while true
				puts "How much more do you want to bet? Maximum of #{[player.initial_bet, player.money].min}."
				second_bet = gets.to_f
				if second_bet <= player.initial_bet and second_bet >= 0 and second_bet <= player.money
					player.place_bet(second_bet, hand)
					hit(player, hand)
					player_turn(player, hand + 1)
					return true
				end
				puts "Please enter a valid bet!"
			end
		end
	end


	def dealer_turn
		@dealer.unhide_card
		@dealer.get_cards
		if @dealer.has_natural?
			puts "Dealer has blackjack!"
			return
		end
		while @dealer.current_value < 17
			card = @deck.pop
			puts "Dealer hit and got #{card}!"
			@dealer.hit(card)
			@dealer.get_cards
			if @dealer.bust
				puts "Bust!"
			end
		end
	end

	def evaluate_game
		broke_players = Array.new
		if @dealer.bust
			@players.each do |p|
				for hand in 0..p.number_of_hands - 1
					if p.has_natural?
						p.win_blackjack
					elsif !p.bust(hand)
						p.win(hand)
					else
						p.lose(hand)
					end
					if p.is_broke?
						broke_players.push(p)
					end
				end
			end
		else
			@players.each do |p|
				for hand in 0..p.number_of_hands - 1
					if p.bust(hand)
						p.lose(hand)
					elsif p.has_natural?
						if @dealer.has_natural?
							p.push(hand)
						else
							p.win_blackjack
						end
					elsif p.current_value(hand) > @dealer.current_value
						p.win(hand)
					else 
						p.lose(hand)
					end
					if p.is_broke?
						broke_players.push(p)
					end
				end
			end
		end
		@dealer.reset
		@players -= broke_players
		@players.each do |p|
			p.has_money
		end
	end

	def play_or_quit
		quitters = Array.new
		@players.each do |p|
			puts "Player #{p.player_number}, type any key to keep playing or quit to quit"
			option = gets.chomp
			if option == "quit"
				puts "Bye!"
				quitters.push(p)
			else
				p.reset
			end
		end
		@players -= quitters
	end

end

#starts the game.
game = Game.new
