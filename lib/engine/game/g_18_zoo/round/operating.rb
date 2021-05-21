# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module Round
        class Operating < Engine::Round::Operating
          def after_setup
            super

            @game.corporations.each do |corporation|
              if (ability = @game.abilities(corporation, :disable_train))
                if ability.used?
                  corporation.remove_ability(ability)
                else
                  ability.train.operated = true
                  ability.use!
                end
              end

              next if !corporation.floated? || corporation.num_market_shares.zero?

              amount = corporation.num_market_shares * 2
              @game.bank.spend(amount, corporation, check_cash: false, check_positive: false)
              @log << "#{corporation.name} earns #{@game.format_currency(amount)}"\
                " (#{corporation.num_market_shares} certs in the Market)"
            end
          end
        end
      end
    end
  end
end
