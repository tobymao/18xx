# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative 'faction_certificates'

module Engine
  module Game
    module GFrost1831
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          include FactionCertificates

          # Faction certificates are bought from Parliament at the Faction's price
          def can_buy?(entity, bundle)
            faction = bundle.corporation
            return super unless faction.type == :faction

            can_gain_faction_certificate?(entity, faction) &&
              bundle.owner == faction.ipo_owner &&
              entity.cash >= @game.faction_share_price(faction)
          end

          def buy_shares(entity, shares, exchange: nil, swap: nil, allow_president_change: true, borrow_from: nil,
                         discounter: nil, silent: nil)
            faction = shares.corporation
            return super unless faction.type == :faction

            bundle = shares.is_a?(ShareBundle) ? shares : ShareBundle.new(shares)
            price = @game.faction_share_price(faction)
            @log << "#{entity.name} buys a #{bundle.percent}% share of #{faction.name} "\
                    "from the Parliament for #{@game.format_currency(price)}"
            gain_faction_certificate(entity, faction, price)
          end

          # Sold Faction certificates return to Parliament at the Faction's price, which
          # does not fall; the Faction loses 1 Influence Cube per certificate (8.2.2)
          def can_sell?(entity, bundle)
            faction = bundle.corporation
            return super unless faction.type == :faction

            @game.parliament_open? &&
              entity.percent_of(faction) >= bundle.percent &&
              !bought? &&
              @game.faction_influence(faction.id) >= bundle.num_shares &&
              @round.players_sold[entity][faction] != :now &&
              keeps_president?(entity, faction, bundle)
          end

          def sell_shares(entity, shares, swap: nil)
            faction = shares.corporation
            return super unless faction.type == :faction

            bundle = shares.is_a?(ShareBundle) ? shares : ShareBundle.new(shares)
            price = @game.faction_share_price(faction) * bundle.num_shares
            @round.players_sold[entity][faction] = :now
            @game.bank.spend(price, entity)
            bundle.shares.each { |share| share.transfer(faction) }
            @log << "#{entity.name} sells #{bundle.percent}% of #{faction.name} "\
                    "to the Parliament for #{@game.format_currency(price)}"
            bundle.num_shares.times { @game.faction_influence_lose(faction.id) }

            update_faction_president(faction)
          end

          private

          # A President's certificate may be sold only if another player can take over (8.3.1)
          def keeps_president?(entity, faction, bundle)
            return true unless faction.owner == entity

            threshold = faction.presidents_share.percent
            return true if entity.percent_of(faction) - bundle.percent >= threshold

            faction.player_share_holders.any? { |player, percent| player != entity && percent >= threshold }
          end

          def update_faction_president(faction)
            player, percent = faction.player_share_holders.max_by { |_, p| p }
            return if player == faction.owner || percent < faction.presidents_share.percent

            faction.owner = player
            @log << "#{player.name} becomes president of #{faction.name}"
          end
        end
      end
    end
  end
end
