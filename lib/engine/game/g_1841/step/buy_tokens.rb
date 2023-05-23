# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1841
      module Step
        class BuyTokens < Engine::Step::Base
          def actions(entity)
            return [] unless entity == pending_entity

            %w[choose]
          end

          def active?
            pending_entity
          end

          def current_entity
            pending_entity
          end

          def pending_entity
            pending_buy[:entity]
          end

          def pending_price
            pending_buy[:price]
          end

          def pending_min
            pending_buy[:min]
          end

          def pending_max
            pending_buy[:max]
          end

          def pending_buy
            @round.buy_tokens&.first || {}
          end

          def description
            'Buy Tokens'
          end

          def process_choose(action)
            @game.purchase_tokens!(pending_entity, action.choice.to_i, pending_price)

            @round.buy_tokens.shift
          end

          def choice_available?(entity)
            pending_entity == entity
          end

          def choice_name
            'Number of Tokens to Buy'
          end

          def choices
            Array.new(pending_max - pending_min + 1) do |i|
              num = i + pending_min
              next if (num > pending_min) && ((num * pending_price) > pending_entity.cash)

              emr = pending_min * pending_price > pending_entity.cash ? ' - EMR' : ''

              [num, "#{num} (#{@game.format_currency(num * pending_price)}#{emr})"]
            end.compact.to_h
          end

          def visible_corporations
            [pending_entity]
          end

          def round_state
            super.merge(
              {
                buy_tokens: [],
              }
            )
          end
        end
      end
    end
  end
end
