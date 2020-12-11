# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G18CO
      class PresidentsChoice < Base
        include ShareBuying

        def actions(entity)
          return [] unless entity.player?
          return [] unless entity == current_entity

          available_actions = []

          available_actions << 'buy_shares' if can_buy_any?(entity)
          available_actions << 'pass' if available_actions.any?

          available_actions
        end

        def description
          'Buy Shares'
        end

        def pass_description
          'Leave Round'
        end

        def log_pass(entity)
          @log << "#{entity.name} leaves President's Choice round"
        end

        def log_skip(entity)
          @log << "#{entity.name} cannot buy any shares and leaves President's Choice round"
        end

        def process_buy_shares(action)
          buy_shares(action.entity, action.bundle, swap: action.swap)
          pass!
        end

        def buyable_shares(entity)
          @game.corporations.flat_map do |corporation|
            next unless corporation.president?(entity)

            corporation.corporate_shares.select { |s| can_buy?(entity, s.to_bundle) }
          end.compact
        end

        def can_buy_any?(entity)
          buyable_shares(entity).any?
        end

        # Returns if a share can be bought via a normal buy actions
        # If a player has sold shares they cannot buy in many 18xx games
        # Some 18xx games can only buy one share per turn.
        def can_buy?(entity, bundle)
          return unless bundle&.buyable
          return unless bundle.owner.corporation?

          corporation = bundle.corporation
          entity.cash >= bundle.price &&
            can_gain?(entity, bundle) &&
            bundle.owner.president?(entity) &&
            corporation != bundle.owner
        end

        def purchasable_companies
          []
        end

        def can_buy_corporate_shares?
          true
        end

        def can_buy_normal_shares?
          false
        end

        def can_sell?
          false
        end

        def can_ipo_any?(_entity)
          false
        end

        def ipo_type(_entity) end
      end
    end
  end
end
