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

          def setup
            @reopened = nil
            super
          end

          def purchasable_companies(_entity)
            []
          end

          def can_ipo_any?(entity)
            !bought? && @game.corporations.any? do |c|
              @game.can_par?(c, entity) && (@game.public_mine?(c) || can_buy?(entity, c.shares.first&.to_bundle))
            end
          end

          def can_buy?(entity, bundle)
            corp = bundle.corporation
            return if corp.receivership? && !@game.can_restart?(corp, entity)

            super
          end

          def can_buy_multiple?(entity, corporation, _owner)
            return unless corporation.corporation?

            if @reopened == corporation
              entity.percent_of(corporation) < 40
            elsif @game.railway?(corporation)
              @round.current_actions.any? { |x| x.is_a?(Action::Par) && x.corporation == corporation } &&
                @round.current_actions.none? { |x| x.is_a?(Action::BuyShares) }
            else
              false
            end
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

          # president of corp can't dump unless someone else has 20% - even with a president cert of 10%
          def can_dump?(entity, bundle)
            @game.dumpable?(bundle, entity)
          end

          # president of RR can never drop below 20% if it hasn't finished it's concession (operated)
          # or nobody else has at least 20%
          def president_can_sell?(entity, corporation)
            return true unless corporation.owner == entity
            return true if !@game.concession_pending?(corporation) || corporation == @game.mhe

            corporation.share_holders[entity] > 20
          end

          def ipo_type(entity)
            if @game.railway?(entity)
              :par
            else
              :form
            end
          end

          def get_par_prices(entity, corp)
            @game
              .stock_market
              .par_prices
              .select { |p| p.price <= entity.cash || @game.public_mine?(corp) }
          end

          def pool_shares(corporation)
            if corporation.receivership? && corporation != @game.mhe && corporation.total_shares == 10
              shares = @game.share_pool.shares_by_corporation[corporation].reject(&:president).reverse
              # offer 20% bundle
              [ShareBundle.new(shares.take(2))]
            else
              @game.share_pool.shares_by_corporation[corporation].group_by(&:percent).values
                .map(&:first).sort_by(&:percent).reverse
            end
          end

          def process_buy_shares(action)
            corporation = action.bundle.corporation
            was_receivership = corporation.receivership? && corporation != @game.mhe
            buy_shares(action.entity, action.bundle, swap: action.swap,
                                                     allow_president_change: @game.pres_change_ok?(corporation))
            if was_receivership
              @reopened = corporation
              remove_company(action.entity, corporation)
            end
            track_action(action, corporation)
          end

          def process_par(action)
            corporation = action.corporation
            entity = action.entity

            if @game.railway?(corporation)
              super
              remove_company(entity, corporation)
              @game.replace_company!(corporation)
              return
            end

            form_public_mine(entity, corporation)

            track_action(action, corporation)
          end

          def form_public_mine(entity, corporation)
            corporation.owner = entity
            @round.pending_forms << { corporation: corporation, owner: entity, targets: [] }
            @log << "#{entity.name} forms Public Mining Company #{corporation.name}"
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
