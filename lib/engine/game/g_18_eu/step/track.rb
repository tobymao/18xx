# frozen_string_literal: true

require_relative '../../../step/track'
require_relative '../../../part/upgrade'

module Engine
  module Game
    module G18EU
      module Step
        class Track < Engine::Step::Track
          include Engine::Step::Tracker

          def process_lay_tile(action)
            action.tile.upgrades << Part::Upgrade.new(60, ['mountain'], nil) if action.hex.tile.upgrades.sum(&:cost) == 120

            super
          end

          def update_token!(_action, _entity, tile, old_tile)
            super

            return if old_tile.cities.size == 1 || tile.color != :brown

            tile.cities.each do |city|
              prev = nil
              city.tokens.compact.sort_by { |t| t.corporation.name }.each do |token|
                if prev&.corporation == token.corporation
                  prev.remove!
                  @game.log << "#{token.corporation.name} redundant token removed from #{tile.hex.name}"
                end
                prev = token
              end
            end
          end
        end
      end
    end
  end
end
