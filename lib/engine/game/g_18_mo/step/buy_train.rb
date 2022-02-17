# frozen_string_literal: true

require_relative '../../g_1846/step/buy_train'

module Engine
  module Game
    module G18MO
      module Step
        class BuyTrain < G1846::Step::BuyTrain
          def buyable_train_variants(train, entity)
            return [] unless buyable_trains(entity).any? { |bt| bt.variants[bt.name] }

            variants = train.variants.values
            return variants if train.owned_by_corporation?

            ability = @game.abilities(entity, :train_discount, time: ability_timing)
            variants.reject! { |v| entity.cash < min_price_variant(v, ability) } if must_issue_before_ebuy?(entity)
            return variants if variants.size < 2

            min, max = variants.sort_by { |v| v[:price] }
            return [min] if ((min_price_variant(min, ability) <= entity.cash) &&
                             (entity.cash < min_price_variant(max, ability))) || entity.receivership?

            if (last_cash_raised = @last_share_sold_price || @last_share_issued_price)
              must_spend = entity.cash - last_cash_raised + 1
              must_spend += entity.owner.cash if @last_share_sold_price
              variants.reject! { |v| v[:price] < must_spend }
            end

            variants
          end

          def min_price_variant(variant, ability)
            return variant[:price] unless ability
            return variant[:price] unless ability.trains.include?(variant[:name])

            variant[:price] - ability.discount
          end
        end
      end
    end
  end
end
