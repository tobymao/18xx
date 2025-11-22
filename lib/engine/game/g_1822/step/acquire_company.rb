# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G1822
      module Step
        class AcquireCompany < Engine::Step::AcquireCompany
          def help
            return if current_entity.owner.companies.count { |c| @game.company_header(c) == 'PRIVATE COMPANY' }.zero?

            'Reminder: unacquired private companies count against your certificate limit.'
          end
        end
      end
    end
  end
end
