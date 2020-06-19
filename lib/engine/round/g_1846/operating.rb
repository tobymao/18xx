# frozen_string_literal: true

require_relative '../operating'
require_relative '../../token'

module Engine
  module Round
    module G1846
      class Operating < Operating
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

        DIVIDEND_TYPES = %i[payout withhold half].freeze

        def select(entities, game, round_num)
          minors, corporations = entities.partition(&:minor?)
          corporations.select!(&:floated?)
          if game.turn == 1 && round_num == 1
            corporations.sort_by! do |c|
              sp = c.share_price
              [sp.price, sp.corporations.find_index(c)]
            end
          else
            corporations.sort!
          end
          minors + corporations
        end

        def steps
          @current_entity.minor? ? self.class::MINOR_STEPS : self.class::STEPS
        end

        def can_lay_track?
          @step == :token_or_track && !skip_track
        end

        def can_place_token?
          @step == :token_or_track && !skip_token
        end

        def issuable_shares
          num_shares = @current_entity.num_player_shares - @current_entity.num_market_shares
          bundles = @current_entity.bundles_for_corporation(@current_entity)
          share_price = @game.stock_market.find_share_price(@current_entity, :left).price

          bundles
            .each { |bundle| bundle.share_price = share_price }
            .reject { |bundle| bundle.num_shares > num_shares }
        end

        def redeemable_shares
          share_price = @game.stock_market.find_share_price(@current_entity, :right).price

          @game
            .share_pool
            .bundles_for_corporation(@current_entity)
            .each { |bundle| bundle.share_price = share_price }
            .reject { |bundle| @current_entity.cash < bundle.price }
        end

        def connected_hexes
          hexes = {}

          @current_entity.abilities(:token) do |ability, _|
            ability[:hexes].each do |id|
              hex = @game.hex_by_id(id)
              hexes[hex] = hex.neighbors.keys
            end
          end

          super.merge(hexes)
        end

        def connected_nodes
          nodes = {}

          @current_entity.abilities(:token) do |ability, _|
            ability[:hexes].each do |id|
              @game.hex_by_id(id).tile.cities.each { |c| nodes[c] = true }
            end
          end

          super.merge(nodes)
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

        def skip_token
          return true if count_actions(Action::PlaceToken).positive?

          super
        end

        def skip_track
          @current_entity.cash < @game.class::TILE_COST || count_actions(Action::LayTile) > 1
        end

        def skip_issue
          issuable_shares.empty? && redeemable_shares.empty?
        end

        def skip_dividend
          return super if @current_entity.corporation?

          revenue = @current_routes.sum(&:revenue)
          process_dividend(Action::Dividend.new(
            @current_entity,
            kind: revenue.positive? ? 'payout' : 'withhold',
          ))
          true
        end

        def skip_token_or_track
          skip_track && skip_token
        end

        def process_sell_shares(action)
          return super if action.entity.player?

          @game.share_pool.sell_shares(action.bundle)
        end

        def process_buy_shares(action)
          @game.share_pool.buy_shares(@current_entity, action.bundle)
        end

        def process_buy_company(action)
          super

          company = action.company
          return unless (minor = @game.minor_by_id(company.id))
          raise GameError, 'Cannot buy minor because train tight' unless corp_has_room?

          cash = minor.cash
          minor.spend(cash, @current_entity) if cash.positive?
          train = minor.trains[0]
          @current_entity.buy_train(train, :free)
          minor.tokens[0].swap!(Token.new(@current_entity))
          @log << "#{@current_entity.name} receives #{@game.format_currency(cash)}"\
            ", a 2 train, and a token on #{minor.coordinates}"
          @game.minors.delete(minor)
          @graph.clear
        end

        def tile_cost(tile, abilities)
          [@game.class::TILE_COST, tile.upgrade_cost(abilities)].max
        end

        def payout(revenue)
          return super if @current_entity.corporation?

          @log << "#{@current_entity.name} pays out #{@game.format_currency(revenue)}"

          amount = revenue / 2

          [@current_entity, @current_entity.owner].each do |entity|
            @log << "#{entity.name} receives #{@game.format_currency(amount)}"
            @bank.spend(amount, entity)
          end
        end

        def potential_tiles(hex)
          return [] if used_teleport(hex) && !connected(hex)

          super
        end

        def place_token(action)
          hex = action.city.hex

          if used_teleport(hex)
            higher =
              case @current_entity.id
              when 'B&O'
                100
              when 'PRR'
                60
              end
            action.token.price = connected(hex) ? 40 : higher
            @current_entity.remove_ability(:token)
          end

          super
        end

        def connected(hex)
          @graph.connected_hexes(@current_entity)[hex]
        end

        def used_teleport(hex)
          @current_entity.abilities(:token) do |ability, _|
            return true if ability[:hexes].include?(hex.id)
          end

          false
        end

        def half(revenue)
          withheld = revenue / 2 / 10 * 10
          @bank.spend(withheld, @current_entity)
          @log << "#{@current_entity.name} runs for #{@game.format_currency(revenue)} and pays half"
          @log << "#{@current_entity.name} witholds #{@game.format_currency(withheld)}"
          payout(revenue - withheld)
        end

        def change_share_price(revenue)
          return if @current_entity.minor?

          price = @current_entity.share_price.price
          @stock_market.move_left(@current_entity) if revenue < price / 2
          @stock_market.move_right(@current_entity) if revenue >= price
          @stock_market.move_right(@current_entity) if revenue >= price * 2
          @stock_market.move_right(@current_entity) if revenue >= price * 3 && price >= 165
          log_share_price(@current_entity, price)
        end
      end
    end
  end
end
