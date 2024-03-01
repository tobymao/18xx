# frozen_string_literal: true

require_relative '../../../step/corporate_sell_shares'
require_relative '../../../step/share_buying'
require_relative '../../../action/corporate_sell_shares'
require_relative '../../../action/corporate_sell_company'

module Engine
  module Game
    module G18India
      module Step
        class CorporateSellSharesCompany < Engine::Step::CorporateSellShares
          include Engine::Step::ShareBuying

          def description
            'Corporate Sell Certificates to Market'
          end

          # Can sell any / all shares and companies, no restriction on purchases later
          def actions(entity)
            return [] unless entity == current_entity

            actions = []
            actions << 'corporate_sell_shares' if can_sell_any?(entity)
            actions << 'corporate_sell_company' if can_sell_any_companies?(entity)
            actions << 'pass' if actions.any?

            actions
          end

          # ------ Sell Companies (new methods) ------

          def can_sell_any_companies?(entity)
            sellable_companies(entity).any?
          end

          def sellable_companies(entity)
            return [] unless entity.corporation?

            entity.companies.select { |c| c.type == :private || c.type == :bond }
          end

          def can_sell_company?(company)
            return false unless company.company?
            return false if company.owner != current_entity

            company.type == :private || company.type == :bond
          end

          def process_corporate_sell_company(action)
            company = action.company
            corp = action.entity
            raise GameError, "Cannot sell #{company.id}" unless can_sell_company?(company)

            sell_company(corp, company, action.price, @game.bank)
          end

          def sell_price(company)
            return 0 unless can_sell_company?(company)

            company.value - @game.class::COMPANY_SALE_FEE
          end

          def sell_company(corp, company, price, bank)
            company.owner = bank
            bank.companies.push(company)
            corp.companies.delete(company)
            bank.spend(price, corp) if price.positive?
            @log << "#{corp.name} sells #{company.name} to the Bank for #{@game.format_currency(price)}"
          end

          # ----- Sell Shares -----

          # There are no restrictions on sales. Any amount can be sold to market
          def can_sell?(entity, bundle)
            return unless bundle
            return false if entity != bundle.owner

            true
          end

          # modify to sell to market
          def process_corporate_sell_shares(action)
            @game.sell_shares_and_change_price(action.bundle, swap: action.swap)
          end

          # Source for items in View::Game::CorporateSellShares, removed restrictions on sales
          def source_list(entity)
            entity.corporate_shares.map(&:corporation).compact.uniq
          end

          # Added for a hook in View::Game::Round::Operating
          def corporate_stock_round?
            true
          end
        end
      end
    end
  end
end
