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
            if @round.current_actions.empty?
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

          def can_buy_multiple?(entity, corp, _owner)
            super || (corp.owner == entity && just_parred(corp) && num_shares_bought(corp) < 2)
          end

          def just_parred(corporation)
            @round.current_actions.any? { |x| x.is_a?(Action::Par) && x.corporation == corporation }
          end

          def num_shares_bought(corporation)
            @round.current_actions.count { |x| x.is_a?(Action::BuyShares) && x.bundle.corporation == corporation }
          end

          def should_stop_applying_program(entity, program, share_to_buy)
            # The automatic program should stop if the 20% share is acquireable
            if !share_to_buy || !share_to_buy.last_cert
              @game.corporations.each do |corporation|
                share = corporation.ipo_shares.find(&:last_cert)
                share ||= @game.share_pool.shares_by_corporation[corporation].find(&:last_cert)
                if share && @game.last_cert_last?(share.to_bundle) && corporation.holding_ok?(entity, share.percent)
                  return "Last cert available for #{corporation.name}"
                end
              end
            end
            super
          end
        end
      end
    end
  end
end
