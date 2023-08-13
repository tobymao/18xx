# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'emergency_assist'

module Engine
  module Game
    module G1841
      module Step
        class BuyNewTokens < Engine::Step::Base
          include EmergencyAssist

          def actions(entity)
            return [] unless entity == pending_entity

            %w[choose]
          end

          def active?
            pending_entity
          end

          def active_entities
            [pending_entity]
          end

          def pending_entity
            pending_buy[:entity]
          end

          def pending_price
            pending_buy[:price]
          end

          def pending_first_price
            pending_buy[:first_price]
          end

          def pending_type
            pending_buy[:type]
          end

          def pending_min
            pending_buy[:min]
          end

          def pending_max
            pending_buy[:max]
          end

          def pending_corp
            pending_buy[:corp] || pending_entity
          end

          def pending_buy
            @round.buy_tokens&.first || {}
          end

          def description
            'Buy New Tokens'
          end

          def process_choose(action)
            num = action.choice.to_i
            total = price(num)
            type = pending_type
            entity = pending_entity
            @round.buy_tokens.shift

            case type
            when :start
              @game.purchase_tokens!(entity, num, total) # should never need token_emegency_money
            when :transform
              if entity.cash < total
                sweep_cash(entity, entity.player, total)
                raise GameError, "#{entity.name} does not have #{format_currency(total)} for token" if entity.cash < total
              end

              @game.purchase_additional_tokens!(entity, num, total)
              @game.transform_finish
            when :secession
              raise GameError, "#{entity.name} does not have #{format_currency(total)} for token" if entity.cash < total

              @game.purchase_additional_tokens!(entity, num, total)
              @game.secession_tokens_next
            end
          end

          def choice_available?(entity)
            pending_entity == entity
          end

          def choice_name
            return "Number of Additional Tokens to Buy for #{pending_corp.name}" if pending_type != :start

            "Number of Tokens to Buy for #{pending_corp.name}"
          end

          def price(num)
            return 0 if num.zero?

            pending_first_price + ((num - 1) * pending_price)
          end

          def choices
            Array.new(pending_max - pending_min + 1) do |i|
              num = i + pending_min
              total = price(num)
              next if (num > pending_min) && (total > pending_corp.cash)

              emr = total > pending_corp.cash ? ' - EMR' : ''

              [num, "#{num} (#{@game.format_currency(total)}#{emr})"]
            end.compact.to_h
          end

          def visible_corporations
            [pending_corp]
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
