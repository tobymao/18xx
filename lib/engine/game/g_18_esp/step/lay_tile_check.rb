# frozen_string_literal: true

module LayTileCheck
  def potential_tiles(entity, hex)
    tiles = super
    if @game.north_hex?(hex)
      tiles.reject! { |tile| tile.paths.any? { |path| path.track == :broad } }
    else
      tiles.reject! { |tile| tile.paths.any? { |path| path.track == :narrow } }
    end
    tiles
  end

  def legal_tile_rotation?(entity, hex, tile)
    if hex.tile.towns.none?(&:halt?)
      return super unless hex.id == @game.class::ARANJUEZ_HEX

      # handle aranjues hex situation. Tile must be connected to madrid.
      super && tile.exits.any? { |exit| hex.neighbors[exit] == @game.madrid_hex }
    else
      halt_upgrade_legal_rotation?(entity, hex, tile)
    end
  end

  def halt_upgrade_legal_rotation?(entity_or_entities, hex, tile)
    # entity_or_entities is an array when combining private company abilities
    entities = Array(entity_or_entities)
    entity, *_combo_entities = entities

    return false unless @game.legal_tile_rotation?(entity, hex, tile)

    old_ctedges = hex.tile.city_town_edges

    new_paths = tile.paths
    new_exits = tile.exits
    new_ctedges = tile.city_town_edges
    extra_cities = [0, new_ctedges.size - old_ctedges.size].max
    multi_city_upgrade = tile.cities.size > 1 && hex.tile.cities.size > 1
    new_exits.all? { |edge| hex.neighbors[edge] } &&
      !(new_exits & hex_neighbors(entity, hex)).empty? &&
      new_paths.any? { |p| old_ctedges.flatten.empty? || (p.exits - old_ctedges.flatten).empty? } &&
      (old_ctedges.flatten - new_exits.flatten).empty? &&
      # Count how many cities on the new tile that aren't included by any of the old tile.
      # Make sure this isn't more than the number of new cities added.
      # 1836jr30 D6 -> 54 adds more cities
      extra_cities >= new_ctedges.count { |newct| old_ctedges.all? { |oldct| (newct & oldct).none? } } &&
      # 1867: Does every old city correspond to exactly one new city?
      (!multi_city_upgrade || old_ctedges.all? { |oldct| new_ctedges.one? { |newct| (oldct & newct) == oldct } })
  end
end
