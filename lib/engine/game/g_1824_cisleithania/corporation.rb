# frozen_string_literal: true

require_relative '../g_1824/corporation'

module Engine
  module Game
    module G1824Cisleithania
      class Corporation < G1824::Corporation
        def initialize(sym:, name:, **opts)
          super(sym: sym, name: name, **opts)

          # Used for 2 player variant initial SR
          @stack = nil
        end

        def make_construction_railway!
          @type = :construction_railway
          a = @abilities.first
          remove_ability(a)
        end

        def make_bond_railway!
          @type = :bond_railway
          remove_reserve_for_all_shares!
          @ipoed = true
          float!

          # Presidency share is treated as a double cert
          @presidents_share.double_cert = true
        end

        def receivership?
          return true if @type == :bond_railway

          super
        end
      end
    end
  end
end
