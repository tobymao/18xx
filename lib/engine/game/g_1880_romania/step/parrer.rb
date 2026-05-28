# frozen_string_literal: true

module Engine
  module Game
    module G1880Romania
      module Step
        module Parrer
          def private_company_president_corp?(corporation)
            corporation == @game.tr
          end

          def select_verb
            @parring[:corporation] == @game.tr ? 'receives' : 'selects'
          end

          def building_permit_log(permit)
            return "#{@parring[:corporation].name} is automatically assigned an #{permit} building permit" if
              @parring[:corporation] == @game.tr

            super
          end
        end
      end
    end
  end
end
