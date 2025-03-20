# frozen_string_literal: true

require_relative '../../g_1858/step/buy_train'

module Engine
  module Game
    module G1858India
      module Step
        class BuyTrain < G1858::Step::BuyTrain
          def actions(entity)
            return super unless can_buy_company?(entity)

            super | %w[buy_company pass]
          end

          def buyable_trains(entity)
            trains = super
            trains.reject! { |t| @game.mail_train?(t) } unless can_buy_mail_train?(entity)
            return trains unless at_train_limit?(entity)

            trains.select { |train| @game.mail_train?(train) }
          end

          def process_buy_company(action)
            corporation = action.entity
            company = action.company
            price = action.price

            raise GameError, "Cannot buy #{company.name}" \
              unless @game.company_sellable(company)
            raise GameError, "Price must be #{@game.format_currency(company.value)}" \
              unless price == company.value

            company.owner = corporation
            corporation.companies << company
            corporation.spend(price, @game.bank)
            @log << "#{corporation.name} buys #{company.name} for "\
                    "#{@game.format_currency(price)}"
          end

          private

          def can_buy_mail_train?(entity)
            !@game.owns_mail_train?(entity)
          end

          def room?(entity, _shell = nil)
            super || !@game.owns_mail_train?(entity)
          end

          def at_train_limit?(entity)
            @game.num_corp_trains(entity) == @game.train_limit(entity)
          end

          def can_buy_company?(entity)
            return false unless entity == current_entity
            return false if entity.minor?
            return false if owns_loco_works?(entity)
            return false unless @game.phase.status.include?('loco_works')

            companies = @game.purchasable_companies(entity)
            !companies.empty? && companies.map(&:value).min <= entity.cash
          end

          def owns_loco_works?(corporation)
            corporation.companies.any? { |company| !private_railway?(company) }
          end
        end
      end
    end
  end
end
