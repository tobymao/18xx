# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../token'
require_relative '../../../entity'
require_relative '../../../share_holder'
require_relative '../system'

module Engine
  module Game
    module G1828
      module Step
        class Merger < Engine::Step::Base
          def actions(_entity)
            return [] unless merge_in_progress?

            case @state
            when :select_target
              ['merge']
            when :failed
              ['failed_merge']
            else
              ['choose']
            end
          end

          def description
            if @player_choice
              @player_choice.step_description
            elsif @state == :select_target
              "Select a corporation to merge with #{mergeable_entity.name}"
            else
              'Merge failed'
            end
          end

          def blocks?
            merge_in_progress?
          end

          def merge_in_progress?
            mergeable_entity
          end

          def merge_failed?
            @state == :failed
          end

          def process_merge(action)
            @target = action.corporation
            raise GameError, 'Invalid action' unless @state == :select_target
            raise GameError, 'Wrong company' unless action.entity == mergeable_entity
            unless mergeable_entities(@round.acting_player, mergeable_entity).include?(@target)
              raise GameError, "Unable to merge #{mergeable_entity.name} with #{action.corporation.name}"
            end

            @merger = mergeable_entity
            merge_corporations
          end

          def process_choose(action)
            raise GameError, 'Invalid action' unless @player_choice
            raise GameError, 'Not your turn' unless action.entity == @players.first
            raise GameError, 'Invalid choice' unless @player_choice.choices.any? { |c| c.include?(action.choice) }

            @player_selection = action.choice
            @player_choice = nil
            merge_corporations
          end

          def merge_action
            @state == :failed ? 'Acknowledge' : 'Merge'
          end

          def action_id_before_merge
            @merge_start_action_id
          end

          def mergeable_type(corporation)
            "Corporations that can merge with #{corporation.name}"
          end

          def mergeable_entity
            if !@state && @round.merge_initiator
              @state = :select_target
              @merge_start_action_id = @game.last_game_action_id
            end
            @system || @round.merge_initiator
          end

          def merging_corporations
            [@merger, @target]
          end

          def show_other_players
            false
          end

          def choice_available?(entity)
            @player_choice && entity == @players.first
          end

          def choice_name
            @player_choice&.choice_description
          end

          def choices
            @player_choice&.choices
          end

          def active_entities
            merge_corporations if @state == :token_removal
            return [] unless merge_in_progress?

            if @player_choice
              [@players.first]
            else
              [@round.acting_player]
            end
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

            trains = @system.trains.empty? ? 'None' : @system.trains.map(&:name).join(', ')
            @log << "Merging #{@target.name} into #{@merger.name}. #{@merger.name} system " \
                    "receives #{@game.format_currency(@system.cash)} cash, " \
                    "trains (#{trains}), and tokens (#{@system.tokens.size}). " \
                    "New share price is #{@game.format_currency(@system.share_price.price)}. "
          end

          def combine_ipo_shares
            @target.shares_of(@target).dup.each { |s| s.transfer(@merger) }
          end

          def exchange_pairs(entity)
            return unless entity.num_shares_of(@merger) + entity.num_shares_of(@target) >= 2

            # Determine which share not to trade-in if entity has an odd number of shares
            hide_odd_share(entity)
            return if @player_choice

            merger_pshare = entity.shares_of(@merger).find(&:president)
            target_pshare = entity.shares_of(@target).find(&:president)
            shares_needed = merger_pshare || target_pshare ? 2 : 1

            # Determine where the system share will come from
            from = exchange_source(entity, num_needed: shares_needed)
            return if @player_choice

            unless from
              restore_odd_share(entity)
              entity.shares_of(@target).dup.each { |share| share.transfer(@discard) }
              return
            end

            if from == entity
              # Entity already has the required shares, execute exchange, including presidency edge cases
              exchanged_shares = merger_pshare ? [merger_pshare] : entity.shares_of(@merger).take(shares_needed)
              exchanged_shares.each { |share| share.transfer(@used) }

              discarded_shares = if target_pshare
                                   [target_pshare]
                                 else
                                   (entity.shares_of(@target) + entity.shares_of(@merger)).take(shares_needed)
                                 end
              discarded_shares.each { |share| share.transfer(@discard) }

              system_shares = if shares_needed == 2 && (system_pshare = @system.shares_of(@system).find(&:president))
                                [system_pshare]
                              else
                                @system.shares_of(@system).take(shares_needed)
                              end
              @game.share_pool.transfer_shares(ShareBundle.new(system_shares), entity) unless entity == @merger

              @log << "#{entity.name} exchanges #{shares_str(exchanged_shares + discarded_shares)} for " \
                      "#{shares_needed} system share#{'s' if shares_needed > 1}"
            else
              # Execute trade to get share(s) needed for the exchange
              shares_to_trade = [merger_pshare || target_pshare || entity.shares_of(@target).first]
              from_merger_shares = from.shares_of(@merger).reject(&:president)
              shares_to_receive = [from_merger_shares.first,
                                   from.shares_of(@target).reject(&:president).first,
                                   from_merger_shares[1]].compact.take(shares_needed)
              trade_share(entity, shares_to_trade, from, shares_to_receive)

              # Exchange the shares
              (exchanged_share = entity.shares_of(@merger).first).transfer(@used)
              discarded_share = (entity.shares_of(@target) + entity.shares_of(@merger)).first
              discarded_share.transfer(@discard)

              system_share = @system.shares_of(@system).reject(&:president).first
              @game.share_pool.transfer_shares(system_share.to_bundle, entity) unless entity == @merger

              @log << "#{entity.name} exchanges #{shares_str([exchanged_share,
                                                              discarded_share])} for 1 system share"
            end

            # Repeat until all pairs owned by the entity are exchanged
            exchange_pairs(entity) if entity.num_shares_of(@merger).positive? || entity.num_shares_of(@target).positive?

            restore_odd_share(entity)
          end

          def hide_odd_share(entity)
            total_shares = entity.num_shares_of(@merger) + entity.num_shares_of(@target)
            return unless total_shares.odd?

            merger_share = entity.shares_of(@merger).reject(&:president).first
            target_share = entity.shares_of(@target).reject(&:president).first

            num_system_shares = total_shares / 2
            if @player_selection
              @odd_share = @merger.name.include?(@player_selection) ? merger_share : target_share
              @player_selection = nil
            elsif !merger_share
              @odd_share = target_share
            elsif !target_share
              @odd_share = merger_share
            elsif entity.num_shares_of(@merger) <= num_system_shares
              @odd_share = target_share
            elsif entity.player?
              choices = merging_corporations.map do |c|
                "#{c.name} (#{@game.format_currency(c.share_price.price)})"
              end
              @player_choice = PlayerChoice.new(step_description: 'Choose Share not to Exchange',
                                                choice_description: 'Choose share',
                                                choices: choices)
              return
            else
              @odd_share = entity.shares_of(@merger).first
            end
            @odd_share&.transfer(@used)
          end

          def restore_odd_share(entity)
            @odd_share&.transfer(entity)
            @odd_share = nil
          end

          def exchange_singles(entity)
            return if entity.num_shares_of(@merger).zero? && entity.num_shares_of(@target).zero?

            if @player_selection
              @exchange_selection = @player_selection
              @player_selection = nil
            end

            # Determine if the entity can exchange a single share for a system share
            share = (entity.shares_of(@merger) + entity.shares_of(@target)).first
            if entity.player? &&
                ([@merger, @target].any? { |c| sold_share?(entity, c) } ||
                 share.price + entity.cash < @system.share_price.price ||
                 @system.num_shares_of(@system).zero? ||
                 @exchange_selection&.include?('Sell'))
              share.transfer(@discard)
              sold_share(entity, share.corporation)
              @game.bank.spend(share.price, entity)
              @exchange_selection = nil

              @log << "#{entity.name} discards 1 #{share.corporation.name} share and receives " \
                      "#{@game.format_currency(share.price)} from the bank."
            elsif entity.player? && !@exchange_selection
              exchange_cost = share.price - @system.share_price.price
              @player_choice = PlayerChoice.new(step_description: 'Exchange or Sell Share',
                                                choice_description: 'Choose',
                                                choices: ["Exchange (#{@game.format_currency(exchange_cost)})",
                                                          "Sell (#{@game.format_currency(share.price)})"])
            else
              # Determine where the system share will come from
              from = exchange_source(entity)
              return if @player_choice
              return entity.shares_of(@target).each { |s| s.transfer(@discard) } unless from

              # Execute trade to get share(s) needed for the exchange
              trade_share(entity, [share], from,
                          from.shares_of(@merger).reject(&:president).take(1)) if from != entity

              # Exchange the share and pay the difference in cost
              payment_msg = ''
              if entity.player?
                price = @system.share_price.price - share.price
                entity.spend(price, @game.bank)
                payment_msg = "and #{@game.format_currency(price)} "
              end

              entity.shares_of(@merger).first.transfer(@used)
              unless entity == @merger
                @game.share_pool.transfer_shares(@system.shares_of(@system).first.to_bundle, entity)
              end

              @exchange_selection = nil

              @log << "#{entity.name} exchanges 1 #{share.corporation.name} share " + payment_msg + 'for 1 system share'
            end
          end

          def exchange_source(entity, num_needed: 1)
            source = nil

            if @player_selection
              source = @players.find { |p| p.name == @player_selection }
              @player_selection = nil
            elsif entity.num_shares_of(@merger) >= num_needed &&
                  [@merger, @target].sum { |c| entity.num_shares_of(c) } >= num_needed * 2
              source = entity
            else
              sources = [@discard, @players[1..-1], @merger, @game.share_pool].flatten.compact.select do |src|
                merger_shares = src.shares_of(@merger).reject(&:president)
                target_shares = src.shares_of(@target).reject(&:president)

                merger_shares.size.positive? && (merger_shares.size + target_shares.size) >= num_needed
              end

              # If exchanging with another player, check to see if there are options to choose from
              if sources.any? && sources.first.player? && (players = sources.select do |s|
                                                             @players.include?(s)
                                                           end).size > 1
                @player_choice = PlayerChoice.new(step_description: 'Choose Player to Trade with for a System Share',
                                                  choice_description: 'Choose player',
                                                  choices: players.map(&:name))
              end

              source = sources.first
            end

            source
          end

          def shares_str(shares)
            return unless shares&.any?

            shares.group_by(&:corporation).flat_map do |c, cshares|
              cshares.partition(&:president).flat_map do |partition|
                next unless partition.any?

                if partition.first.president
                  'president\'s share'
                elsif partition.size == 1
                  '1 share'
                else
                  "#{partition.size} shares"
                end
              end.compact.join(' and ') + " of #{c.name}"
            end.join(' and ')
          end

          def trade_share(entity_a, shares_a, entity_b, shares_b)
            shares_a.each { |s| s.transfer(entity_b) }
            shares_b.each { |s| s.transfer(entity_a) }
            return unless entity_b.player?

            log_msg = "#{entity_a.name} trades #{shares_str(shares_a)} to #{entity_b.name} for #{shares_str(shares_b)}."

            # If the receiving player cannot exchange the share as a pair, they pay/receive the share price difference
            if shares_b.size == 1 && (entity_b.num_shares_of(@merger) + entity_b.num_shares_of(@target)).odd? &&
               !(cash_difference = shares_b.first.price - shares_a.first.price).zero?
              if cash_difference.positive?
                @game.bank.spend(cash_difference, entity_b)
                log_msg += " #{entity_b.name} receives #{@game.format_currency(cash_difference)} from the bank."
              else
                cash_difference = cash_difference.abs
                if entity_b.cash >= cash_difference
                  entity_b.spend(cash_difference, @game.bank)
                  log_msg += " #{entity_b.name} pays #{@game.format_currency(cash_difference)} to the bank."
                else
                  discard_share = shares_a.first
                  discard_share.transfer(@discard)
                  sold_share(entity_b, discard_share.corporation)
                  @game.bank.spend(discard_share.price, entity_b)
                  log_msg += " #{entity_b.name} must discard #{shares_str([discard_share])} and receives " \
                             "#{@game.format_currency(discard_share.price)} from the bank."
                end
              end
            end

            @log << log_msg
          end

          def exchange_discarded_shares
            total_shares = @discard.num_shares_of(@merger)
            return unless total_shares.positive?

            shares = @system.shares_of(@system).take(total_shares)
            @game.share_pool.transfer_shares(ShareBundle.new(shares), @game.share_pool)

            @log << "#{total_shares} discarded system shares placed in the market"
          end

          def complete_merger
            (@discard.shares_of(@merger) + @used.shares_of(@merger)).each { |s| s.transfer(s.corporation) }
            (@discard.shares_of(@target) + @used.shares_of(@target)).each { |s| s.transfer(s.corporation) }
            @merger.close!
            @target.close!

            # Selling either corporation this round constitutes as a sale of the system
            players = @round.entities
            players.each { |p| sold_share(p, @system) if sold_share?(p, @target) || sold_share?(p, @merger) }

            # Donate share
            if @system.owner.num_shares_of(@system) >= 3
              share = @system.owner.shares_of(@system).reject(&:president).first
              share.buyable = false
              @game.share_pool.transfer_shares(share.to_bundle, @system)
            else
              @state = :failed
              return
            end

            unless @system.floated?
              @system.spend(@system.cash, @game.bank)
              @log << "#{@system.name} not yet floated, discarding treasury."
            end

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
end
