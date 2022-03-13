# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1894
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def actions(entity)
            if @pending_late_corporation
              return %w[choose] unless @corporation_size
            end

            super
          end

          def can_buy_multiple?(entity, corporation, _owner)
            super && corporation.owner == entity && num_shares_bought(corporation) < 2
          end

          def num_shares_bought(corporation)
            @round.current_actions.count { |x| x.is_a?(Action::BuyShares) && x.bundle.corporation == corporation }
          end

          def process_par(action)
            super

            corporation = action.corporation

            return if Engine::Game::G1894::Game::REGULAR_CORPORATIONS.include?(corporation.name)

            choices = @game.late_corporation_possible_home_hexes(corporation)

            @home_hex_choice = HomeHexChoice.new(step_description: "Choose home location for #{corporation.name}",
              choice_description: 'Choose home location',
              choices: choices)
            nil

            @pending_late_corporation = corporation
          end

          def process_choose(action)
            @game.home_hex(@pending_late_corporation, action.choice)
            @pending_late_corporation = nil
          end

          def choice_available?(entity)
            @home_hex_choice
          end

          def choice_name
            @home_hex_choice&.choice_description
          end

          def choices
            @home_hex_choice&.choices
          end

          class HomeHexChoice
            attr_accessor :step_description, :choice_description, :choices

            def initialize(step_description:, choice_description:, choices:)
              @step_description = step_description
              @choice_description = choice_description
              @choices = choices
            end
          end
        end
      end
    end
  end
end
