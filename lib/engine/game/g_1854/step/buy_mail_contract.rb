# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1854
      module Step
        class BuyMailContract < Engine::Step::Base
          ACTIONS = %w[buy_mail_contract pass].freeze

          def actions(entity)
            # TODO: This functionality is currently incomplete
            return [] if entity != current_entity
            return [] unless can_entity_buy_mail_contract?(entity)

            ACTIONS
          end

          def description
            'Buy Mail Contracts'
          end

          def pass_description
            'Skip (Mail Contract)'
          end

          def can_entity_buy_mail_contract?(entity)
            return false unless entity.corporation?
            return false if entity.minor?
          end

          def log_skip(entity)
            # no need to print out skip for minors, they can never
            # own mail contracts
            super unless entity.minor?
          end
        end
      end
    end
  end
end
