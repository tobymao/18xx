# frozen_string_literal: true

require_relative '../base'
require_relative '../share_buying'
require_relative '../../action/buy_company.rb'
require_relative '../../action/buy_shares'
require_relative '../../action/par'

module Engine
  module Step
    module G1860
      class BuySellParShares < BuySellParShares
        include ShareBuying

        def actions(entity)
          return [] unless entity == current_entity
          return ['sell_shares'] if must_sell?(entity)

          actions = []
          actions << 'buy_shares' if can_buy_any?(entity)
          actions << 'par' if can_ipo_any?(entity)
          actions << 'buy_company' if can_buy_any_companies?(entity)
          actions << 'sell_shares' if can_sell_any?(entity)
          actions << 'sell_company' if can_sell_any_companies?(entity)

          actions << 'pass' if actions.any?
          actions
        end

        def description
          'Sell then Buy Certificates'
        end

        def pass_description
          if @current_actions.empty?
            'Pass (Certificates)'
          else
            'Done (Certificates)'
          end
        end

        def purchasable_companies(_entity)
          []
        end

        def can_buy_company?(player, company)
          !did_sell?(company, player)
        end

        def can_buy_any_companies?(entity)
          return false if bought? ||
            !entity.cash.positive? ||
            @game.num_certs(entity) >= @game.cert_limit

          @game.companies.select { |c| c.owner == @game.bank }.reject { |c| did_sell?(c, entity) }.any?
        end

        def get_par_prices(_entity, corp)
          @game.par_prices(corp)
        end

        def process_buy_shares(action)
          super

          corporation = action.bundle.corporation
          place_home_track(corporation) if corporation.floated?
          @game.check_new_layer
        end

        def process_buy_company(action)
          player = action.entity
          company = action.company
          price = action.price
          owner = company.owner

          @game.game_error("Cannot buy #{company.name} from #{owner.name}") unless owner == @game.bank

          company.owner = player

          player.companies << company
          player.spend(price, owner)
          @current_actions << action
          @log << "#{player.name} buys #{company.name} from #{owner.name} for #{@game.format_currency(price)}"

          @game.close_other_companies!(company) if company.sym == 'FFC'
        end

        # Returns if a share can be bought via a normal buy actions
        # If a player has sold shares they cannot buy in many 18xx games
        def can_buy?(entity, bundle)
          return unless bundle&.buyable

          corporation = bundle.corporation
          entity.cash >= bundle.price && can_gain?(entity, bundle) &&
            !@round.players_sold[entity][corporation] &&
            (can_buy_multiple?(entity, corporation) || !bought?) &&
            can_buy_presidents_share?(entity, bundle, corporation)
        end

        # can only buy president's share if player already has at least one share
        def can_buy_presidents_share?(entity, share, corporation)
          return true if share.percent != corporation.presidents_percent ||
                         share.owner != @game.share_pool

          difference = share.percent - corporation.share_percent
          num_shares_needed = difference / corporation.share_percent
          existing_shares = entity.percent_of(corporation) || 0
          existing_shares > num_shares_needed
        end

        def can_sell?(entity, bundle)
          return unless bundle

          can_sell_order? &&
            @game.share_pool.fit_in_bank?(bundle) &&
            can_dump?(entity, bundle)
        end

        # can't sell partial president's share to pool if pool is empty
        def can_dump?(entity, bundle)
          corp = bundle.corporation
          return true if !bundle.presidents_share || bundle.percent >= corp.presidents_percent

          max_shares = corp.player_share_holders.reject { |p, _| p == entity }.values.max || 0
          return true if max_shares > 10

          pool_shares = @game.share_pool.percent_of(corp) || 0
          pool_shares.positive?
        end

        def process_sell_company(action)
          company = action.company
          player = action.entity
          @game.game_error("Cannot sell #{company.id}") unless can_sell_company?(company)

          sell_company(player, company, action.price)
          @round.last_to_act = player
        end

        def sell_price(entity)
          return 0 unless can_sell_company?(entity)

          entity.value - 30
        end

        def can_sell_any_companies?(entity)
          !bought? && sellable_companies(entity).any?
        end

        def sellable_companies(entity)
          return [] unless @game.turn > 1
          return [] unless entity.player?

          entity.companies
        end

        def can_sell_company?(entity)
          return false unless entity.company?
          return false if entity.owner == @game.bank
          return false unless @game.turn > 1

          true
        end

        def sell_company(player, company, price)
          company.owner = @game.bank
          player.companies.delete(company)
          @game.bank.spend(price, player) if price.positive?
          @log << "#{player.name} sells #{company.name} to bank for #{@game.format_currency(price)}"
          @round.players_sold[player][company] = :now
        end

        def place_home_track(corporation)
          hex = @game.hex_by_id(corporation.coordinates)
          tile = hex.tile

          # skip if a tile is already in home location
          return unless tile.color == :white

          @log << "#{corporation.name} must choose tile for home location"

          @round.pending_tracks << {
            entity: corporation,
            hexes: [hex],
          }

          @round.clear_cache!
        end
      end
    end
  end
end
