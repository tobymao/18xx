# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/share_buying'

module Engine
  module Game
    module G1860
      module Step
        class Exchange < Engine::Step::Base
          include Engine::Step::ShareBuying

          EXCHANGE_ACTIONS = %w[buy_shares].freeze

          def actions(entity)
            actions = []
            actions.concat(EXCHANGE_ACTIONS) if can_exchange?(entity)
            actions
          end

          def blocks?
            false
          end

          def process_buy_shares(action)
            company = action.entity
            bundle = action.bundle
            unless can_exchange?(company, bundle)
              raise GameError, "Cannot exchange #{action.entity.id} for #{bundle.corporation.id}"
            end

            corporation = bundle.corporation
            floated = corporation.floated?

            bundle.corporation.shares.each { |share| share.buyable = true }

            buy_shares(company.owner, bundle, exchange: company)
            company.close!
            place_home_track(corporation) if corporation.floated? && !floated && !@game.sr_after_southern
            @game.check_new_layer
          end

          def can_buy?(entity, bundle)
            can_gain?(entity, bundle, exchange: true)
          end

          private

          def can_exchange?(entity, bundle = nil)
            return false unless entity.company?
            return false unless (ability = @game.abilities(entity, :exchange))

            owner = entity.owner
            return can_gain?(owner, bundle, exchange: true) if bundle

            corporation = @game.exchange_corporations(ability).first
            return false unless corporation.ipoed

            shares = []
            shares << corporation.available_share if ability.from.include?(:ipo)
            shares << @game.share_pool.shares_by_corporation[corporation]&.first if ability.from.include?(:market)

            shares.any? { |s| can_gain?(entity.owner, s&.to_bundle, exchange: true) }
          end

          def place_home_track(corporation)
            hex = @game.hex_by_id(corporation.coordinates)
            tile = hex.tile

            # skip if a tile is already in home location
            return unless tile.color == :white

            @log << "#{corporation.name} (#{corporation.owner.name}) must choose tile for home location"

            @round.pending_tracks << {
              entity: corporation,
              hexes: [hex],
            }

            @round.clear_cache!
          end
        end
      end
    end
  end
end
