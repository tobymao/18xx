# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/tokener'

module Engine
  module Game
    module G18CO
      module Step
        class Takeover < Engine::Step::Base
          include Engine::Step::Tokener
          ACTIONS = %w[place_token pass].freeze

          def actions(entity)
            return [] unless entity == current_entity

            ACTIONS
          end

          def round_state
            super.merge(
              {
                pending_takeover: nil,
              }
            )
          end

          def active?
            takeover_in_progress
          end

          def active_entities
            [current_entity]
          end

          def current_entity
            pending_takeover[:destination_corp]
          end

          def taken_entity
            pending_takeover[:source_corp]
          end

          def place_count
            pending_takeover[:place_count]
          end

          def pending_takeover
            @round.pending_takeover || {}
          end

          def description
            "Replace up to #{place_count} Tokens"
          end

          def available_cities
            taken_entity.tokens.map(&:city).compact
          end

          def available_city(_entity, city)
            available_cities.include?(city)
          end

          def available_hex(_entity, hex)
            available_cities.map(&:hex).include?(hex)
          end

          def pass_description
            'Discard Remaining Tokens'
          end

          def process_pass(_action)
            @game.log << "#{current_entity.name} passes replacing remaining #{taken_entity.name} tokens"

            close_corporation(taken_entity)
          end

          def process_place_token(action)
            entity = action.entity

            raise GameError, "Cannot place a token on #{action.city.hex.name}" unless available_hex(entity,
                                                                                                    action.city.hex)

            old_token = taken_entity.tokens.find { |t| t.city == action.city }
            new_token = entity.unplaced_tokens.last
            old_token.remove!
            action.city.exchange_token(new_token)
            pending_takeover[:place_count] -= 1

            @game.log << "#{current_entity.name} replaces #{taken_entity.name} token on #{action.city.hex.name}"

            return if place_count.positive? &&
              taken_entity.placed_tokens.any? &&
              current_entity.unplaced_tokens.any?

            close_corporation(taken_entity)
          end

          def takeover_in_progress
            return true if current_entity

            @game.corporations.dup.each do |source|
              next unless source&.owner&.corporation?

              execute_takeover!(source, source.owner)
              return true if current_entity
            end

            false
          end

          def execute_takeover!(source, destination)
            @game.log << "#{source.name} to be taken over by #{destination.name}"

            @round.pending_takeover = {
              destination_corp: destination,
              source_corp: source,
              place_count: 0,
            }

            return_corporate_shares_to_market(source)
            distribute_treasury(source, destination)
            remove_redundant_tokens(source, destination)
            increase_train_limit(source, destination)
            transfer_companies(source, destination)
            transfer_mines(source, destination)
            transfer_trains(source, destination)
            replace_tokens(source, destination)
            close_corporation(source) unless place_count.positive?
          end

          def return_corporate_shares_to_market(source)
            return unless source.corporate_shares.any?

            returned_certs = source.corporate_shares.group_by(&:corporation)
              .map { |key, vals| [key, vals.size] }

            cash = {}
            source.corporate_shares.dup.each do |share|
              @game.bank.spend(share.price, source)
              cash[share.corporation] =
                cash[share.corporation].nil? ? share.price : cash[share.corporation] + share.price
              share.transfer(@game.share_pool)
            end

            total_count = 0
            share_string = returned_certs.map do |corp, count|
              total_count += count
              "#{count} #{corp.name} (#{@game.format_currency(cash[corp])})"
            end.join(', ')

            @game.log << "#{source.name} returns #{share_string} to the market"
          end

          def remove_redundant_tokens(source, destination)
            return if source.placed_tokens.empty?
            return if destination.unplaced_tokens.empty?

            destination_hexes = destination.tokens.map { |token| token&.city&.hex }.compact

            source.tokens.each do |token|
              next unless token.used

              token.city&.remove_reservation!(source)
              token.remove! if destination_hexes.include?(token.city.hex)
            end
          end

          def transfer_companies(source, destination)
            return unless source.companies.any?

            transferred = @game.transfer(:companies, source, destination)

            @game.log << "#{destination.name} takes #{transferred.map(&:name).join(', ')} from #{source.name}"
          end

          def transfer_trains(source, destination)
            return unless source.trains.any?

            source.trains.each { |train| train.operated = false }
            transferred = @game.transfer(:trains, source, destination)

            @game.log << "#{destination.name} takes #{transferred.map(&:name).join(', ')}"\
                         " train#{transferred.one? ? '' : 's'} from #{source.name}"
          end

          def transfer_mines(source, destination)
            mine_count = @game.mines_count(source)
            return unless mine_count.positive?

            @game.log << "#{destination.name} takes #{mine_count} mines from #{source.name}"
            @game.mines_add(destination, mine_count)
            @game.mines_remove(source)
          end

          # The owned Corporation's Treasury, rounded down to the nearest $10
          # is paid out to the owned Corporation's shareholders as if it were a dividend.
          # Treasury money paid to shares in the Market is returned to the Bank.
          # Any leftover treasury cash is transferred to the owning Corporation's treasury.
          def distribute_treasury(source, destination)
            payout = (source.cash.to_f / 10).floor

            payout_shareholders(source, payout)

            remaining_cash = source.cash

            return unless remaining_cash.positive?

            source.spend(remaining_cash, destination)
            @game.log << "#{destination.name} takes #{@game.format_currency(remaining_cash)}"\
                         " from #{source.name} remaining cash"
          end

          def payout_shareholders(source, payout)
            share_percent = source.share_percent

            payouts = source.share_holders.map do |s_h|
              entity, percent = s_h
              next if source == entity

              total_payout = payout * percent / share_percent
              next unless total_payout.positive?

              entity = @game.bank if entity.name == 'Market'

              source.spend(total_payout, entity)
              "#{@game.format_currency(total_payout)} to #{entity.name}"
            end.compact

            @game.log << "#{source.name} distributes #{payouts.join(', ')}" if payouts.any?
          end

          def increase_train_limit(source, destination)
            destination.add_ability(
              Engine::Ability::TrainLimit.new(
                type: 'train_limit',
                description: "+1 train limit from #{source.name} takeover",
                increase: 1
              )
            )

            @game.log << "#{destination.name} has +1 train limit from #{source.name} takeover"
          end

          def replace_tokens(source, destination)
            return if source.placed_tokens.empty?
            return if destination.unplaced_tokens.empty?

            @round.pending_takeover[:place_count] = 2
          end

          def close_corporation(entity)
            @game.close_corporation(entity)
            if entity == @game.dsng && !@game.drgr&.closed?
              @game.log << "#{@game.drgr.name} closes due to takeover of #{@game.dsng.name}"
              @game.drgr.close!
            end
            entity.close!
            @round.pending_takeover = nil
          end

          def can_replace_token?(entity, token)
            available_city(entity, token.city)
          end
        end
      end
    end
  end
end
