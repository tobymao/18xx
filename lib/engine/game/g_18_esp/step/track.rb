# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'tracker'

module Engine
  module Game
    module G18ESP
      module Step
        class Track < Engine::Step::TrackAndToken
          include Engine::Game::G18ESP::Tracker

          def actions(entity)
            return [] unless entity == current_entity
            return [] if entity.company?

            actions = []
            actions << 'lay_tile' if can_lay_tile?(entity)
            if opening_mountain_pass?(entity) && @game.phase.status.include?('mountain_pass') && !@round.opened_mountain_pass
              actions << 'choose'
            end
            actions << 'place_token' if can_place_token?(entity)
            actions << 'pass' if actions.any?
            actions
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
          end

          def skip!
            pass!
          end
        end
      end
    end
  end
end
