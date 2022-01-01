# frozen_string_literal: true

require_relative 'buy_sell_par_shares'

module Engine
  module Game
    module G18NewEngland
      module Step
        class ReserveParShares < G18NewEngland::Step::BuySellParShares
          def actions(entity)
            return [] unless entity == current_entity

            actions = []
            actions << 'par' if can_ipo_any?(entity) || can_reserve_any?(entity)
            actions << 'pass' unless actions.empty?
            actions
          end

          def description
            'Reserve or Form Minors'
          end

          def pass_description
            entity_reserved?(current_entity) ? 'Relinquish Reservations and Continue to Pass' : 'Pass'
          end

          def process_pass(action)
            if entity_reserved?(action.entity)
              @log << "#{action.entity.name} Relinquishes all reservations"
              remove_entity_reservations(action.entity)
              @round.relinquished[action.entity] = true
            end
            super
          end

          # only exit first stock round on consecutive passes
          def pass!
            super
            @round.pass_order.clear if @round.current_actions.any?
          end

          def skip!
            if current_entity && !@acted && entity_reserved?(current_entity)
              @log << "#{current_entity.name} relinquishes all reservations due to lack of money"
              remove_entity_reservations(current_entity)
              @round.relinquished[current_entity] = true
            end
            super
          end

          def log_skip(entity)
            return super unless @round.relinquished[entity]

            @log << "#{entity.name} is required to pass"
          end

          def can_reserve_any?(entity)
            !bought? && !relinquished?(entity) && @game.available_minor_prices.any? { |p| 2 * p.price <= entity.cash }
          end

          def can_ipo_any?(entity)
            !bought? && !relinquished?(entity) && @game.corporations.any? do |c|
              reserved?(c, entity) && @game.can_par?(c, entity) && can_par_minor?(entity, c.shares.first&.to_bundle)
            end
          end

          def relinquished?(entity)
            @round.relinquished[entity]
          end

          def remove_entity_reservations(entity)
            @round.reservations[entity].each { |minor, _v| remove_reservation(minor, entity) }
            @round.reservations[entity].clear
          end

          def remove_reservation(minor, entity)
            @round.reservations[entity][minor] = nil
            @game.unreserve_minor(minor, entity)
          end

          def add_reservation(minor, entity)
            @round.reservations[entity][minor] = true
            @game.reserve_minor(minor, entity)
          end

          def reserved?(minor, entity)
            @round.reservations[entity][minor]
          end

          def entity_reserved?(entity)
            @round.reservations[entity].any? { |_k, v| v }
          end

          def minor_reserved?(minor)
            @round.reservations.any? { |_k, v| v[minor] }
          end

          def process_par(action)
            minor = action.corporation
            entity = action.entity
            if reserved?(minor, entity)
              remove_reservation(minor, entity)
              return super
            end

            add_reservation(minor, entity)
            @log << "#{entity.name} reserves #{minor.name}"
            track_action(action, minor)
          end

          def ipo_type(minor)
            return :par if reserved?(minor, current_entity)
            return :form unless minor_reserved?(minor)

            ''
          end

          def round_state
            super.merge(
              {
                reservations: Hash.new { |h, k| h[k] = {} },
                relinquished: {},
              }
            )
          end
        end
      end
    end
  end
end
