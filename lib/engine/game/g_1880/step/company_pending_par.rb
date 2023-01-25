# frozen_string_literal: true

require_relative '../../../step/company_pending_par'
require_relative 'parrer'

module Engine
  module Game
    module G1880
      module Step
        class CompanyPendingPar < Engine::Step::CompanyPendingPar
          include Parrer
        end
      end
    end
  end
end
