# frozen_string_literal: true

require_relative 'choose_ability_on_sr'

module Engine
  module Game
    module G18ZOO
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          include Engine::Game::G18ZOO::ChooseAbilityOnSr

          def actions(entity)
            return ['choose_ability'] if entity.company? && can_choose_ability?(entity)

            actions = super
            actions << 'choose_ability' if entity.player? && can_choose_any_ability?(entity)
            actions << 'buy_company' unless available_companies.empty?
            actions << 'pass' unless actions.empty?
            actions.uniq
          end

          def can_buy_company?(player, _company)
            player.companies.count { |c| !@game.zoo_ticket?(c) } < 3
          end

          def process_buy_company(action)
            price = action.price
            company = action.company
            owner = company.owner

            raise GameError, "Cannot buy #{company.name} from #{owner.name}" if owner == @game.bank && price != company.value

            super

            @game.available_companies.delete(action.company)
            @game.apply_custom_ability(action.company)
          end

          def get_par_prices(_entity, _corp)
            super.reject do |p|
              (p.price == 9 && !@game.phase.tiles.include?(:green)) ||
                (p.price == 12 && !@game.phase.tiles.include?(:brown))
            end
          end

          def can_buy?(entity, bundle)
            super && more_than_80_only_from_market(entity, bundle)
          end

          def more_than_80_only_from_market(entity, bundle)
            corporation = bundle.corporation
            is_ipo_share = bundle.owner.corporation?
            percent = entity.percent_of(corporation)
            !is_ipo_share || percent < 80
          end

          def log_pass(entity)
            return @log << "#{entity.name} passes" if @round.current_actions.empty?
            return if bought? || !sold?

            @log << "#{entity.name} declines to buy shares"
          end

          def buyable_bank_owned_companies(_entity)
            available_companies
          end

          def available_companies
            return [] if bought?

            @game.available_companies
          end

          def round_state
            # An extra field to track whether a share was already sold from any not president since the start of the round.
            super.merge({ share_sold: [] })
          end

          def sell_shares(entity, shares, swap: nil)
            raise GameError, "Cannot sell shares of #{shares.corporation.name}" if !can_sell?(entity, shares) && !swap

            should_move = shares.owner == shares.corporation.owner || !@round.share_sold.include?(shares)
            @round.share_sold << shares if shares.owner != shares.corporation.owner && !@round.share_sold.include?(shares)

            @round.players_sold[shares.owner][shares.corporation] = :now
            @game.sell_shares_and_change_price(shares, swap: swap, movement: (should_move ? @game.sell_movement : :none))
            return if should_move

            @game.log << ("#{shares.corporation.name}'S share price protected " \
              '(share protection rule: avoid the "wait-and-sell-in-player-order" technique)')
          end
        end
      end
    end
  end
end
