# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1864
      module Step
        class UPShares < Engine::Step::Base
          ACTIONS = %w[buy_shares pass].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] if available_shares.empty?

            ACTIONS
          end

          def active?
            !@game.pending_up_share_buyers.empty?
          end

          def active_entities
            [current_entity].compact
          end

          def current_entity
            @game.pending_up_share_buyers.first&.fetch(:player)
          end

          def description
            'Buy Union Pacific shares'
          end

          def available_shares
            @game.union_pacific.shares.take(1)
          end

          def can_buy?(entity, bundle)
            return false unless bundle&.corporation == @game.union_pacific

            entity.cash >= bundle.price &&
              entity.percent_of(@game.union_pacific) + bundle.percent <= 60
          end

          def process_buy_shares(action)
            @game.share_pool.buy_shares(action.entity, action.bundle)
            decrement_or_pop
          end

          def process_pass(action)
            log_pass(action.entity)
            @game.pending_up_share_buyers.shift
          end

          def skip!
            return super unless available_shares.empty?

            while !@game.pending_up_share_buyers.empty? && available_shares.empty?
              buyer = @game.pending_up_share_buyers.shift
              @log << "#{buyer[:player].name} cannot buy Union Pacific shares - the IPO is empty"
            end
          end

          private

          def decrement_or_pop
            head = @game.pending_up_share_buyers.first
            head[:shares] -= 1
            @game.pending_up_share_buyers.shift unless head[:shares].positive?
          end
        end
      end
    end
  end
end
