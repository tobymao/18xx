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
            description = 'Merger - '
            description += @player_choice.step_description if @player_choice
            description += "Select corporation to merge with #{mergeable_entity.name}" if @state == :select_target
            description
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
            enter_state(:start_merge)
          end

          def process_choose(action)
            raise GameError, 'Invalid action' unless @player_choice
            raise GameError, 'Not your turn' unless action.entity == @players.first
            raise GameError, 'Invalid choice' unless @player_choice.choices.any? { |c| c.include?(action.choice) }

            @player_selection = action.choice
            @player_choice = nil
            enter_state(@state)
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
              @merge_start_action_id = @game.last_game_action_id
              enter_state(:select_target)
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
            enter_state(@state) if @state == :token_removal
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
            @discard = ShareHolderEntity.new('the discard')
            @used = ShareHolderEntity.new
            @ipo = ShareHolderEntity.new('IPO')
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

            attr_reader :name

            def initialize(name = nil)
              @name = name
            end
          end

          def enter_state(state)
            @state = state

            case state
            when :start_merge
              enter_start_merge_state
            when :token_removal
              enter_token_removal_state
            when :exchange_pairs
              enter_exchange_pairs_state
            when :exchange_singles
              enter_exchange_singles_state
            when :complete_merger
              enter_complete_merger_state
            end
          end

          def enter_start_merge_state
            create_system
            @round.corporation_removing_tokens ? enter_state(:token_removal) : enter_state(:exchange_pairs)
          end

          def enter_token_removal_state
            enter_state(:exchange_pairs) unless @round.corporation_removing_tokens
          end

          def enter_exchange_pairs_state
            @players = @round.entities.rotate(@round.entities.index(@round.acting_player)) if !@players || @players.empty?

            while (player = @players.first)
              @trade_order = @round.entities.rotate(@round.entities.index(player))
              hide_odd_share(player)
              exchange_pairs(player)
              restore_odd_share(player)
              return if @player_choice

              @odd_share = nil
              @players.shift
            end

            enter_state(:exchange_singles)
          end

          def enter_exchange_singles_state
            @players = @round.entities.rotate(@round.entities.index(@round.acting_player) + 1) if !@players || @players.empty?

            until @players.empty?
              @trade_order = @players
              exchange_singles(@players.first)
              return if @player_choice

              @players.shift
            end

            enter_state(:complete_merger)
          end

          def enter_complete_merger_state
            @players = []
            exchange_pairs(@game.share_pool)
            exchange_singles(@game.share_pool)
            combine_ipo_shares
            exchange_pairs(@ipo)
            exchange_singles(@ipo)
            exchange_discarded_shares
            complete_merger
          end

          def reset_merger_step
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
            @merger.shares.dup.each { |s| s.transfer(@ipo) }
            @target.shares.dup.each { |s| s.transfer(@ipo) }
          end

          def exchange_pairs(entity)
            return unless entity.num_shares_of(@merger) + entity.num_shares_of(@target) >= 2
            return if @player_choice

            merger_pshare = entity.shares_of(@merger).find(&:president)
            target_pshare = entity.shares_of(@target).find(&:president)
            shares_needed = merger_pshare || target_pshare ? 2 : 1

            # Determine where the system share will come from
            from = exchange_source(entity, num_needed: shares_needed)
            return if @player_choice
            return discard_shares(entity) unless from

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
              @log << "#{entity.name} exchanges #{shares_str(exchanged_shares + discarded_shares)} for " \
                      "#{shares_needed} system share#{'s' if shares_needed > 1}"
              @game.share_pool.transfer_shares(ShareBundle.new(system_shares), entity) unless entity == @ipo
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
              @log << "#{entity.name} exchanges #{shares_str([exchanged_share,
                                                              discarded_share])} for 1 system share"
              @game.share_pool.transfer_shares(system_share.to_bundle, entity) unless entity == @ipo
            end

            # Repeat until all pairs owned by the entity are exchanged
            exchange_pairs(entity) if entity.num_shares_of(@merger).positive? || entity.num_shares_of(@target).positive?
          end

          def hide_odd_share(entity)
            identify_odd_share(entity) unless @odd_share
            @odd_share&.transfer(@used)
          end

          def identify_odd_share(entity)
            total_shares = entity.num_shares_of(@merger) + entity.num_shares_of(@target)
            return unless total_shares.odd?

            merger_share = entity.shares_of(@merger).reject(&:president).first
            target_share = entity.shares_of(@target).reject(&:president).first

            if @player_selection
              @odd_share = @player_selection.include?(@merger.name) ? merger_share : target_share
              @player_selection = nil
            elsif entity.player? && merger_share && target_share
              choices = merging_corporations.map do |c|
                "#{c.name} (#{@game.format_currency(c.share_price.price)})"
              end
              @player_choice = PlayerChoice.new(step_description: 'Choose share to retain after 2:1 exchange',
                                                choice_description: 'Choose share',
                                                choices: choices)
              nil
            else
              @odd_share = merger_share || target_share
            end
          end

          def restore_odd_share(entity)
            @odd_share&.transfer(entity)
          end

          def exchange_singles(entity)
            return if entity.num_shares_of(@merger).zero? && entity.num_shares_of(@target).zero?

            if !@exchange_selection && @player_selection
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
              @player_choice = PlayerChoice.new(step_description: 'Exchange or sell share',
                                                choice_description: 'Choose',
                                                choices: ["Exchange (#{@game.format_currency(exchange_cost)})",
                                                          "Sell (#{@game.format_currency(share.price)})"])
            else
              # Determine where the system share will come from
              from = exchange_source(entity)
              return if @player_choice
              return discard_shares(entity) unless from

              # Execute trade to get share(s) needed for the exchange
              trade_share(entity, [share], from, from.shares_of(@merger).reject(&:president).take(1)) if from != entity

              # Exchange the share and pay the difference in cost
              payment_msg = ''
              if entity.player?
                price = @system.share_price.price - share.price
                entity.spend(price, @game.bank)
                payment_msg = "and #{@game.format_currency(price)} "
              end

              entity.shares_of(@merger).first.transfer(@used)
              @log << ("#{entity.name} exchanges 1 #{share.corporation.name} share " + payment_msg + 'for 1 system share')
              @game.share_pool.transfer_shares(@system.shares_of(@system).first.to_bundle, entity) unless entity == @ipo

              @exchange_selection = nil
            end
          end

          def exchange_source(entity, num_needed: 1)
            source = nil

            if @player_selection
              source = @trade_order.find { |p| p.name == @player_selection }
              @player_selection = nil
            elsif entity.num_shares_of(@merger) >= num_needed
              source = entity
            else
              sources = [@discard, @trade_order[1..-1], @merger, @game.share_pool].flatten.compact.select do |src|
                merger_shares = src.shares_of(@merger).reject(&:president)
                target_shares = src.shares_of(@target).reject(&:president)

                merger_shares.size.positive? && (merger_shares.size + target_shares.size) >= num_needed
              end

              # If exchanging with another player, check to see if there are options to choose from
              if sources.any? && sources.first.player? && (players = sources.select do |s|
                                                             @trade_order.include?(s)
                                                           end).size > 1
                @log << ("#{entity.name} chooses player to trade #{@target.name} share to for #{@merger.name} share")
                @player_choice =
                  PlayerChoice.new(step_description: "Trade #{@target.name} share for #{@merger.name} share",
                                   choice_description: 'Choose player',
                                   choices: players.map(&:name))
              end

              source = sources.first
            end

            source
          end

          def discard_shares(entity)
            shares_to_discard = entity.shares_of(@target)
            @log << "#{entity.name} discards #{shares_str(shares_to_discard)}"
            shares_to_discard.dup.each { |s| s.transfer(@discard) }
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
            log_msg = "#{entity_a.name} trades #{shares_str(shares_a)} to #{entity_b.name} for #{shares_str(shares_b)}"

            # If the receiving player cannot exchange the share as a pair, they pay/receive the share price difference
            if entity_b.player? &&
               shares_b.size == 1 &&
               (entity_b.num_shares_of(@merger) + entity_b.num_shares_of(@target)).odd? &&
               !(cash_difference = shares_b.first.price - shares_a.first.price).zero?
              log_msg += '. '
              if cash_difference.positive?
                @game.bank.spend(cash_difference, entity_b)
                log_msg += "#{entity_b.name} receives #{@game.format_currency(cash_difference)} from the bank."
              else
                cash_difference = cash_difference.abs
                if entity_b.cash >= cash_difference
                  entity_b.spend(cash_difference, @game.bank)
                  log_msg += "#{entity_b.name} pays #{@game.format_currency(cash_difference)} to the bank."
                else
                  discard_share = shares_a.first
                  discard_share.transfer(@discard)
                  sold_share(entity_b, discard_share.corporation)
                  @game.bank.spend(discard_share.price, entity_b)
                  log_msg += "#{entity_b.name} must discard #{shares_str([discard_share])} and receives " \
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

            # Selling either corporation this round constitutes as a sale of the system
            players = @round.entities
            players.each { |p| sold_share(p, @system) if sold_share?(p, @target) || sold_share?(p, @merger) }

            # Donate share
            if @system.owner.num_shares_of(@system) >= 3
              @log << "President (#{@system.owner.name}) contributes 1 system share to the #{@system.name} treasury"
              share = @system.owner.shares_of(@system).reject(&:president).first
              share.buyable = false
              @game.share_pool.transfer_shares(share.to_bundle, @system)
            else
              @state = :failed
              return
            end

            # Fix-up treasury for the case where one of the merging corporations wasn't floated
            if !@merger.floated? || !@target.floated?
              @system.spend(@system.cash, @game.bank)
              if @system.floated?
                @game.bank.spend(@system.share_price.price * 10, @system)
                @log << "Setting #{@system.name}'s treasury to 10 times market price"
              else
                @log << "#{@system.name} not yet floated, discarding treasury"
              end
            end

            close_corporation(@merger)
            close_corporation(@target)
            reset_merger_step
          end

          def sold_share(player, corporation)
            @round.players_sold[player][corporation] = :now
          end

          def sold_share?(player, corporation)
            @round.players_sold[player][corporation]
          end

          def close_corporation(corporation)
            corporation.share_holders.keys.each do |share_holder|
              share_holder.shares_by_corporation.delete(corporation)
            end
            @game.share_pool.shares_by_corporation.delete(corporation)
            corporation.share_price&.corporations&.delete(corporation)
            @game.corporations.delete(corporation)
            corporation.close!
          end
        end
      end
    end
  end
end
