# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18NY
      module Step
        class SpecialCapitalization < Engine::Step::Base
          ACTIONS = %w[sell_shares pass].freeze

          def actions(entity)
            return [] unless entity.corporation?
            return [] if entity != current_entity
            return [] if issuable_shares(entity).empty?

            ACTIONS
          end

          def description
            'Special Capitalization'
          end

          def pass_description
            'Skip (Issue)'
          end

          def active?
            @game.capitalization_round
          end

          def active_entities
            @entities ||= @game.operating_order.select { |corp| corp.num_treasury_shares.positive? }
            [@entities[0]]
          end

          def process_sell_shares(action)
            @game.share_pool.sell_shares(action.bundle)
            next_entity!
            pass!
          end

          def process_pass(action)
            super
            next_entity!
          end

          def next_entity!
            @entities.shift
            @game.capitalization_round = nil if @entities.empty?
          end

          def issuable_shares(entity)
            # Done via Sell Shares
            @game.issuable_shares(entity)
          end
        end
      end
    end
  end
end
