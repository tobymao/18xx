# frozen_string_literal: true

module Engine
  module Game
    module G1804
      module Step
        class ExploratoryCommittee < Engine::Step::Base
          def setup
            return if @round.instance_variable_defined?(:@exploratory_committee_done)

            @round.instance_variable_set(:@exploratory_committee_done, true)

            @game.corporations.each do |corp|
              next if !corp.par_price || corp.floated?

              amount = corp.par_price.price
              @game.bank.spend(amount, corp)
              @game.log << "#{corp.name} receives $#{amount} from the bank (par price) because it is parred but not yet floated"
            end
          end

          def actions(_entity)
            []
          end

          def active?
            false
          end

          def skip!; end
        end
      end
    end
  end
end
