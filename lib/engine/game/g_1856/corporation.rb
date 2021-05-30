# frozen_string_literal: true

require_relative '../../corporation'

module Engine
  module Game
    module G1856
      class Corporation < Engine::Corporation
        attr_accessor :escrow, :presidents_share

        CAPITALIZATION_STRS = {
          full: 'Full',
          incremental: 'Incremental',
          escrow: 'Escrow',
        }.freeze
        def initialize(game, sym:, name:, **opts)
          @game = game
          @started = false
          @escrow = nil
          super(sym: sym, name: name, **opts)
          @capitalization = nil
          @destinated = false
        end

        # ~Ab~RE-using floated? to represent whether or not a corporation has operated
        def floated?
          @started || (@capitalization == :full && percent_of(self) <= 100 - @game.percent_to_operate)
        end

        def floatable?
          percent_of(self) <= 100 - @game.percent_to_operate
        end

        def float!
          @started = true
        end

        def can_buy?
          false
        end

        def par!
          @capitalization = capitalization_type
          @escrow = 0 if @capitalization == :escrow
        end

        def destinated!
          @destinated = true
        end

        def capitalization_type_desc
          CAPITALIZATION_STRS[@capitalization || capitalization_type]
        end

        def capitalization_type
          # TODO: escrow
          return :escrow if !@destinated && @game.phase.status.include?('escrow')
          return :incremental if (@destinated && @game.phase.status.include?('escrow')) ||
            @game.phase.status.include?('incremental')
          return :full if @game.phase.status.include?('fullcap')

          # This shouldn't happen
          raise NotImplementedError
        end
      end
    end
  end
end
