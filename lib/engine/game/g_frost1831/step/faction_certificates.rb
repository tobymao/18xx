# frozen_string_literal: true

module Engine
  module Game
    module GFrost1831
      module Step
        # Buying a Faction certificate (rules 8.2.2, 8.2.4, 8.4.2), shared by the
        # Stock Round and the Affiliate exchange.
        module FactionCertificates
          MAX_FACTION_PERCENT = 60

          # Shown for the Affiliate exchange buttons; the views pass a Share
          def can_gain?(entity, bundle, exchange: false)
            faction = bundle&.corporation
            return super if faction&.type != :faction

            bundle = bundle.to_bundle

            bundle.owner == faction.ipo_owner && can_gain_faction_certificate?(entity, faction)
          end

          def can_gain_faction_certificate?(player, faction)
            @game.parliament_open? &&
              faction.ipo_shares.any?(&:buyable) &&
              !opposing_faction?(player, faction) &&
              player.percent_of(faction) + faction.presidents_share.percent <= MAX_FACTION_PERCENT
          end

          # Each certificate gives the Faction 1 Influence Cube, which moves the Government
          def gain_faction_certificate(player, faction, price = 0, bundle: nil)
            was_founded = faction.floated?
            player.spend(price, @game.bank) if price.positive?
            # The first certificate of a Faction is the President's
            bundle = faction.presidents_share.to_bundle if faction.presidents_share.owner == faction.ipo_owner
            @game.share_pool.transfer_shares(bundle || faction.ipo_shares.find(&:buyable).to_bundle, player)

            @game.faction_influence_gain(faction.id)
            @game.move_government(faction.id)
            found_faction(faction) if !was_founded && faction.floated?
          end

          def opposing_faction?(player, faction)
            opposite = @game.corporation_by_id(@game.class::OPPOSITES[faction.id])
            player.percent_of(opposite).positive?
          end

          # The President chooses a reserved city for the home base
          def found_faction(faction)
            @log << "#{faction.name} is founded"
            @round.pending_tokens << {
              entity: faction,
              hexes: @game.available_faction_cities.map { |hex_id| @game.hex_by_id(hex_id) },
              token: faction.find_token_by_type,
            }
            @round.clear_cache!
          end
        end
      end
    end
  end
end
