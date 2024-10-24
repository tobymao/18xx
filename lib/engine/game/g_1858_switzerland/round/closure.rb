# frozen_string_literal: true

require_relative '../../g_1858/round/closure'

module Engine
  module Game
    module G1858Switzerland
      module Round
        class Closure < G1858::Round::Closure
          private

          # Is this the final private closure round?
          def last_pcr?
            @game.phase.name != '5'
          end

          def companies
            companies = @game.companies.reject(&:closed?)
            return companies if last_pcr?

            companies.reject { |company| company.color == :lightblue }
          end

          def minors
            minors = @game.minors.reject(&:closed?)
            return minors if last_pcr?

            minors.reject { |minor| minor.color == :lightblue }
          end
        end
      end
    end
  end
end
