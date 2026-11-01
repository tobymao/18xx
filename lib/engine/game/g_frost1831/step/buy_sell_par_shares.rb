# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module GFrost1831
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def actions(entity)
            actions = super
            # Add pay_debt option if player has debt and can afford it
            if entity.player? && entity.debt.positive? && entity.cash >= entity.debt
              actions = actions + ['choose'] unless actions.include?('choose')
            end
            actions
          end

          def can_buy?(entity, bundle)
            # Player with debt cannot buy shares
            return false if entity.player? && entity.debt.positive?

            # For factions: only allow buying from IPO (Parliament), never from players/market
            if bundle.corporation.type == :faction
              return false unless @game.parliament_open?
              # Only from IPO
              return false unless bundle.owner == bundle.corporation.ipo_owner
              return false unless entity.cash >= @game.faction_share_price(bundle.corporation)

              # Check opposition rule: can't buy opposing factions
              return false if opposing_faction_owned?(entity, bundle.corporation)

              # Check 60% limit for factions
              return false if entity.percent_of(bundle.corporation) + bundle.percent > 60

              return true
            end

            super
          end

          def buy_shares(entity, shares, exchange: nil, swap: nil, allow_president_change: true, borrow_from: nil,
                         discounter: nil, silent: nil)
            corporation = shares.corporation

            if corporation.type == :faction
              # Custom buy for factions — price comes from ruler, not market
              bundle = shares.is_a?(ShareBundle) ? shares : ShareBundle.new(shares)
              price = @game.faction_share_price(corporation)

              was_floated = corporation.floated?

              entity.spend(price, @game.bank)
              @game.share_pool.transfer_shares(bundle, entity)

              @log << "#{entity.name} buys a #{bundle.percent}% share of #{corporation.name} "\
                      "from the Parliament for #{@game.format_currency(price)}"

              # Faction gains 1 influence cube when share is bought
              @game.faction_influence_gain(corporation.id)
              @game.move_government(corporation.id)

              # Check if faction just floated (was not floated before, is now)
              float_faction(corporation) if !was_floated && corporation.floated?

              return
            end

            super
          end

          def can_sell?(entity, bundle)
            corporation = bundle.corporation

            if corporation.type == :faction
              return false unless @game.parliament_open?
              return false unless entity.percent_of(corporation).positive?

              # Respect sell/buy order: can't sell after buying
              return false if bought?

              # Faction must have enough influence to lose (1 per share sold)
              faction_influence_count = @game.faction_influence(corporation.id)
              return false if faction_influence_count < bundle.num_shares

              # Can't sell what was bought in same SR
              return false if @round.players_sold[entity][corporation] == :now

              # President can sell shares as long as they retain >= presidents_share.percent after the sale.
              # They can only sell down to the presidency threshold (20% for factions).
              # If the sale would drop them below that, another player must hold >= 20% to take over.
              if corporation.owner == entity
                current_percent = entity.percent_of(corporation)
                pres_threshold = corporation.presidents_share.percent
                percent_after_sale = current_percent - bundle.percent
                if percent_after_sale < pres_threshold
                  # Would lose presidency — need another player to take over
                  other_holders = corporation.player_share_holders.reject { |p, _| p == entity }
                  max_other = other_holders.values.max || 0
                  return false if max_other < pres_threshold
                end
              end

              return true
            end

            super
          end

          def sell_shares(entity, shares, swap: nil)
            corporation = shares.corporation

            if corporation.type == :faction
              bundle = shares.is_a?(Engine::ShareBundle) ? shares : Engine::ShareBundle.new(shares)
              price = @game.faction_share_price(corporation) * bundle.num_shares

              # Mark as sold to prevent buying same turn
              @round.players_sold[entity][corporation] = :now

              # Pay player the ruler price
              @game.bank.spend(price, entity)

              # Return shares to IPO (corporation), NOT to market/share_pool
              bundle.shares.each do |share|
                share.transfer(corporation)
              end

              @log << "#{entity.name} sells #{bundle.percent}% of #{corporation.name} "\
                      "to the Parliament for #{@game.format_currency(price)}"

              # Faction loses 1 influence cube per share sold
              bundle.num_shares.times do
                @game.faction_influence_lose(corporation.id)
              end

              # Check if president changed or faction lost all shareholders.
              # Factions are NEVER un-founded once floated — they remain in play permanently.
              if corporation.player_share_holders.values.all? { |p| p <= 0 }
                corporation.owner = nil
                @log << "#{corporation.name} has no president (all shares returned to Parliament)"
              else
                max_holder = corporation.player_share_holders.select { |_, p| p.positive? }
                                        .max_by { |_, p| p }
                if max_holder && max_holder[0] != corporation.owner &&
                    max_holder[1] >= corporation.presidents_share.percent
                  corporation.owner = max_holder[0]
                  @log << "#{max_holder[0].name} becomes president of #{corporation.name}"
                end
              end

              return
            end

            super
          end

          private

          def process_payoff_loan(action)
            # Legacy — redirect to choose
            process_choose(Engine::Action::Choose.new(action.entity, choice: 'pay_debt'))
          end

          def choices
            entity = current_entity
            choices = {}

            # Pay debt option
            if entity&.player? && entity.debt.positive? && entity.cash >= entity.debt
              choices['pay_debt'] = "Pay Loan (#{@game.format_currency(entity.debt)})"
            end

            choices
          end

          def choice_available?(entity)
            entity&.player? && entity.debt.positive? && entity.cash >= entity.debt
          end

          def choice_name
            nil
          end

          def process_choose(action)
            choice = action.choice
            entity = action.entity

            if choice == 'pay_debt'
              amount = entity.debt
              entity.spend(amount, @game.bank)
              entity.debt = 0
              @log << "#{entity.name} pays off #{@game.format_currency(amount)} loan"
              return
            end

            super
          end

          def opposing_faction_owned?(entity, faction)
            opposites = @game.class::OPPOSITES
            opposite_sym = opposites[faction.id]
            return false unless opposite_sym

            opposite = @game.corporations.find { |c| c.id == opposite_sym }
            return false unless opposite

            entity.percent_of(opposite).positive?
          end

          def float_faction(faction)
            @log << "#{faction.name} is founded!"
            faction.floated = true

            # Use the standard HomeToken mechanism — highlights hexes on map for clicking
            available_hexes = @game.available_faction_cities.map { |hex_id| @game.hex_by_id(hex_id) }
            token = faction.find_token_by_type

            @log << "#{faction.name} must choose city for base"
            @round.pending_tokens << {
              entity: faction,
              hexes: available_hexes,
              token: token,
            }
            @round.clear_cache!
          end
        end
      end
    end
  end
end
