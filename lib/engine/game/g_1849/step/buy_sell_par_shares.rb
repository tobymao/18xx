# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1849
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def setup
            super
            @game.old_operating_order = @game.corporations.sort
          end

          def process_par(action)
            super
            @log << "#{action.entity.name} may buy up to two additional shares."
          end

          def process_sell_shares(action)
            price_before = action.bundle.shares.first.price
            super
            return unless price_before != action.bundle.shares.first.price

            @game.moved_this_turn << action.bundle.corporation
            @moved_any = true
          end

          def pass!
            @passed = true
            if @current_actions.empty?
              @round.pass_order |= [current_entity]
              current_entity.pass!
            else
              @game.reorder_corps if @moved_any
              @round.pass_order.delete(current_entity)
              current_entity.unpass!
            end
            @game.old_operating_order = @game.corporations.sort
            @moved_any = false
          end

          def get_par_prices(entity, _corp)
            @game.par_prices.select { |p| p.price * 2 <= entity.cash }
          end

          def can_buy?(entity, bundle)
            super && @game.last_cert_last?(bundle)
          end

          def can_buy_any_from_ipo?(entity)
            @game.corporations.any? { |c| c.ipoed && can_buy?(entity, c.shares.min_by(&:percent)&.to_bundle) }
          end

          def can_buy_multiple?(entity, corp)
            super || (corp.owner == entity && just_parred(corp) && num_shares_bought(corp) < 2)
          end

          def just_parred(corporation)
            @current_actions.any? { |x| x.is_a?(Action::Par) && x.corporation == corporation }
          end

          def num_shares_bought(corporation)
            @current_actions.count { |x| x.is_a?(Action::BuyShares) && x.bundle.corporation == corporation }
          end
        end
      end
    end
  end
end
