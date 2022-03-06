# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module GRollingStock
      module Step
        class ProposeAndPurchase < Engine::Step::Base
          def actions(entity)
            return [] unless @round.entities.include?(entity)

            actions = []
            actions << 'propose' if can_propose_any?(entity)
            actions << 'respond' if can_respond_any?(entity)
            actions << 'pass' if can_pass?(entity)
            actions
          end

          def description
            'Propose, accept or reject acquisition offers'
          end

          def can_pass?(entity)
            !entity.passed?
          end

          # is there a company that a corporation run by this player can afford and isn't
          # currently in a proposal?
          def can_propose_any?(entity)
            return unless can_pass?(entity)

            @game.corporations.any? do |corp|
              next unless corp.owner == entity

              @game.companies.any? do |c|
                next unless c.owner
                next if c.owner.corporation? && c.owner.companies.one?
                next if company_in_any_proposal?(c)

                c.owner != corp && corp.cash >= c.min_price # FIXME: available cash
              end
            end
          end

          def can_propose?(entity, corporation, company)
            return unless company.owner
            return if company.owner.corporation? && company.owner.companies.one?
            return if company_in_any_proposal?(company)

            company.owner != corporation && corporation.cash >= company.min_price # FIXME: available cash
          end

          def can_respond_any?(entity)
            responder_in_any_proposal?(entity)
          end

          def company_in_any_proposal?(company)
            return false unless company.company?

            @round.proposals.any? { |prop| prop[:company] == company }
          end
      
          def responder_in_any_proposal?(entity)
            return false unless entity.player?

            @round.proposals.any? { |prop| prop[:responder] == entity }
          end

          def process_pass(action)
            puts "process_pass(#{action.entity.name})"
            log_pass(action.entity)
            action.entity.pass!
          end

          def process_propose(action)
          end

          def process_respond(action)
          end

          def player_corporations(player)
            @game.corporations.select { |c| c.owner == player }
          end

          def active_entities
            @round.entities
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
