# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class AcquireCompany < Base
      ACTIONS = %w[acquire_company pass].freeze

      def actions(entity)
        return [] unless entity == current_entity
        return ACTIONS if can_acquire_company?(entity)

        []
      end

      def can_acquire_company?(entity)
        !@game.purchasable_companies(entity).empty?
      end

      def description
        'Acquire private companies'
      end

      def pass_description
        @acted ? 'Done (Acquire companies)' : 'Skip (Acquire companies)'
      end

      def process_acquire_company(action)
        entity = action.entity
        company = action.company

        owner = company.owner
        owner&.companies&.delete(company)

        company.owner = entity
        entity.companies << company

        @round.acquired_companies << company

        @log << "#{entity.name} acquires #{company.name} from #{owner.name}"
        @game.company_bought(company, entity)

        pass! if @game.purchasable_companies(entity).empty?
      end

      def round_state
        { acquired_companies: [] }
      end
    end
  end
end
