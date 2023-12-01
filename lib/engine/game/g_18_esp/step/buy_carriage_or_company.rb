# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18ESP
      module Step
        class BuyCarriageOrCompany < Engine::Step::BuyCompany
          def actions(entity)
            return [] if !entity.corporation? || entity != current_entity

            actions = []
            actions << 'buy_company' if can_buy_company?(entity)
            actions << 'special_buy' if can_buy_carriage?(entity)
            actions << 'pass' if blocks?
            actions
          end

          def description
            'Buy Tender or Company'
          end

          def can_buy_carriage?(entity)
            return false unless entity

            # have p4 ability left, have carriage cost bucks, doesn't own carriage
            !@game.luxury_ability(entity) &&
            @game.luxury_carriages_count.positive? &&
            entity.cash >= @game.class::CARRIAGE_COST
          end

          def buyable_items(_entity)
            owner = @game.p4&.owner&.player? ? @game.p4&.owner : @game.bank
            [Item.new(description: "Tender from #{owner.name}", cost: @game.class::CARRIAGE_COST)]
          end

          def short_description
            'Buy Tender or Company'
          end

          def blocks?
            @opts[:blocks] && (can_buy_carriage?(current_entity) || can_buy_company?(current_entity))
          end

          def process_special_buy(action)
            item = action.item
            payee = @game.p4&.owner&.player? ? @game.p4.owner : @game.bank
            @game.luxury_carriages_count -= 1

            luxury_ability = Ability::Base.new(
              type: 'base',
              owner_type: 'corporation',
              description: 'Tender',
              desc_detail: 'Allows to attach Tender to regular trains '\
                           'extending their distance by one town, harbor or mine.',
              when: 'owning_corp_or_turn'
            )
            action.entity.add_ability(luxury_ability)
            amount_spent = payee == @game.bank ? item.cost : 20
            action.entity.spend(20, payee)
            action.entity.spend(item.cost - 20, @game.bank)
            @log << "#{action.entity.name} buys a tender for #{@game.format_currency(item.cost)}. \
                     #{payee.name} receives #{@game.format_currency(amount_spent)}. \
                    There are #{@game.luxury_carriages_count} tenders left"
          end
        end
      end
    end
  end
end
