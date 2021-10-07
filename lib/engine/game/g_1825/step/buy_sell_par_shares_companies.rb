# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares_companies'

module Engine
  module Game
    module G1825
      module Step
        class BuySellParSharesCompanies < Engine::Step::BuySellParSharesCompanies
          def actions(entity)
            return [] unless entity == current_entity
            return super unless must_sell?(entity)
            return %w[sell_shares sell_company] if can_sell_any_companies?(entity)

            ['sell_shares']
          end

          # only purchase actions count for keeping the round going and for determining priority deal
          def pass!
            super
            if bought?
              @round.pass_order.delete(current_entity)
              current_entity&.unpass!
            else
              @round.pass_order |= [current_entity]
              current_entity&.pass!
            end
          end

          def get_par_prices(entity, corp)
            return super unless @game.minor?(corp)

            @game.par_prices(corp).reject { |p| p.price * 4 > entity.cash }
          end

          def can_buy_any_companies?(entity)
            return false if bought? ||
              !entity.cash.positive? ||
              @game.num_certs(entity) >= @game.cert_limit

            @game.companies.any? { |c| (!c.owner || c.owner == @game.bank) && !did_sell?(c, entity) }
          end

          # illegal to buy and then sell stock in same corporation in the same turn
          def can_sell?(entity, bundle)
            return unless bundle
            return false if entity != bundle.owner

            corp = bundle.corporation
            bought_this = @round.current_actions.uniq(&:class).size.positive? &&
              ((@round.current_actions.last.instance_of?(Action::Par) &&
                @round.current_actions.last.corporation == corp) ||
               (@round.current_actions.last.instance_of?(Action::BuyShares) &&
                @round.current_actions.last.bundle.corporation == corp))
            return false if bought_this

            super
          end

          def process_sell_shares(action)
            super

            @game.check_bank_broken!
          end

          def process_buy_shares(action)
            super

            @game.check_formation(action.bundle.corporation)
          end

          def process_par(action)
            super

            # possible for a minor to form on par
            @game.check_formation(action.corporation)
          end

          def process_buy_company(action)
            player = action.entity
            company = action.company
            price = action.price
            owner = company.owner || @game.bank

            raise GameError, "Cannot buy #{company.name} from #{owner.name}" unless owner == @game.bank

            company.owner = player

            player.companies << company
            player.spend(price, owner)
            track_action(action, company)
            @log << "#{player.name} buys #{company.name} from #{owner.name} for #{@game.format_currency(price)}"
            @game.check_new_layer
          end

          def process_sell_company(action)
            super

            @game.check_bank_broken!
          end

          def visible_corporations
            @game.unbought_companies.empty? ? @game.sorted_corporations : []
          end
        end
      end
    end
  end
end
