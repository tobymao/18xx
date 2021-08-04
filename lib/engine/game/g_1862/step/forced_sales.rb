# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1862
      module Step
        class ForcedSales < Engine::Step::BuySellParShares
          def round_state
            super.merge(
              {
                pending_forced_sales: [],
              }
            )
          end

          def actions(entity)
            return [] unless entity == pending_entity

            ['sell_shares']
          end

          def description
            'Forced Sale of Assets'
          end

          def active_entities
            [pending_entity]
          end

          def active?
            pending_entity
          end

          def pending_entity
            pending_forced_sale[:entity]
          end

          def pending_forced_sale
            @round.pending_forced_sales&.first || {}
          end

          def can_sell?(entity, bundle)
            return unless bundle

            can_dump?(entity, bundle)
          end

          # can't sell partial president's share to pool if pool doesn't have enough
          def can_dump?(entity, bundle)
            corp = bundle.corporation
            return true if !bundle.presidents_share || bundle.percent >= corp.presidents_percent

            max_shares = corp.player_share_holders.reject { |p, _| p == entity }.values.max || 0
            return true if max_shares >= corp.presidents_percent

            diff = bundle.shares.sum(&:percent) - bundle.percent

            pool_shares = @game.share_pool.percent_of(corp) || 0
            pool_shares >= diff
          end

          def process_sell_shares(action)
            entity = action.entity
            sell_shares(entity, action.bundle, swap: action.swap)

            if entity.cash < pending_forced_sale[:amount]
              pending_forced_sale[:amount] = pending_forced_sale[:amount] - entity.cash
              entity.spend(entity.cash, @game.bank)
              if can_sell_any?(entity)
                @log << "#{entity.name} still owes #{@game.format_currency(pending_forced_sale[:amount])}"
              else
                @log << "#{entity.name} has no more sellable assets. Remainder of debt is forgiven."
                @round.pending_forced_sales.shift
              end
            else
              entity.spend(pending_forced_sale[:amount], @game.bank)
              @log << "#{entity.name} has repaid obligation debt"
              @round.pending_forced_sales.shift
            end
          end

          def visible_corporations
            entity = pending_entity
            entity.shares_by_corporation.keys.reject { |c| entity.shares_of(c).empty? }
          end
        end
      end
    end
  end
end
