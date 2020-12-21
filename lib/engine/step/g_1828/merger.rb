# frozen_string_literal: true

require_relative '../base'
require_relative '../../token'
require_relative '../../g_1828/system'
require_relative '../../share_holder'

module Engine
  module Step
    module G1828
      class Merger < Base
        MERGE_ACTIONS = %w[merge].freeze
        CHOOSE_ACTIONS = %w[choose].freeze
        MERGE_STATES = %i[select_target exchange_pairs exchange_singles merge_failed].freeze

        def actions(_entity)
          return [] unless merge_in_progress?

          @state == :select_target ? MERGE_ACTIONS : CHOOSE_ACTIONS
        end

        def description
          "Select a corporation to merge with #{merging_corporation.name}"
        end

        def blocks?
          merge_in_progress?
        end

        def merge_in_progress?
          merging_corporation
        end

        def process_merge(action)
          @target = action.corporation
          @game.game_error('Invalid action') unless @state == :select_target
          @game.game_error('Wrong company') unless action.entity == merging_corporation
          unless mergeable_entities.include?(@target)
            @game.game_error("Unable to merge #{merging_corporation.name} with #{action.corporation.name}")
          end

          merge_corporations
        end

        def process_choose(action); end

        def merge_name
          'Merge'
        end

        def mergeable_type(corporation)
          "Corporations that can merge with #{corporation.name}"
        end

        def merging_corporation
          @state = :select_target if !@state && @round.merging_corporation
          @round.merging_corporation
        end

        def choice_name
          'Select player'
        end

        def choices
          @players.map(&:name)
        end

        def show_other_players
          false
        end

        def active_entities
          return [] unless merge_in_progress?

          @state == :select_target ? [@round.acting_player] : [@players.first]
        end

        def round_state
          {
            merging_corporation: nil,
            acting_player: nil,
          }
        end

        private

        class ShareHolderEntity
          include Engine::ShareHolder
        end

        def mergeable_entities(entity = @round.acting_player, corporation = merging_corporation)
          return [] if corporation.owner != entity

          @game.corporations.select do |candidate|
            next if candidate == corporation ||
                    !candidate.ipoed ||
                    candidate.operated? != corporation.operated? ||
                    (!candidate.floated? && !corporation.floated?)

            # Mergeable not possible unless a player owns 5+ shares between the corporations
            @game.players.any? do |player|
              num_shares = player.num_shares_of(candidate) + player.num_shares_of(corporation)
              num_shares >= 6 ||
                (num_shares == 5 && !did_sell?(player, candidate) && !did_sell?(player, corporation))
            end
          end
        end

        def merge_corporations
          if @state == :select_target
            create_share_cache
            combine_assets
            setup_exchange_pairs_state
          end

          if @state == :exchange_pairs
            return
            while @players.any?
              exchange_pairs(@players.first)
              break if @player_action_required

              @players.shift!
            end
            setup_exchange_singles_state if @players.empty?
          end

          if @state == :exchange_single
            while @players.any?
              exchange_singles(@players.first)
              break if @player_action_required

              @players.shift!
            end

            complete_merge if @players.empty?
          end
        end

        def setup_exchange_pairs_state
          @state = :exchange_pairs
          @players = @round.entities.rotate(@round.entities.index(@round.acting_player))
        end

        def setup_exchange_singles_state
          @state = :exchange_singles
          @players = @round.entities.rotate(@round.entities.index(@round.acting_player))
          @players.rotate!
        end

        def reset_merge_state
          @state = nil
          @round.merging_corporation = nil
          @round.acting_player = nil
        end

        def create_share_cache
          @discard = ShareHolderEntity.new

          @shares = {}
          add_corporation_shares_to_cache(merging_corporation)
          add_corporation_shares_to_cache(@target)
        end

        def add_corporation_shares_to_cache(corporation)
          cache = {}

          @game.players.each { |p| cache[p] = p.num_shares_of(corporation) }
          cache[corporation] = corporation.num_shares_of(corporation)
          cache[@game.share_pool] = @game.share_pool.num_shares_of(corporation)
          cache[@discard] = @discard.num_shares_of(corporation)

          @shares[corporation] = cache
        end

        def combine_assets
          merging_corporation.send(:extend, Engine::G1828::System)
          merging_corporation.setup
          merging_corporation.shells << @target

          #          merging_corporation.share_price = system_market_price(merging_corporation, @target)
          #          @game.stock_market.move(merging_corporation, merging_corporation.share_price.coordinates[0], merging_corporation.share_price.coordinates[1], force: true)
          @target.spend(@target.cash, merging_corporation)
          hexes_to_remove_tokens = combine_tokens(merging_corporation, @target)
          if hexes_to_remove_tokens.any?
            @round.corporation_removing_tokens = merging_corporation
            @round.hexes_to_remove_tokens = hexes_to_remove_tokens
          end

          @log << "Merging #{@target.name} into #{merging_corporation.name}. New share price is #{@game.format_currency(merging_corporation.share_price.price)}. Adding #{@game.format_currency(@target.cash)} cash, " \
                  "#{@target.trains.map(&:name).join(', ')} trains, and #{@target.tokens.size} tokens to #{merging_corporation.name}."
        end

        def system_market_price
          market = @game.stock_market.market
          share_prices = [merging_corporation.share_price, @target.share_price]
          share_values = share_prices.map(&:price).sort

          left_most_col = share_prices.min { |a, b| a.coordinates[1] <=> b.coordinates[1] }.coordinates[1]
          max_share_value = share_values[1] + (share_values[0] / 2).floor
          new_market_price = nil
          if market[0][left_most_col].price < max_share_value
            i = market[0].size - 1
            i -= 1 while market[0][i].price > max_share_value
            new_market_price = market[0][i]
          else
            i = 0
            i += 1 while market[i][left_most_col].price > max_share_value
            new_market_price = market[i][left_most_col]
          end

          new_market_price
        end

        def combine_tokens
          hexes_to_remove_tokens = []
          used, unused = (merging_corporation.tokens + @target.tokens).partition(&:used)
          merging_corporation.tokens.clear

          used.group_by { |t| t.city.hex }.each do |hex, tokens|
            if tokens.one?
              replace_token(merging_corporation, tokens.first)
            elsif tokens[0].city == tokens[1].city
              replace_token(merging_corporation, tokens.first)
              @game.place_blocking_token(hex)
            else
              tokens.each { |t| replace_token(merging_corporation, t) }
              hexes_to_remove_tokens << hex
            end
          end

          unused.each { |t| merging_corporation.tokens << Engine::Token.new(merging_corporation, price: t.price) }

          hexes_to_remove_tokens
        end

        def replace_token(corporation, token)
          new_token = Engine::Token.new(corporation, price: token.price)
          corporation.tokens << new_token
          token.swap!(new_token, check_tokenable: false)
        end
      end
    end
  end
end
