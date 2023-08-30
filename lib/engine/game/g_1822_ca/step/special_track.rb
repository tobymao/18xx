# frozen_string_literal: true

require_relative '../../g_1822/step/special_track'
require_relative 'tracker'

module Engine
  module Game
    module G1822CA
      module Step
        class SpecialTrack < G1822::Step::SpecialTrack
          include G1822CA::Tracker

          def available_hex(entity_or_entities, hex)
            if hex == @game.sawmill_hex
              super && Array(entity_or_entities).none? { |e| @game.must_remove_town?(e) }
            else
              super
            end
          end

          def actions(entity)
            return [] unless entity.company?

            super
          end

          def process_lay_tile(action)
            super

            # cannot lay a second yellow after using one of the P19-P20 Mountain
            # Pass privates
            @round.num_laid_track += 1 if @game.class::MOUNTAIN_PASS_COMPANIES.include?(action.entity.id)
          end

          # P21 3-Tile Grant does not need to be consecutive
          # https://boardgamegeek.com/thread/2449433/article/35135037#35135037
          def handle_extra_tile_lay_company(ability, entity)
            super unless entity.id == @game.class::COMPANY_LSR
          end
        end
      end
    end
  end
end
