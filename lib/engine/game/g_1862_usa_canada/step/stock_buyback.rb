# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1862UsaCanada
      module Step
        class StockBuyback < Engine::Step::Base
          ACTIONS = %w[choose pass].freeze

          def description
            'Stock Buyback (Aktienrückkauf)'
          end

          def pass_description
            'Skip Buyback'
          end

          def actions(entity)
            return [] unless entity.corporation?
            return [] unless entity == current_entity
            return [] unless buyback_available?(entity)

            ACTIONS
          end

          def choice_name
            amount = @game.buyback_bond_amount(current_entity)
            half   = @game.corporation_by_id(current_entity.id)&.share_price&.price.to_i / 2
            "Stock Buyback — #{@game.format_currency(amount)} bond; " \
              "shareholders receive #{@game.format_currency(half)} per cert + halved certificate"
          end

          def choices
            { 'execute' => 'Execute buyback' }
          end

          def process_choose(action)
            entity = action.entity
            @game.record_bond!(entity)
            @game.execute_buyback_payout!(entity)
            pass!
          end

          def process_pass(_action)
            pass!
          end

          def log_skip(_entity)
            # silent skip — only floated corps in phase 3+ will see this
          end

          private

          def buyback_available?(entity)
            @game.phase.name.to_i >= 3 &&
              !@game.buyback_done?(entity) &&
              !entity.share_price.nil?
          end
        end
      end
    end
  end
end
