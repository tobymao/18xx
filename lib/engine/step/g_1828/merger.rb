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

        def actions(_entity)
          return [] unless merge_in_progress?

          [:select_target, :failed].include?(@state) ? MERGE_ACTIONS : CHOOSE_ACTIONS
        end

        def description
          if @player_choice
            @player_choice.step_description
          elsif @state == :select_target
            "Select a corporation to merge with #{mergeable_entity.name}"
          else
            "Merge failed"
          end
        end

        def blocks?
          merge_in_progress?
        end

        def merge_in_progress?
          mergeable_entity
        end

        def process_merge(action)
          @target = action.corporation
          @game.game_error('Invalid action') unless @state == :select_target
          @game.game_error('Wrong company') unless action.entity == mergeable_entity
          unless mergeable_entities(@round.acting_player, mergeable_entity).include?(@target)
            @game.game_error("Unable to merge #{mergeable_entity.name} with #{action.corporation.name}")
          end

          @merger = mergeable_entity
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

        def merge_action
          @state == :failed ? 'Acknowledge' : 'Merge'
        end

        def mergeable_type(corporation)
          "Corporations that can merge with #{corporation.name}"
        end

        def mergeable_entity
          @state = :select_target if !@state && @round.merge_initiator
          @system || @round.merge_initiator
        end

        def merging_corporations
          [@merger, @target]
        end

        def choice_name
          @player_choice&.choice_description
        end

        def choices
          @player_choice&.choices
        end

        def show_other_players
          false
        end

        def choice_available?(entity)
          @player_choice && entity == @players.first
        end

        def active_entities
          merge_corporations if @state == :token_removal
          return [] unless merge_in_progress?

          (!@state || @state == :select_target) ? [@round.acting_player] : [@players.first]
        end

        def mergeable_entities(entity = @round.acting_player, corporation = mergeable_entity)
          @game.merge_candidates(entity, corporation)
        end

        def round_state
          {
            merge_initiator: nil,
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

        def merge_corporations
          if @state == :select_target
            create_system
            @round.corporation_removing_tokens ? enter_token_removal_state : enter_exchange_pairs_state
          end

          enter_exchange_pairs_state if @state == :token_removal && !@round.corporation_removing_tokens

          if @state == :exchange_pairs
            while @players.any?
              exchange_pairs(@players.first)
              return if @player_choice

              @players.shift
            end
            enter_exchange_singles_state
          end

          if @state == :exchange_singles
            while @players.any?
              exchange_singles(@players.first)
              return if @player_choice

              @players.shift
            end
            enter_complete_merger_state
          end

          return unless @state == :complete_merger

          exchange_pairs(@game.share_pool)
          exchange_singles(@game.share_pool)
          combine_ipo_shares
          exchange_pairs(@merger)
          exchange_singles(@merger)
          exchange_discarded_shares
          complete_merger
        end

        def enter_token_removal_state
          @state = :token_removal
        end

        def enter_exchange_pairs_state
          @state = :exchange_pairs
          @players = @round.entities.rotate(@round.entities.index(@round.acting_player))
        end

        def enter_exchange_singles_state
          @state = :exchange_singles
          @players = @round.entities.rotate(@round.entities.index(@round.acting_player) + 1)
        end

        def enter_complete_merger_state
          @state = :complete_merger
          @players = []
        end

        def reset_merge_state
          @state = nil
          @merger = nil
          @target = nil
          @players = nil
          @system = nil
          @round.merge_initiator = nil
          @round.acting_player = nil
        end

        def create_system
          @system = @game.create_system(merging_corporations)

          used_tokens = @system.tokens.select(&:used)
          if (hexes = used_tokens.group_by { |t| t.city.tile.hex }.select { |_k, v| v.size > 1 }.keys).any?
            @round.corporation_removing_tokens = @system
            @round.hexes_to_remove_tokens = hexes
          end

          trains = @system.trains.any? ? @system.trains.map(&:name).join(', ') : 'None'
          @log << "Merging #{@target.name} into #{@merger.name}. #{@merger.name} system " \
                  "receives #{@game.format_currency(@system.cash)} cash, " \
                  "trains (#{trains}), and tokens (#{@target.tokens.size}). " \
                  "New share price is #{@game.format_currency(@merger.share_price.price)}. "
        end

        def combine_ipo_shares
          @target.num_shares_of(@target).times { @target.shares_of(@target).first.transfer(@merger) }
        end

        def exchange_pairs(entity)
          return unless entity.num_shares_of(@merger) + entity.num_shares_of(@target) >= 2

          # Determine which share not to trade-in if entity has an odd number of shares
          hide_odd_share(entity)
          return if @player_choice

          # Determine where the system share will come from
          from = exchange_source(entity)
          return if @player_choice
          return entity.shares_of(@target).each { |share| share.transfer(@discard) } unless from

          # Execute trade if the system share comes from another player
          if from != entity && from.player?
            trade_share(entity, @target, from, @merger)
            from = entity
          end

          # Exchange the pair of shares
          share_corps = if from == entity
                          [@merger] << (entity.num_shares_of(@target).positive? ? @target : @merger)
                        else
                          [@target, @target]
                        end
          entity.shares_of(share_corps.first).first.transfer(from) unless entity == from
          entity.shares_of(share_corps.last).first.transfer(@discard)
          from.shares_of(@merger).first.transfer(@used)
          @system.shares_of(@system).first.transfer(entity) unless entity == @merger

          msg = if share_corps.uniq.size == 2
                  "1 #{@merger.name} share and 1 #{@target.name} share"
                else
                  "2 #{share_corps.first.name} shares"
                end
          @log << "#{entity.name} exchanges #{msg} for a system share"

          # Repeat until all pairs owned by the entity are exchanged
          exchange_pairs(entity) if entity.num_shares_of(@merger).positive? || entity.num_shares_of(@target).positive?

          restore_odd_share(entity)
        end

        def hide_odd_share(entity)
          total_shares = entity.num_shares_of(@merger) + entity.num_shares_of(@target)
          return unless total_shares.odd?

          num_system_shares = total_shares / 2
          if @player_selection
            @odd_share = entity.shares_of(@game.corporations.find { |c| c.name == @player_selection }).first
            @player_selection = nil
          elsif entity.player? &&
                entity.num_shares_of(@merger) > num_system_shares &&
                entity.num_shares_of(@target).positive?
            @player_choice = PlayerChoice.new(step_description: 'Choose Share Not to Exchange',
                                              choice_description: 'Choose share',
                                              choices: merging_corporations.map(&:name))
            return
          elsif entity.num_shares_of(@merger) <= num_system_shares
            @odd_share = entity.shares_of(@target).first
          else
            @odd_share = entity.shares_of(@merger).first
          end
          @odd_share&.transfer(@used)
        end

        def restore_odd_share(entity)
          @odd_share&.transfer(entity)
        end

        def exchange_singles(entity)
          return if entity.num_shares_of(@merger).zero? && entity.num_shares_of(@target).zero?

          # Determine if the entity can exchange a single share for a system sahre
          corp = entity.num_shares_of(@merger).positive? ? @merger : @target
          if entity.player? &&
              ([@merger, @target].any? { |c| sold_share?(entity, c) } ||
               corp.share_price.price + entity.cash < @system.share_price.price ||
               @system.num_shares_of(@system).zero?)
            entity.shares_of(corp).first.transfer(@discard)
            sold_share(entity, corp)

            @log << "#{entity.name} discards a #{corp.name} share and receives " \
                    "#{@game.format_currency(corp.share_price.price)} from the bank."
            return
          end

          # Determine where the system share will come from
          from = exchange_source(entity)
          return if @player_choice
          return entity.shares_of(@target).each { |share| share.transfer(@discard) } unless from

          # Execute trade if the system share comes from another player
          if from != entity && from.player?
            trade_share(entity, @target, from, @merger)
            from = entity
          end

          # Exchange the share and pay the difference in cost
          share_corp = from == entity ? @merger : @target
          payment_msg = ''
          if entity.player?
            price = @system.share_price.price - share_corp.share_price.price
            entity.spend(price, @game.bank)
            payment_msg = "and #{@game.format_currency(price)} "
          end

          entity.shares_of(share_corp).first.transfer(from) unless entity == from
          from.shares_of(@merger).first.transfer(@used)
          @system.shares_of(@system).first.transfer(entity) unless entity == @merger

          @log << "#{entity.name} exchanges a #{share_corp.name} share " + payment_msg + 'for a system share'
        end

        def exchange_source(entity)
          source = nil

          if entity.num_shares_of(@merger).positive?
            source = entity
          elsif @discard.num_shares_of(@merger).positive?
            source = @discard
          elsif (players = @players.select { |p| p.num_shares_of(@merger).positive? }).any?
            if players.size > 1 && !@player_selection
              @player_choice = PlayerChoice.new(step_description: 'Choose Player to Trade with for a System Share',
                                                choice_description: 'Choose player',
                                                choices: players.map(&:name))
              return
            end
            source = players.find { |p| p.name == @player_selection } || players.first
            @player_selection = nil
          elsif @merger.num_shares_of(@merger).positive?
            source = @merger
          elsif @game.share_pool.num_shares_of(@merger).positive?
            source = @game.share_pool
          end

          source
        end

        def trade_share(player_a, corporation_a, player_b, corporation_b)
          player_a.shares_of(corporation_a).first.transfer(player_b)
          player_b.shares_of(corporation_b).first.transfer(player_a)

          msg = nil
          cash_difference = corporation_b.share_price.price - corporation_a.share_price.price
          if cash_difference.positive?
            @game.bank.spend(cash_difference, player_b)

            msg = "#{player_b.name} receives #{@game.format_currency(cash_difference)} from the bank."
          elsif cash_difference.negative?
            cash_difference = cash_difference.abs
            if player_b.cash >= cash_difference
              player_b.spend(cash_difference, @game.bank)

              msg = "#{player_b.name} pays #{@game.format_currency(cash_difference)} to the bank."
            else
              player_b.shares_of(corporation_a).first.transfer(@discard)
              sold_share(player_b, corporation_a)
              @game.bank.spend(corporation_b.share_price.price, player_b)

              msg = "#{player_b.name} must discard the #{corporation_a.name} share and receives " \
                    "#{@game.format_currency(corporation_b.share_price.price)} from the bank."
            end
          end

          @log << "#{player_a.name} trades a #{@target.name} share to #{player_b.name} for a #{@merger.name} share. " \
                  "#{msg}"
        end

        def exchange_discarded_shares
          total_shares = @discard.num_shares_of(@merger)
          return unless total_shares.positive?

          total_shares.times { @system.shares_of(@system).first.transfer(@game.share_pool) }

          @log << "#{total_shares} discarded system shares placed in the market"
        end

        def complete_merger
          players = @round.entities

          # Selling either corporation this round constitutes as a sale of the system
          players.each { |p| sold_share(p, @system) if sold_share?(p, @target) || sold_share?(p, @merger) }

          # Donate share
          if (president = players.find { |p| p.shares_of(@system).find(&:president) })
            if president.num_shares_of(@system) >= 3
              @system.owner = president

              share = president.shares_of(@system).find { |s| !s.president }
              share.buyable = false
              @game.share_pool.transfer_shares(share.to_bundle, @system)
            else
              @state = :failed
              return
              # TODO: Implement multi-turn undo
            end
          end

          unless @system.floated?
            @system.spend(@system.cash, @game.bank)
            @log << "#{@system.name} not yet floated, discarding treasury."
          end

          (@discard.shares_of(@merger) + @used.shares_of(@merger)).each { |s| s.transfer(s.corporation) }
          (@discard.shares_of(@target) + @used.shares_of(@target)).each { |s| s.transfer(s.corporation) }
          @merger.close!
          @target.close!

          reset_merge_state
        end

        def sold_share(player, corporation)
          @round.players_sold[player][corporation] = :now
        end

        def sold_share?(player, corporation)
          @round.players_sold[player][corporation]
        end
      end
    end
  end
end
