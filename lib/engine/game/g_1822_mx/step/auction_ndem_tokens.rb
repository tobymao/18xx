# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1822MX
      module Step
        class AuctionNdemTokens < Engine::Step::Base
          ACTIONS = %w[pass].freeze
          def actions(entity)
            if current_entity == entity
              return %w[remove_token pass] unless @token_up_for_bid
              return %w[merge] if @auction_winner
              return %w[bid pass] if @current_high_bidder

              return %w[bid]
            end
            ACTIONS
          end

          def setup
            return if current_entity != @game.ndem

            # Don't need to make sure NdeM has tokens.  It starts with one.
            @available_ndem_tokens = @game.ndem.tokens.select(&:used).to_h { |t| [t, ndem_token_cost(t)] }
            @player_step_order = @game.players.dup
            @token_up_for_bid = nil
            @remaining_choosers = @player_step_order.dup
          end

          def ndem_closing?
            @game.ndem_state == :closing && current_entity == @game.ndem
          end

          def active?
            ndem_closing?
          end

          def blocking?
            ndem_closing?
          end

          def description
            'NDEM Privatization'
          end

          def base_city_revenue(city)
            @game.phase.tiles.reverse_each { |color| return city.revenue[color] if city.revenue[color] }
            0
          end

          def ndem_token_cost(token)
            token.city ? [base_city_revenue(token.city), 10].max : 0
          end

          def min_player_bid
            (@current_high_bid.zero? ? ndem_token_cost(@token_up_for_bid) : @current_high_bid + min_increment)
          end

          def max_bid_for_token(player)
            corps = player.presidencies.reject { |c| @game.exchange_tokens(c).zero? }
            corp = corps.max_by(&:cash)
            corp ? corp.cash : 0
          end

          # Get the ordered player list.  If start_player is not specified, use
          # priority order.  If next_player is true, shift the starting player
          # to the end - used for getting the next person after start to act.
          def get_player_list(start_player: nil, next_player: false)
            players = @game.players.dup
            (players.append(players.shift) while players[0] != start_player) if start_player
            players.append(players.shift) if next_player
            players
          end

          def corp_can_purchase_token?(corporation, token)
            corporation.cash >= @available_ndem_tokens[token] &&
            !@game.exchange_tokens(corporation).zero? &&
            token.hex.tile.cities.none? { |c| c.tokened_by?(corporation) }
          end

          def player_can_purchase_token?(player, token)
            player.presidencies.any? { |c| corp_can_purchase_token?(c, token) }
          end

          def player_can_purchase_any_token?(player)
            @available_ndem_tokens.keys.any? { |t| player_can_purchase_token?(player, t) }
          end

          def process_pass(action)
            if @remaining_choosers.empty?
              process_pass_end_round
            elsif !@token_up_for_bid
              process_pass_remove_token
            else
              process_pass_bid(action)
            end
          end

          def pass_description
            return 'Pass (choose token)' unless @token_up_for_bid

            'Pass (bid on token)'
          end

          def help
            return "#{ndem_acting_player.name} is up to select an NDEM token to auction" unless @token_up_for_bid
            unless @auction_winner
              return "#{ndem_acting_player.name} is up to bid for the NDEM token at #{@token_up_for_bid.city.hex.id}"
            end

            "#{ndem_acting_player.name} is choosing a company to buy NDEM token"
          end

          # Remove token methods
          def available_hex(entity, hex)
            return false unless entity == @game.ndem

            @game.ndem.tokens.each do |t|
              return true if t.city && t.city.hex == hex
            end
            false
          end

          def can_replace_token?(_entity, token)
            return false unless token

            @game.ndem.tokens.include?(token)
          end

          def process_pass_remove_token
            @log << "#{@remaining_choosers[0].name} passes picking an NDEM token to auction"
            @remaining_choosers.shift
          end

          def process_pass_end_round
            @game.ndem_state = :closed
            @log << "#{@game.ndem.name} closes"
            @game.ndem.close!
          end

          def process_remove_token(action)
            unless player_can_purchase_token?(@remaining_choosers[0], action.city.tokens[action.slot])
              raise GameError,
                    "#{@remaining_choosers[0].name} does not have a company that can purchase a token at #{action.city.hex.id}"
            end

            @token_up_for_bid = action.city.tokens[action.slot]

            @game.log << "#{@remaining_choosers[0].name} has chosen NDEM token at #{action.city.hex.id} for auction"
            @remaining_bidders = get_player_list(start_player: @remaining_choosers[0])
            @current_high_bid = 0
            @current_high_bidder = nil
            @auction_winner = nil
          end

          def max_player_bid(_player)
            max_bid_for_token(@remaining_bidders[0])
          end

          def min_increment
            10
          end

          def available
            [@game.ndem]
          end

          def auctioning
            :turn
          end

          def visible?
            true
          end

          def players_visible?
            true
          end

          def committed_cash(_player, _show_hidden = false)
            0
          end

          def process_bid(action)
            raise GameError, "Minimum bid is #{min_player_bid}" if action.price < min_player_bid

            if action.price > max_bid_for_token(@remaining_bidders[0])
              raise GameError,
                    "#{@remaining_choosers[0].name} can bid a maximum of " \
                    "#{@game.format_currency(max_bid_for_token(@remaining_bidders[0]))}"
            elsif action.price % min_increment != 0
              raise GameError, "Bids must be in increments of #{@game.format_currency(min_increment)}"
            end

            @log << "#{@remaining_bidders[0].name} bids #{@game.format_currency(action.price)}"
            @current_high_bid = action.price
            @available_ndem_tokens[@token_up_for_bid] = @current_high_bid + min_increment
            @current_high_bidder = @remaining_bidders[0]
            @remaining_bidders.append(@remaining_bidders.shift)
            check_auction_over
          end

          def process_pass_bid(_action)
            @log << "#{@remaining_bidders[0].name} passes"
            @remaining_bidders.shift
            check_auction_over
          end

          def auction_over?
            @remaining_bidders.size.zero? || (@remaining_bidders.size == 1 && @remaining_bidders[0] == @current_high_bidder)
          end

          def check_auction_over
            return unless auction_over?

            @log << "#{@current_high_bidder.name} wins the auction"
            @auction_winner = @current_high_bidder
          end

          def merge_name(_entity = nil)
            'Choose'
          end

          def mergeable(_corporation)
            @auction_winner.presidencies.select { |c| !@game.exchange_tokens(c).zero? && c.cash >= @current_high_bid }
          end

          def show_other_players
            true
          end

          def buyer
            @auction_winner
          end

          def process_merge(action)
            @log << "#{action.corporation.id} buys NDEM token for #{@game.format_currency(@current_high_bid)}"

            ndem_city = @token_up_for_bid.city
            @token_up_for_bid.remove!
            @game.remove_exchange_token(action.corporation)
            token = Engine::Token.new(action.corporation)
            action.corporation.tokens << token
            ndem_city.place_token(action.corporation, token, check_tokenable: false)
            action.corporation.spend(@current_high_bid, @game.bank)
            @game.graph.clear

            @available_ndem_tokens.delete(@token_up_for_bid)
            @token_up_for_bid = nil
            @auction_winner = nil
            @player_step_order.append(@player_step_order.shift)
            @remaining_choosers = @player_step_order.dup
          end

          def auto_actions(entity)
            # Pass under the following conditions:
            # - There are no players left to choose a token for auction
            # - There is no token up for bid, and the current chooser cannot purchase any remaining tokens
            # - There is a token up for bid, the next bidder cannot purchase it, but the auction is not over
            if @remaining_choosers.empty? ||
              (!@token_up_for_bid && !player_can_purchase_any_token?(@remaining_choosers[0])) ||
              (@token_up_for_bid && !player_can_purchase_token?(@remaining_bidders[0], @token_up_for_bid) && !auction_over?)
              [Engine::Action::Pass.new(entity)]
            end
          end

          def ndem_acting_player
            return @auction_winner if @auction_winner
            return @remaining_bidders[0] if @token_up_for_bid

            @remaining_choosers[0]
          end
        end
      end
    end
  end
end
