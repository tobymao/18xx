# frozen_string_literal: true

require_relative '../../g_1880/step/company_pending_par'
require_relative 'parrer'

module Engine
  module Game
    module G1880Romania
      module Step
        class CompanyPendingPar < G1880::Step::CompanyPendingPar
          include Parrer
        end
      end
    end
  end
end
