# frozen_string_literal: true

require_relative '../base'
require_relative '../../token'
require_relative '../../entity'
require_relative '../../share_holder'
require_relative '../../g_1828/system'

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
          if @player_choice
            @player_choice.step_description
          else
            "Select a corporation to merge with #{merging_corporation.name}"
          end
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
          unless mergeable_entities(@round.acting_player, merging_corporation).include?(@target)
            @game.game_error("Unable to merge #{merging_corporation.name} with #{action.corporation.name}")
          end

          @merger = merging_corporation
          merge_corporations
        end

        def process_choose(action)
          @game.game_error('Invalid action') unless @player_choice
          @game.game_error('Not your turn') unless action.entity == @players.first
          @game.game_error('Invalid choice') unless @player_choice.choices.include?(action.choice)

          @player_selection = action.choice
          @player_choice = nil
          merge_corporations
        end

        def merge_name
          'Merge'
        end

        def mergeable_type(corporation)
          "Corporations that can merge with #{corporation.name}"
        end

        def merging_corporation
          @state = :select_target if !@state && @round.merging_corporation
          @system || @round.merging_corporation
        end

        def choice_name
          @player_choice ? @player_choice.choice_description : 'And so here we are'
        end

        def choices
          @player_choice ? @player_choice.choices : ['DONE']
        end

        def show_other_players
          false
        end

        def active_entities
          merge_corporations if @state == :token_removal
          return [] unless merge_in_progress?

          @state == :select_target ? [@round.acting_player] : [@players.first]
        end

        def round_state
          {
            merging_corporation: nil,
            acting_player: nil,
          }
        end

        def setup
          @discard = ShareHolderEntity.new
          @used = ShareHolderEntity.new
        end

        private

        class PlayerChoice
          attr_accessor :step_description, :choice_description, :choices

          def initialize(step_description:, choice_description:, choices:)
            @step_description = step_description
            @choice_description = choice_description
            @choices = choices
          end
        end

        class ShareHolderEntity
          include Engine::Entity
          include Engine::ShareHolder
        end

        def corporations
          [@merger, @target]
        end

        def mergeable_entities(entity = @round.acting_player, corporation = @round.merging_corporation)
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
            create_system
            @round.corporation_removing_tokens ? setup_token_removal_state : setup_exchange_pairs_state
          end

          setup_exchange_pairs_state if @state == :token_removal && !@round.corporation_removing_tokens

          if @state == :exchange_pairs
            @players.each do |p|
              if (share = p.shares_of(@merger).find(&:president))
                share.transfer(@used)
              end
              if (share = p.shares_of(@target).find(&:president))
                share.transfer(@used)
              end
            end
            while @players.any?
              exchange_pairs(@players.first)
              return if @player_choice

              @players.shift
            end
            setup_exchange_singles_state
          end

          if @state == :exchange_singles
            while @players.any?
              exchange_singles(@players.first)
              return if @player_choice

              @players.shift
            end
            @state = :complete_merger
          end

          if @state == :complete_merger
            exchange_unowned_shares(@game.share_pool)
            exchange_unowned_shares(@merger)
            exchange_discarded_shares
            complete_merger
          end
        end

        def setup_token_removal_state
          @state = :token_removal
        end

        def setup_exchange_pairs_state
          @state = :exchange_pairs
          @players = @round.entities.rotate(@round.entities.index(@round.acting_player))
        end

        def setup_exchange_singles_state
          @state = :exchange_singles
          @players = @round.entities.rotate(@round.entities.index(@round.acting_player) + 1)
        end

        def reset_merge_state
          @state = nil
          @merger = nil
          @target = nil
          @players = nil
          @system = nil
          @round.merging_corporation = nil
          @round.acting_player = nil
        end

        def create_system
          @system = @game.create_system(corporations)
          if (hexes = @system.tokens.select(&:used).group_by { |t| t.city.tile.hex }.select { |_k, v| v.size > 1 }.keys)
            @round.corporation_removing_tokens = @system
            @round.hexes_to_remove_tokens = hexes
          end

          @log << "Merging #{@target.name} into #{@merger.name}. #{@merger.name} " \
                  "receives #{@game.format_currency(@target.cash)} cash, " \
                  "trains (#{@target.trains.map(&:name).join(', ')}), and tokens (#{@target.tokens.size}). " \
                  "New share price is #{@game.format_currency(@merger.share_price.price)}. "
        end

        def exchange_pairs(player)
          num_shares = ->(corp) { player.num_shares_of(corp) }
          total_shares = num_shares[@merger] + num_shares[@target]
          return unless total_shares >= 2

          hide_odd_share(player)
          return if @player_choice

          if num_shares[@merger].positive?
            corps = [@merger] << (num_shares[@target].positive? ? @target : @merger)
            exchange_pair(player, corps, player)
          elsif @discard.num_shares_of(@merger).positive?
            exchange_pair(player, [@target, @target], @discard)
          elsif (players = @players.select { |p| p.num_shares_of(@merger).positive? }).any?
            if players.size > 1 && !@player_selection
              @player_choice = PlayerChoice.new(step_description: 'Choose which player to trade for system share',
                                                choice_description: 'Choose player',
                                                choices: players.map(&:name))
              return
            end
            @player_selection = players.find { |p| p.name == @player_selection } || players.first
            trade_share(player, @target, @player_selection, @merger)
            @player_selection = nil
            exchange_pair(player, [@merger, @target], player)
          elsif @merger.num_shares_of(@merger).positive?
            exchange_pair(player, [@target, @target], @merger)
          else
            exchange_pair(player, [@target, @target], @game.share_pool)
          end

          exchange_pairs(player) if num_shares[@merger].positive? || num_shares[@target].positive?

          restore_odd_share(player)
        end

        def hide_odd_share(player)
          num_shares = ->(corp) { player.num_shares_of(corp) }
          total_shares = num_shares[@merger] + num_shares[@target]
          return unless total_shares.odd?

          num_system_shares = total_shares / 2
          if @player_selection
            @odd_share = player.shares_of(@game.corporations.find { |c| c.name == @player_selection }).first
            @player_selection = nil
          elsif num_shares[@merger] > num_system_shares && num_shares[@target].positive?
            @player_choice = PlayerChoice.new(step_description: 'Choose which share to keep after pairs are exchanged',
                                              choice_description: 'Choose share',
                                              choices: corporations.map(&:name))
            return
          elsif num_shares[@merger] <= num_system_shares
            @odd_share = player.shares_of(@target).first
          else
            @odd_share = player.shares_of(@merger).first
          end
          @odd_share&.transfer(@used)
        end

        def restore_odd_share(player)
          @odd_share&.transfer(player)
        end

        def exchange_singles(player)
          num_shares = ->(corp) { player.num_shares_of(corp) }
          return if num_shares[@merger].zero? && num_shares[@target].zero?

          corp = num_shares[@merger].positive? ? @merger : @target
          if [@merger, @target].any? { |c| has_sold?(player, c) } ||
              corp.share_price.price + player.cash < @system.share_price.price ||
              @system.num_shares_of(@system).zero?
            player.shares_of(corp).first.transfer(@discard)
            sold_share(player, corp)

            @log << "#{player.name} discards a #{corp.name} share and receives #{@game.format_currency(corp.share_price.price)} from the bank."
            return
          end

          if corp == @merger
            exchange_single(player, @merger, player)
          elsif @discard.num_shares_of(@merger).positive?
            exchange_single(player, @target, @discard)
          elsif (players = @players.select { |p| p.num_shares_of(@merger).positive? }).any?
            if players.size > 1 && !@player_selection
              @player_choice = PlayerChoice.new(step_description: 'Choose which player to trade for system share',
                                                choice_description: 'Choose player',
                                                choices: players.map(&:name))
              return
            end
            @player_selection = players.find { |p| p.name == @player_selection } || players.first
            trade_share(player, @target, @player_selection, @merger)
            @player_selection = nil
            exchange_single(player, @merger, player)
          elsif @merger.num_shares_of(@merger).positive?
            exchange_single(player, @target, @merger)
          else
            exchange_single(player, @target, @game.share_pool)
          end
        end

        def trade_share(player_a, corporation_a, player_b, corporation_b)
          player_a.shares_of(corporation_a).first.transfer(player_b)
          player_b.shares_of(corporation_b).first.transfer(player_a)

          msg = ''
          cash_difference = corporation_b.share_price.price - corporation_a.share_price.price
          if cash_difference.positive?
            @game.bank.spend(cash_difference, player_b)
            msg = "#{player_b.name} receives #{@game.format_currency(cash_difference)} from the bank."
          elsif cash_difference.negative?
            cash_difference *= -1
            if player_b.cash >= cash_difference
              player_b.spend(cash_difference, @game.bank)
              msg = "#{player_b.name} pays #{@game.format_currency(cash_difference)} to the bank."
            else
              player_b.shares_of(corporation_a).first.transfer(@discard)
              sold_share(player_b, corporation_a)
              @game.bank.spend(corporation_b.share_price.price, player_b)
              msg = "#{player_b.name} must discard the #{corporation_a.name} share and receives #{@game.format_currency(corporation_b.share_price.price)} from the bank."
            end
          end

          @log << "#{player_a.name} trades a #{@target.name} share to #{player_b.name} for a #{@merger.name} share. #{msg}"
        end

        def exchange_unowned_shares(entity)
          num_shares = ->(corp) { entity.num_shares_of(corp) }
          total_shares = num_shares[@merger] + num_shares[@target]
          return unless total_shares.positive?

          if @system.num_shares_of(@system).zero?
            entity.shares_of(@target).each { |share| share.transfer(@discard) }
            return
          end

          if num_shares[@merger].positive?
            if total_shares == 1
              exchange_single(entity, @merger, entity)
            else
              share_corps = [@merger] << (num_shares[@target].positive? ? @target : @merger)
              exchange_pair(entity, share_corps, entity)
            end
          elsif @discard.num_shares_of(@merger).positive?
            total_shares == 1 ? exchange_single(entity, @target, @discard) :
                                exchange_pair(entity, [@target, @target], @discard)
          else
            total_shares == 1 ? exchange_single(entity, @target, :corporation) :
                                exchange_pair(entity, [@target, @target], :corporation)
          end

          exchange_unowned_shares(entity)
        end

        def exchange_discarded_shares
          total_shares = @discard.num_shares_of(@merger)
          return unless total_shares.positive?

          total_shares.times { @system.shares_of(@system).first.transfer(@game.share_pool) }

          @log << "#{remaining_system_shares} discarded system shares placed in the market"
        end

        def exchange_pair(entity, corps, from)
          entity.shares_of(corps.first).first.transfer(from) unless entity == from
          entity.shares_of(corps.last).first.transfer(@discard)
          from.shares_of(@merger).first.transfer(@used)
          @system.shares_of(@system).first.transfer(entity) unless entity == @merger

          msg = if corps.uniq.size == 2
                  "1 #{@merger.name} share and 1 #{@target.name} share"
                else
                  "2 #{corps.first.name} shares"
                end
          @log << "#{entity.name} exchanges #{msg} for a system share"
        end

        def exchange_single(entity, corp, from)
          payment_msg = ''
          if entity.player?
            price = @system.share_price.price - corp.share_price.price
            entity.spend(price, @game.bank)
            payment_msg = "and #{@game.format_currency(price)} "
          end

          entity.shares_of(corp).first.transfer(from) unless entity == from
          from.shares_of(@merger).first.transfer(@used)
          @system.shares_of(@system).first.transfer(entity) unless entity == @merger

          @log << "#{entity.name} exchanges a #{corp.name} share " + payment_msg + 'for a system share'
        end

        def complete_merger
          players = @round.entities

          # Selling either corporation this round constitutes as a sale of the system
          players.each { |p| sold_share(p, @system) if has_sold?(p, @target) || has_sold?(p, @merger) }

          # Donate share
          if (president = players.find { |p| p.shares_of(@system).find(&:president) })
            if president.num_shares_of(@system) >= 3
              puts 'Good case'
              @system.owner = president
            else
              puts 'Bad case'
              # Merge failed -- need to implement
            end
          end

          unless @system.floated?
            @system.spend(@system.cash, @game.bank)
            @log << "#{@system.name} not yet floated. Discarding treasury."
          end

          (@discard.shares_of(@merger) + @used.shares_of(@merger)).each { |share| share.transfer(share.corporation) }
          (@discard.shares_of(@target) + @used.shares_of(@target)).each { |share| share.transfer(share.corporation) }
          @merger.close!
          @target.close!

          reset_merge_state
        end

        def sold_share(player, corporation)
          @round.players_sold[player][corporation] = :now
        end

        def has_sold?(player, corporation)
          @round.players_sold[player][corporation]
        end
      end
    end
  end
end
