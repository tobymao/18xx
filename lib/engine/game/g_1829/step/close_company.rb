# frozen_string_literal: true

module Engine
  module Game
    module G1829
      module Step
        class CloseCompanyVoluntary < Engine::Step::BuyTrain
          def process_close_company(_action)
            @log << "#{company.name} is closed."
            company.close!
          end
        end
      end
    end
  end
end
