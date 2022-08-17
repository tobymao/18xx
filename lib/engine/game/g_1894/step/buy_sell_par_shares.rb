# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1894
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def actions(entity)
            return %w[choose] if @pending_late_corporation && !@corporation_size

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

            @choices = @game.late_corporation_possible_home_hexes(corporation)

            @pending_late_corporation = corporation
          end

          def process_choose(action)
            choice = action.choice
            @game.late_corporation_home_hex(@pending_late_corporation, choice)
            @game.log << "#{@pending_late_corporation.name}'s home location is #{choice}"
            @pending_late_corporation = nil
          end

          def choice_available?(_entity)
            @pending_late_corporation != nil
          end

          def choice_name
            'Choose home location'
          end

          attr_reader :choices
        end
      end
    end
  end
end
