# frozen_string_literal: true

require_relative '../../../step/buy_company'

module Engine
  module Game
    module G18CZ
      module Step
        class BuyCompany < Engine::Step::BuyCompany
          def process_buy_company(action)
            entity = action.entity
            company = action.company

            case entity.type
            when :medium
              unless company.sym.include?('M') || company.sym.include?('S')
                raise GameError, "#{entity.name} can only buy #{entity.type} companies or smaller"
              end
            when :small
              unless company.sym.include?('S')
                raise GameError,
                      "#{entity.name} can only buy #{entity.type} companies"
              end
            end

            super
          end
        end
      end
    end
  end
end
