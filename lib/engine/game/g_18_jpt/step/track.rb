# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18JPT
      module Step
        class Track < Engine::Step::Track
          def round_state
            super.merge(
              {
                num_additional_lays: 0,
              }
            )
          end

          def setup
            super

            @round.num_additional_lays = 0
          end

          def lay_tile_action(action, entity: nil, spender: nil)
            old_tile = action.hex.tile

            super

            if @game.tmgbt.owner == action.entity && action.tile.label.to_s == 'T' && action.tile.color == :green
              @game.bank.spend(@game.class::T_TILE_SUBSIDY, action.entity)
              @game.log << "#{action.entity.name} receives a "\
                           "#{@game.format_currency(@game.class::T_TILE_SUBSIDY)} subsidy from the bank"
            end

            return unless old_tile.towns.any?

            @round.num_additional_lays += 1 if action.entity == @game.tc

            return unless action.entity == @game.ser

            @game.bank.spend(@game.class::TOWN_TILE_SUBSIDY, action.entity)
            @game.log << "#{action.entity.name} receives a "\
                         "#{@game.format_currency(@game.class::TOWN_TILE_SUBSIDY)} subsidy from the bank"
          end

          # preserve labels on some special cities because they may use unlabeled yellow/green/brown tiles
          def process_lay_tile(action)
            old_tile = action.hex.tile

            super

            return unless old_tile.label.to_s == 'KU'

            old_tile.label = nil
            action.tile.label = 'KU' unless action.tile.label
          end
        end
      end
    end
  end
end
