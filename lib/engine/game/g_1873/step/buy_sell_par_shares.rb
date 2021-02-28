# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative '../../../step/share_buying'
require_relative '../../../action/buy_shares'
require_relative '../../../action/par'

module Engine
  module Game
    module G1873
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def description
            'Sell then Buy Certificates or Form Public Mine'
          end

          def purchasable_companies(_entity)
            []
          end

          # FIXME: need to deal with receivership first and second buy
          def can_buy_multiple?(_entity, corporation)
            return false unless @game.railway?(corporation)

            @current_actions.any? { |x| x.is_a?(Action::Par) && x.corporation == corporation } &&
              @current_actions.none? { |x| x.is_a?(Action::BuyShares) }
          end

          def can_sell?(entity, bundle)
            return unless bundle

            corporation = bundle.corporation

            timing = @game.check_sale_timing(entity, corporation)

            timing &&
              !(@game.class::MUST_SELL_IN_BLOCKS && @round.players_sold[entity][corporation] == :now) &&
              can_sell_order? &&
              (@game.share_pool.fit_in_bank?(bundle) || corporation == @game.mhe) &&
              can_dump?(entity, bundle) &&
              president_can_sell?(entity, corporation)
          end

          # president of corp can't dump unless someone else has 20% - even if president only has 10%
          # this may be the only reason we keep track of the presidents share
          def can_dump?(entity, bundle)
            corporation = bundle.corporation

            return true unless bundle.presidents_share
            return true if corporation == @game.mhe
            return false if !corporation.operated? && @game.railway?(corporation)

            sh = corporation.player_share_holders(corporate: true)
            (sh.reject { |k, _| k == entity }.values.max || 0) >= 20
          end

          # president of RR can never drop below 20% if it hasn't operated
          def president_can_sell?(entity, corporation)
            return true unless corporation.owner == entity
            return true if !@game.railway?(corporation) || corporation.operated? || corporation == @game.mhe

            corporation.share_holders[entity] > 20
          end

          def ipo_type(entity)
            if @game.railway?(entity)
              :par
            else
              :form
            end
          end

          def get_par_prices(entity, _corp)
            @game
              .stock_market
              .par_prices
              .select { |p| p.price <= entity.cash }
          end

          def process_buy_shares(action)
            corporation = action.bundle.corporation
            buy_shares(action.entity, action.bundle, swap: action.swap,
                                                     allow_president_change: @game.pres_change_ok?(corporation))
            track_action(action, corporation)
          end

          def process_par(action)
            corporation = action.corporation
            entity = action.entity

            if @game.railway?(corporation)
              super
              remove_company(entity, corporation)
              return
            end

            form_public_mine(entity, corporation)

            track_action(action, corporation)
          end

          def form_public_mine(entity, corporation)
            corporation.owner = entity
            @round.pending_forms << { corporation: corporation, owner: entity, targets: [] }
            @log << "Public Mining Company #{corporation.name} forms"
          end

          def remove_company(entity, corporation)
            co = @game.companies.find { |c| c.id == corporation.id }
            entity.companies.delete(co)
            co.owner = nil
          end
        end
      end
    end
  end
end
