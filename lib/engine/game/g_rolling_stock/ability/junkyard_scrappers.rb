# frozen_string_literal: true

require_relative '../../../ability/base'

module Engine
  module Game
    module GRollingStock
      module Ability
        class JunkyardScrappers < Engine::Ability::Base
          def description
            'Income on Closing'
          end

          def desc_detail
            'When it closes a company, it receives twice the printed income of that company as a scrapping bonus'
          end
        end
      end
    end
  end
end
