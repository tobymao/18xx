# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module GRollingStock
      module Step
        class CloseCompanies < Engine::Step::Base
          def actions(entity)
            return [] unless @round.entities.include?(entity)

            actions = []
            actions << 'sell_company' if can_close_any?(entity)
            actions << 'pass' if can_pass?(entity) && !must_close?(entity)
            actions
          end

          def description
            'Close Companies'
          end

          def can_pass?(entity)
            !entity.passed?
          end

          def must_close?(entity)
            return if entity.companies.empty?

            (entity.cash + entity.companies.sum { |c| @game.calculate_income(c) }).negative?
          end

          # is there a company that a corporation run by this player can afford and isn't
          # currently in a proposal?
          def can_close_any?(entity)
            return unless can_pass?(entity)

            !entity.companies.empty? || @game.corporations.any? { |c| c.owner == entity && c.companies.size > 1 }
          end

          def can_close?(entity, company)
            return unless company
            return unless entity.player?
            return true if entity.companies.include?(company)

            @game.corporations.each do |corp|
              next if corp.owner != entity || !corp.companies.include?(company)

              return corp.companies.size > 1
            end
            false
          end

          def process_pass(action)
            log_pass(action.entity)
            action.entity.pass!
          end

          def process_sell_company(action)
            entity = action.entity
            company = action.company
            raise GameError, "#{entity.name} cannot close #{company.sym}" unless can_close?(entity, company)

            @game.close_company(company)
            return if can_close_any?(entity)

            @log << "#{entity.name} has no more legal actions and must pass"
            entity.pass!
          end

          def offers
            []
          end

          def player_corporations(player)
            @game.corporations.select { |c| c.owner == player }
          end

          def active_entities
            @round.entities.reject(&:passed?)
          end

          def active?
            true
          end

          def blocking?
            true
          end
        end
      end
    end
  end
end
