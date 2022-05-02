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
              if !@token_up_for_bid
                @game.ndem_acting_player = @remaining_choosers[0]
                return %w[remove_token pass]
              elsif @auction_winner
                return %w[merge]
              elsif @current_high_bidder
                return %w[bid pass]
              else
                return %w[bid]
              end

            end
            ACTIONS
          end

          def setup
            return if current_entity != @game.ndem

            # Don't need to make sure NdeM has tokens.  It starts with one.
            @available_ndem_tokens = @game.ndem.tokens.select(&:used).to_h { |t| [t, ndem_token_cost(t)] }
            @token_up_for_bid = nil
            @player_step_order = @game.players.dup
            @remaining_choosers = @player_step_order.select { |p| player_can_purchase_any_token?(p) }
          end

          def ndem_closing?
            @game.ndem_state == :closing && current_entity == @game.ndem
          end

          def active?
            ndem_closing? && !@remaining_choosers.empty?
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
            !token.city.tokened_by?(corporation)
          end

          def player_can_purchase_token?(player, token)
            player.presidencies.any? { |c| corp_can_purchase_token?(c, token) }
          end

          def player_can_purchase_any_token?(player)
            @available_ndem_tokens.keys.any? { |t| player_can_purchase_token?(player, t) }
          end

          def process_pass(action)
            if !@token_up_for_bid
              process_pass_remove_token(action)
            else
              process_pass_bid(action)
            end
          end

          def pass_description
            return 'Pass (choose token)' unless @token_up_for_bid

            'Pass (bid on token)'
          end

          def help
            return 'Select NDEM token to auction' unless @token_up_for_bid
            return "Bidding for NDEM token at #{@token_up_for_bid.city.hex.id}" unless @auction_winner

            'Choose company to buy NDEM token'
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

          def process_pass_remove_token(_action)
            @log << "#{@remaining_choosers[0].name} passes picking an NDEM token to auction"
            @remaining_choosers.shift
            return unless @remaining_choosers.empty?

            # MHA other case for this - no valid bidders
            @game.ndem_state = :closed
            @log << "#{@game.ndem.name} closes"
            @game.ndem.close!
          end

          def process_remove_token(action)
            @token_up_for_bid = action.city.tokens[action.slot]
            unless player_can_purchase_token?(@remaining_choosers[0], @token_up_for_bid)
              raise GameError, "#{@remaining_choosers} does not have a company that can purchase token at #{action.city.hex.id}"
            end

            # MHA - check to make sure this player can purchase this token
            @game.log << "#{@remaining_choosers[0].name} has chosen NDEM token at #{action.city.hex.id} for auction"
            @remaining_bidders = get_player_list(start_player: @remaining_choosers[0])
            @remaining_bidders.select! { |p| player_can_purchase_token?(p, @token_up_for_bid) }
            @current_high_bid = 0
            @current_high_bidder = nil
            @auction_winner = nil
          end

          def max_player_bid(_player)
            print("max_player_bid:#{max_bid_for_token(@remaining_bidders[0])}")
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
            @remaining_bidders.select! { |p| player_can_purchase_token?(p, @token_up_for_bid) }
            @game.ndem_acting_player = @remaining_bidders[0] unless @remaining_bidders.empty?
            check_auction_over
          end

          def process_pass_bid(_action)
            @log << "#{@remaining_bidders[0].name} passes"
            @remaining_bidders.shift
            @game.ndem_acting_player = @remaining_bidders[0]
            check_auction_over
          end

          def check_auction_over
            return if @remaining_bidders.size > 1
            return if @remaining_bidders.size == 1 && @remaining_bidders[0] != @current_high_bidder

            @log << "#{@current_high_bidder.name} wins the auction"
            @auction_winner = @current_high_bidder
            @game.ndem_acting_player = @auction_winner
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
            @player_step_order.append(@player_step_order.shift)
            @remaining_choosers = @player_step_order.select { |p| player_can_purchase_any_token?(p) }
          end

          def auto_actions(entity)
            print("auto_actions:#{entity}")
            print('have auto_auction complete step') if @remaining_choosers.empty?
          end
        end
      end
    end
  end
end
