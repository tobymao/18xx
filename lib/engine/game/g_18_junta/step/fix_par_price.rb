# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18Junta
      module Step
        # Rules summary 11 (A): once per game, at the start of a Stock Round, the owner of Investidores
        # Unidos may fix the par price of a company that has not yet sold any shares.
        class FixParPrice < Engine::Step::Base
          USE_CHOICE = 'use'
          SKIP_CHOICE = 'skip'

          def description
            'Private (A): Fix Par Price'
          end

          def actions(entity)
            return [] unless entity
            return [] unless entity == pending_actor

            @accepted ? %w[par] : %w[choose]
          end

          def active_entities
            actor = pending_actor
            actor ? [actor] : super
          end

          def blocks?
            !pending_actor.nil?
          end

          def choice_available?(entity)
            !@accepted && entity == pending_actor
          end

          def choice_name
            'Private (A) ability: do you want to fix the par price of a company that has not yet sold any shares?'
          end

          def choices
            {
              USE_CHOICE => 'Yes',
              SKIP_CHOICE => 'No',
            }
          end

          def ipo_type(_corporation)
            :par
          end

          def get_par_prices(_entity, _corporation)
            @game.stock_market.par_prices
          end

          def process_choose(action)
            if action.choice == USE_CHOICE
              @accepted = true
            else
              @game.skip_private_a!(action.entity)
              @round.private_a_resolved = true
              pass!
            end
          end

          def process_par(action)
            corporation = action.corporation
            share_price = action.share_price
            raise GameError, "#{corporation.name} cannot have its par price fixed (already started)" if corporation.ipoed

            @game.use_private_a!(corporation, share_price)
            @round.private_a_resolved = true
            pass!
          end

          def round_state
            { private_a_resolved: false }
          end

          private

          def pending_actor
            return nil unless @game.private_a_usable_this_stock_round?
            return nil if @round.private_a_resolved
            return nil if @game.corporations.all?(&:ipoed)

            @game.private_a_owner
          end
        end
      end
    end
  end
end
