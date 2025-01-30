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

            # have p5 ability left, have carriage cost bucks, doesn't own carriage
            !@game.luxury_ability(entity) &&
            @game.luxury_carriages.values.sum.positive? &&
            entity.cash >= @game.class::CARRIAGE_COST
          end

          def buyable_items(_entity)
            items = []
            @game.luxury_carriages.each do |owner, amount|
              next unless amount.positive?
              next if owner != 'bank' && @game.company_by_id(owner).closed?

              owner_str = owner == 'bank' ? owner : @game.company_by_id(owner).owner.name
              items << Item.new(description: "Tender from #{owner_str}", cost: @game.class::CARRIAGE_COST)
            end
            items
          end

          def short_description
            'Buy Tender or Company'
          end

          def blocks?
            @opts[:blocks] && (can_buy_carriage?(current_entity) || can_buy_company?(current_entity))
          end

          def process_special_buy(action)
            item = action.item
            payee = item.description.include?('bank') ?  @game.bank : @game.p5.owner
            source = item.description.include?('bank') ? 'bank' : 'P5'
            @game.luxury_carriages[source] -= 1

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
                     #{payee.name} receives #{@game.format_currency(amount_spent)}."
          end
        end
      end
    end
  end
end
