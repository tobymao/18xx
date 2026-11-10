# frozen_string_literal: true

require_relative '../../../step/issue_shares'
require_relative 'skip_abbreviated_round'
require_relative '../../../action/choose'

module Engine
  module Game
    module G18OE
      module Step
        class IssueShares < Engine::Step::IssueShares
          include SkipAbbreviatedRound

          def setup
            super
            @bought_abandoned_minor = false
          end

          def actions(entity)
            return [] if skip?

            available_actions = super
            return available_actions unless can_buy_abandoned_minor?(entity)

            available_actions << 'choose' unless available_actions.include?('choose')
            available_actions << 'pass' unless available_actions.include?('pass')
            available_actions
          end

          def can_buy_abandoned_minor?(entity)
            entity == @round.current_operator &&
              entity.type == :major &&
              !@bought_abandoned_minor &&
              entity.cash >= @game.abandoned_minor_price &&
              !@game.abandoned_minors.empty?
          end

          def choice_corporations(entity)
            can_buy_abandoned_minor?(entity) ? @game.abandoned_minors : []
          end

          def entity_choices(target)
            return {} if !target&.corporation? || !@game.abandoned_minor?(target)

            { target.id => "Buy for #{@game.format_currency(@game.abandoned_minor_price)}" }
          end

          def choice_name
            nil
          end

          def description
            'Buy or Sell Shares'
          end

          def pass_description
            can_buy_abandoned_minor?(current_entity) ? 'Skip (Issue Shares/Buy Minor)' : 'Skip (Issue Shares)'
          end

          def log_skip(_entity); end

          def process_choose(action)
            entity = action.entity
            minor = @game.corporation_by_id(action.choice)
            raise GameError, "#{action.choice} is not an abandoned minor" if !minor || !@game.abandoned_minor?(minor)
            raise GameError, "#{entity.name} cannot buy an abandoned minor" unless can_buy_abandoned_minor?(entity)

            price = @game.abandoned_minor_price
            entity.spend(price, @game.bank)
            @log << "#{entity.name} buys abandoned minor #{minor.name} for #{@game.format_currency(price)}"
            @game.add_minor_charter!(minor, entity)
            @game.close_corporation(minor, quiet: true)
            @bought_abandoned_minor = true
          end

          def process_sell_shares(action)
            @game.sell_shares_and_change_price(action.bundle)
            pass! unless can_buy_abandoned_minor?(action.entity)
          end

          def process_buy_shares(action)
            @game.share_pool.buy_shares(action.entity, action.bundle)
            pass! unless can_buy_abandoned_minor?(action.entity)
          end
        end
      end
    end
  end
end
