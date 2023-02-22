# frozen_string_literal: true

module Engine
  module Game
    module G18EUS
      module Step
        module Parrer
          def actions(entity)
            return ['choose'] if @parring && entity == current_entity

            super
          end

          def choice_available?(entity)
            @parring && entity == current_entity
          end

          def choice_name
            return nil unless @parring

            'Choose corporation size'
          end

          def choices
            return nil unless @parring

            ['5 share', '10 share']
          end

          def can_buy_multiple?(_entity, corporation, owner)
            # Can buy one additional share after parring
            super || (@round.current_actions.any? { |a| a.is_a?(Action::Par) && a.corporation == corporation } &&
              @round.current_actions.none? { |a| a.is_a?(Action::BuyShares) && a.bundle.corporation == corporation })
          end

          def process_choose(action)
            choice = action.choice
            raise GameError, 'No choices to make at this time' unless @parring
            raise GameError, "#{action.choice} not a valid choice" unless choices.include?(action.choice)

            @log << "#{@parring.entity.name} selects size of #{choice} for #{@parring.corporation.name}"
            @game.grow_corporation(@parring.corporation) if choice == '10 share'
            @parring = nil
          end

          def process_par(action)
            entity = action.entity
            corporation = action.corporation
            share_price = action.share_price

            if !@loading && !get_par_prices(entity, corporation).include?(share_price)
              raise GameError, "Par price #{@game.format_currency(share_price.price)} not available"
            end

            super

            @parring = action
          end

          def get_par_prices(entity, corp)
            par_types = @game.par_types_for_round
            super.select { |p| par_types.include?(p.type) }
          end
        end
      end
    end
  end
end
