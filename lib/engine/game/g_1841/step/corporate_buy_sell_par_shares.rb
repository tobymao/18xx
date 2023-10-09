# frozen_string_literal: true

require_relative 'base_buy_sell_par_shares'

module Engine
  module Game
    module G1841
      module Step
        class CorporateBuySellParShares < BaseBuySellParShares
          def actions(entity)
            return [] if @game.done_this_round[entity]

            super
          end

          def description
            'Corporate Sell then Buy Shares'
          end

          def auto_actions(_entity); end

          def log_pass(entity)
            return @log << "#{entity.name} passes corporate sell/buy" if @round.current_actions.empty?
            return if bought? && sold?

            action = bought? ? 'to sell' : 'to buy'
            @log << "#{entity.name} declines #{action} shares"
          end

          def pass_description
            if @round.current_actions.empty?
              'Pass (Corporate Share)'
            else
              'Done (Corporate Share)'
            end
          end

          def can_sell_any?(entity)
            @game.corporations.any? { |corp| can_sell_any_of_corporation?(entity, corp) } ||
              entity.ipo_shares.select { |share| can_sell?(entity, share.to_bundle) }.any?
          end

          def can_buy_any_from_market?(entity)
            @game.share_pool.shares.any? { |s| can_buy?(entity, s.to_bundle) }
          end

          def can_buy_any_from_ipo?(entity)
            @game.corporations.each do |corporation|
              next unless corporation.ipoed
              return true if corporation.shares.any? { |s| can_buy?(entity, s.to_bundle) }
            end

            false
          end

          def can_buy?(entity, bundle)
            return unless bundle
            return if entity == bundle.corporation

            super
          end

          def can_gain?(entity, bundle, exchange: false)
            return if !bundle || !entity

            corporation = bundle.corporation

            # can't buy controlling corp
            !@game.in_chain?(entity, corporation) &&
              # can't allow buyer to have more than 5 certs of a given corporation
              (@game.num_certs(entity) < @game.cert_limit(entity)) &&
              # can't allow player to control too much
              ((@game.player_controlled_percentage(entity,
                                                   corporation) + bundle.common_percent) <= corporation.max_ownership_percent)
          end

          def must_sell?(entity)
            return false unless can_sell_any?(entity)
            return true if @game.num_certs(entity) > @game.cert_limit(entity)

            # controlling player controls more than 60% of a stock
            # or this corp owns stock of a corp that controls it
            player = @game.controller(entity)
            @game.corporations.any? do |corp|
              can_sell_any_of_corporation?(entity, corp) &&
              (@game.player_controlled_percentage(player, corp) > corp.max_ownership_percent ||
               (!entity.shares_of(corp).empty? && @game.in_chain?(entity, corp)))
            end
          end

          def process_sell_shares(action)
            super
            @round.recalculate_order
          end

          def purchaseable_companies(_entity)
            []
          end

          def buyable_bank_owned_companies(_entity)
            []
          end
        end
      end
    end
  end
end
