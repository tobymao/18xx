# frozen_string_literal: true

module Lib
  # Generic client-side staging object for a small popup of labeled choices
  # anchored to a hex, mirroring Lib::TileSelector's role for tile-laying.
  # Any step may opt in by implementing `hex_choice_popup(entity, hex)` and
  # returning a `choice => label` hash (or nil to skip the popup for that hex).
  # Used by 2038 to draw routing choices during route building.
  class HexChoicePopup
    attr_reader :entity, :hex, :choices, :x, :y, :role, :root

    def initialize(hex, choices, coordinates, root, entity, role)
      @hex = hex
      @choices = choices
      @x, @y = coordinates
      @root = root
      @entity = entity
      @role = role
    end
  end
end
