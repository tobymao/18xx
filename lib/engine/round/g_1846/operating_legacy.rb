# frozen_string_literal: true

require_relative '../operating'
require_relative '../../token'

module Engine
  module Round
    module G1846
      class OperatingLegacy < Operating
        MINOR_STEPS = %i[
          token_or_track
          route
          dividend
        ].freeze

        STEPS = %i[
          issue
          token_or_track
          route
          dividend
          train
          company
        ].freeze

        STEP_DESCRIPTION = {
          issue: 'Issue or Redeem Shares',
          token_or_track: 'Place a Token or Lay Track',
          route: 'Run Routes',
          dividend: 'Pay or Withhold Dividends',
          train: 'Buy Trains',
          company: 'Purchase Companies',
        }.freeze

        SHORT_STEP_DESCRIPTION = {
          issue: 'Issue/Redeem',
          token_or_track: 'Token/Track',
          route: 'Routes',
          train: 'Train',
          company: 'Company',
        }.freeze

        def steps
          @current_entity.minor? ? self.class::MINOR_STEPS : self.class::STEPS
        end

        private

        def ignore_action?(action)
          return false if action.is_a?(Action::SellShares) && action.entity.corporation?

          case action
          when Action::PlaceToken, Action::LayTile
            return true if !skip_token || !skip_track
          end

          super
        end

        def count_actions(type)
          @current_actions.count { |action| action.is_a?(type) }
        end

        def process_buy_company(action)
          super

          company = action.company
          return unless (minor = @game.minor_by_id(company.id))
          raise GameError, 'Cannot buy minor because train tight' unless corp_has_room?

          cash = minor.cash
          minor.spend(cash, @current_entity) if cash.positive?
          train = minor.trains[0]
          train.buyable = true
          @current_entity.buy_train(train, :free)
          minor.tokens[0].swap!(Token.new(@current_entity))
          @log << "#{@current_entity.name} receives #{@game.format_currency(cash)}"\
            ", a 2 train, and a token on #{minor.coordinates}"
          @game.minors.delete(minor)
          @graph.clear
        end
      end
    end
  end
end
