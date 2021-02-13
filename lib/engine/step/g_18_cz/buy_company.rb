# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G18CZ
      class BuyCompany < Base
        def process_buy_company(action)
          entity = action.entity
          company = action.company
          owner = company.owner

          case entity.type
          when :medium
            raise GameError,
                  "Cannot buy #{company.name} from #{owner.name}" unless company.sym.include?('M') || company.sym.include?('S')
          when :small
            raise GameError, "Cannot buy #{company.name} from #{owner.name}" unless company.sym.include?('S')
          end

          super
        end
      end
    end
  end
end
