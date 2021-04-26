# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module Round
        class Operating < Engine::Round::Operating
          def after_setup
            super

            @game.corporations.each do |corporation|
              corporation.all_abilities.each do |ability|
                next unless ability.is_a?(Engine::G18ZOO::Ability::DisableTrain)

                ability.train.operated = true
                corporation.remove_ability ability
              end

              next if !corporation.floated? || corporation.num_market_shares.zero?

              amount = corporation.num_market_shares * 2
              @game.bank.spend(amount, corporation, check_cash: false, check_positive: false)
              @log << "#{corporation.name} earns #{@game.format_currency(amount)}"\
                " (#{corporation.num_market_shares} certs inside kitchen)"
            end
          end
        end
      end
    end
  end
end
