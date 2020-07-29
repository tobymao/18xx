# frozen_string_literal: true

module Engine
  module Step
    module G1882
      module NwrTrackBonus
        def tile_nwr?(tile)
          tile.icons.any? { |icon| icon.name == 'NWR' }
        end

        def gain_nwr_bonus(tile, entity)
          return if !tile_nwr?(tile) || tile.color != :yellow

          @game.log << "#{entity.name} gains #{@game.format_currency(20)} for laying yellow tile in NWR area"
          @game.bank.spend(20, entity)
        end
      end
    end
  end
end
