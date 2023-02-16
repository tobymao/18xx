# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative '../../../step/tokener'

module Engine
  module Game
    module G1868WY
      module Step
        # a Stock Round action is one of the following:
        # - sell then buy
        # - choose new home for DPR after all its tokens BUST
        # - exchange Ames Bros private for UP double share, then may sell 1-2 of those shares
        class StockRoundAction < Engine::Step::BuySellParShares
          include Engine::Step::Tokener

          def description
            'Stock Round Action'
          end

          def help
            return @game.corp_stacks_str_arr unless @exchanged

            case @game.share_pool.percent_of(@game.union_pacific)
            when 0
              'You may sell both of the Ames Brothers shares'
            when (10..40)
              'You may sell one or both of the Ames Brothers shares'
            else
              ''
            end
          end

          def setup
            super
            @exchanged = false
            @exchanger = @game.ames_bros
          end

          def actions(entity)
            return %w[buy_shares] if can_exchange?(entity)
            return [] unless entity == current_entity
            return ['sell_shares'] if must_sell?(entity)

            actions = []
            actions << 'sell_shares' if can_sell_any?(entity)
            actions << 'buy_shares' if can_buy_any?(entity)
            actions << 'par' if can_ipo_any?(entity)
            actions << 'place_token' if can_token?(entity)
            actions << 'pass' unless actions.empty?

            actions
          end

          def get_par_prices(entity, _corp)
            @game.par_prices.select { |p| p.price * 2 <= entity.cash }
          end

          def visible_corporations
            @game.sr_visible_corporations
          end

          def map_action_optional?
            true
          end

          def initial_double_share_bundle?(bundle)
            bundle.shares == [@game.up_double_share] &&
              !bundle.buyable
          end

          def can_buy?(entity, bundle)
            return false if @exchanged

            if initial_double_share_bundle?(bundle)
              entity == @exchanger.owner &&
                can_gain?(entity, bundle, exchange: true)
            elsif bundle.shares.include?(@game.up_double_share) &&
                  bundle.owner == @game.share_pool &&
                  @game.share_pool.shares_of(@game.union_pacific).size > 1
              false
            else
              super
            end
          end

          def can_exchange?(entity, bundle = nil)
            return false if bought? || sold?
            return false unless entity == @exchanger
            return false unless @game.abilities(entity, :exchange)

            bundle ||= @game.up_double_share.to_bundle
            can_gain?(entity.owner, bundle, exchange: true)
          end

          def process_buy_shares(action)
            entity = action.entity
            player = entity.player
            bundle = action.bundle
            exchange = nil

            if entity == @exchanger
              unless can_exchange?(@exchanger, bundle)
                raise GameError, "Cannot exchange #{@exchanger.id} for #{bundle.corporation.id}"
              end

              exchange = @exchanger
            end

            buy_shares(player, bundle, swap: action.swap, exchange: exchange)

            if exchange
              @round.players_history[@exchanger.owner][bundle.corporation] << action
              @exchanger.close!
              @exchanged = true
              cash = 2 * bundle.corporation.share_price.price
              @game.bank.spend(cash, bundle.corporation)
              @log << "#{bundle.corporation.name} receives #{@game.format_currency(cash)}"
              @game.up_double_share.buyable = true
            end
            track_action(action, bundle.corporation)
          end

          def can_sell?(entity, bundle)
            @exchanged ? bundle.shares == [@game.up_double_share] : super
          end

          def process_sell_shares(action)
            player = action.entity
            bundle = action.bundle
            corporation = bundle.corporation
            swap = nil

            if bundle.partial?
              @log << "#{player.name} swaps the 20% UP certificate with a 10% UP certifcate from the Market to sell 10%"
              swap = @game.share_pool.shares_by_corporation[corporation].first
            end

            sell_shares(player, bundle)
            @game.share_pool.transfer_shares(swap.to_bundle, player) if swap
            track_action(action, corporation)
          end
        end
      end
    end
  end
end
