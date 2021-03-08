# frozen_string_literal: true

require_relative '../../corporation'

module Engine
  module Game
    module G2038
      class Corporation < Engine::Corporation
        attr_accessor :presidents_share

        CAPITALIZATION_STRS = {
          full: 'Public',
          incremental: 'Growth',
        }.freeze

        def initialize(game, sym:, name:, **opts)
          @game = game
          super(sym: sym, name: name, **opts)
          @capitalization = nil
        end

        #        def par!
        #          @capitalization = _capitalization_type
        #          @escrow = 0 if @capitalization == :escrow
        #        end

        #        def capitalization_type_desc
        #          CAPITALIZATION_STRS[@capitalization || _capitalization_type]
        #        end

        #        def _capitalization_type
        #          return :incremental if @game.phase.status.include?('incremental')
        #          return :full

        # This shouldn't happen
        #          raise NotImplementedError
        #        end

        # As long as this is only used in core code for display we can re-use it
        #        def percent_to_float
        #          return 20 if @game.phase.status.include?('facing_2')
        # This shouldn't happen
        #          raise NotImplementedError
        #        end
      end
    end
  end
end
