# frozen_string_literal: true

#
# This module can be called from setup method
# in the Engine::Game class for the game to
# force that stubs have to be connected when laying a tile

module StubsAreRestricted
  def legal_tile_rotation?(_entity, hex, tile)
    legal_if_stubbed?(hex, tile)
  end

  def legal_if_stubbed?(hex, tile)
    hex.tile.stubs.empty? || (hex.tile.stubs.map(&:edge) - tile.exits).empty?
  end
end
