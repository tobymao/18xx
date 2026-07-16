# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'tracker'

module Engine
  module Game
    module G18ESP
      module Step
        # Emits destination_connection inline (not via CDC) so token-buy cash arrives before the same-turn spend.
        class Track < Engine::Step::TrackAndToken
          include Engine::Game::G18ESP::Tracker

          def actions(entity)
            return [] unless entity == current_entity
            return [] if entity.company?

            actions = []
            can_lay = can_lay_tile?(entity)
            can_token = can_place_token?(entity)
            actions << 'lay_tile' if can_lay
            actions << 'choose' if mountain_pass_choice_available?(entity, can_lay || can_token)
            actions << 'place_token' if can_token
            actions << 'destination_connection' if !@game.loading && @acted &&
                                                   @game.new_destination_connection?(entity)
            actions << 'pass' if actions.any?
            actions
          end

          def mountain_pass_choice_available?(entity, otherwise_blocking)
            return false unless @game.phase.status.include?('mountain_pass')
            return false if @round.opened_mountain_pass

            # Skip the graph query while loading when the step already blocks; the log tells us if a pass opens.
            return @game.future_mountain_pass_choose?(entity) if @game.loading && otherwise_blocking

            opening_mountain_pass?(entity)
          end

          def round_state
            super.merge(
              {
                opened_mountain_pass: false,
              }
            )
          end

          def setup
            super
            @tokened = false
            @round.opened_mountain_pass = false
          end

          def auto_actions(entity)
            return [] if @game.loading
            return [] unless @acted
            return [] unless @game.new_destination_connection?(entity)

            [Engine::Action::DestinationConnection.new(entity, corporations: [entity])]
          end

          def process_destination_connection(action)
            corp = action.corporations.first
            corp.goal_reached!(:destination)
            @game.clear_graph_for_entity(corp)
          end

          def process_place_token(action)
            super
            @game.graph.clear
          end

          def pay_token_cost(entity, cost, city)
            return super if !@game.mountain_pass_token_hex?(city.hex) || city.tokens.compact.size == 1

            first_corp = city.tokens.first.corporation
            extra_cost = cost - @game.class::MOUNTAIN_SECOND_TOKEN_COST
            entity.spend(@game.class::MOUNTAIN_SECOND_TOKEN_COST, first_corp)
            entity.spend(extra_cost, @game.bank) if extra_cost.positive?

            @log << "#{entity.name} pays #{first_corp.name} #{@game.format_currency(cost)}"
            @log << "#{entity.name} pays the bank #{@game.format_currency(extra_cost)}" if extra_cost.positive?
          end

          def opening_mountain_pass?(entity)
            entity.type != :minor && !@game.opening_new_mountain_pass(entity).empty?
          end

          def choice_name
            'Choose which Mountain Pass to open'
          end

          def choices
            @game.opening_new_mountain_pass(current_entity)
          end

          def process_choose(action)
            @game.open_mountain_pass(action.entity, action.choice)
            @game.graph_for_entity(action.entity).clear
            @round.opened_mountain_pass = true
            @game.consume_mountain_pass_hint!(action.entity)
          end

          def reactivate_for_token!
            @passed = false unless @tokened
          end

          def skip!
            pass!
          end
        end
      end
    end
  end
end
