# frozen_string_literal: true

require_relative '../../../step/simple_draft'

module Engine
  module Game
    module G18Cuba
      module Step
        class SimpleDraft < Engine::Step::SimpleDraft
          def setup
            super
            @companies = @game.concessions.sort
            @finished = false
          end

          def may_purchase?(company)
            @game.concessions.include?(company)
          end

          def description
            'Draft Concessions'
          end

          def finished?
            @game.players.all? { |p| p.companies.any? { |c| c.id.start_with?(@game.class::COMPANY_CONCESSION_PREFIX) } }
          end

          def max_bid(_entity, company)
            may_purchase?(company) ? min_bid(company) : 0
          end
        end
      end
    end
  end
end
