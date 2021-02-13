# frozen_string_literal: true

require_relative '../buy_company'

module Engine
  module Step
    module G18CZ
      class BuyCompany < BuyCompany
        def process_buy_company(action)
          entity = action.entity
          company = action.company

          case entity.type
          when :medium
            unless company.sym.include?('M') || company.sym.include?('S')
              raise GameError, "#{entity.name} can only buy #{entity.type} companies or smaller"
            end
          when :small
            raise GameError, "#{entity.name} can only buy #{entity.type} companies" unless company.sym.include?('S')
          end

          super
        end
      end
    end
  end
end
