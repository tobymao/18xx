# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18VA
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def actions(entity)
            return [] unless entity == current_entity
            return ['sell_shares'] if must_sell?(entity)
            return ['choose'] if @parred && !@corporation_size

            actions = []
            actions << 'buy_shares' if can_buy_any?(entity)
            actions << 'par' if can_ipo_any?(entity)
            actions << 'buy_company' unless purchasable_companies(entity).empty?
            actions << 'sell_shares' if can_sell_any?(entity)

            actions << 'pass' unless actions.empty?
            actions
          end

          def active_entities
            return [@parred.entity] if @parred

            super
          end

          def choice_name
            'Number of Shares'
          end

          def choices
            @game.phase.corporation_sizes
          end

          def pass!
            return par_corporation if @parred

            super
          end

          def process_par(action)
            super
            @corporation_size = nil
            @parred = action
            size_corporation(@game.phase.corporation_sizes.first) if @game.phase.corporation_sizes.one?
            par_corporation
          end

          def par_corporation
            return unless @corporation_size

            @parred = nil
          end

          def process_choose(action)
            size = action.choice
            raise GameError, 'Corporation size is invalid' unless choices.include?(size)

            size_corporation(size)
          end

          def size_corporation(size)
            @corporation_size = size
            @game.convert(@parred.corporation) if size == 10 && @parred.corporation.type == :five_share
          end

          def choice_available?(entity)
            entity.corporation? && entity == @parred&.corporation
          end

          def buy_shares(entity, shares, exchange: nil, swap: nil, allow_president_change: true, borrow_from: nil,
                         discounter: nil)
            # Pres 5_10 5_10 5_10 10_10!
            # 0    1    2    3    4
            # if shares.to_bundle.shares.find { |s| s.index == 4}

            sixth_share_purchase = shares.to_bundle.shares.first.index == 4 &&
                shares.corporation == shares.to_bundle.shares.first.owner
            super
            @game.sixth_share_capitalization(shares.corporation) if sixth_share_purchase
          end
        end
      end
    end
  end
end
