# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18RoyalGorge
      module Step
        class Track < Engine::Step::Track
          MAX_STEEL_COST = 40

          def help
            [
              "Used #{@round.num_laid_track}/6 track actions.",
              'For each track action, a steel cube from the Steel Market must be bought by paying CF&I.',
              'For each color of track tile, only one column of the Steel Market may be used per turn.',
              'At the end of each set of operating rounds, CF&I pays its steel earnings as dividends to '\
              'shareholders, and the Steel Market is refilled.',
            ]
          end

          def round_state
            super.merge(
              {
                laid_track: {
                  yellow: false,
                  green: false,
                  brown: false,
                },
                steel_column_choice: {
                  yellow: nil,
                  green: nil,
                  brown: nil,
                  gray: nil,
                },
                steel_price_choice: {
                  yellow: nil,
                  green: nil,
                  brown: nil,
                  gray: nil,
                },
              }
            )
          end

          def setup
            @round.steel_column_choice[:yellow] = nil
            @round.steel_column_choice[:green] = nil
            @round.steel_column_choice[:brown] = nil
            @round.steel_column_choice[:gray] = nil

            @round.steel_price_choice[:yellow] = nil
            @round.steel_price_choice[:green] = nil
            @round.steel_price_choice[:brown] = nil
            @round.steel_price_choice[:gray] = nil

            @round.laid_track[:yellow] = false
            @round.laid_track[:green] = false
            @round.laid_track[:brown] = false

            super
          end

          def actions(entity)
            actions = super.dup
            actions << 'choose' if entity == current_entity
            actions
          end

          def process_lay_tile(action)
            entity = action.entity
            color = action.tile.color

            steel_cost =
              if color == :gray
                @round.steel_column_choice[color] = 'I'
                MAX_STEEL_COST
              else
                column = @round.steel_column_choice[color]
                if column.nil?
                  column = @game.available_steel[color].min_by { |_, v| v[-1] || MAX_STEEL_COST }[0]
                  @round.steel_column_choice[color] = column
                end

                chosen_price = @round.steel_price_choice[color] || @game.available_steel[color][column][-1]
                @game.available_steel[color][column].delete(chosen_price) || MAX_STEEL_COST
              end
            if steel_cost.positive?
              entity.spend(steel_cost, @game.steel_corp)
              @log << "#{entity.name} pays #{@game.steel_corp.name} #{@game.format_currency(steel_cost)} for steel"
            end

            upgrade_other_royal_gorge_hexes(action) if @game.class::ROYAL_GORGE_HEXES_TO_TILES.include?(action.hex.id)

            super

            # update choice to one step up the column
            if @round.steel_price_choice[color] && @round.steel_price_choice[color] != MAX_STEEL_COST
              next_choice = nil
              @game.available_steel[color][column].each_with_index do |price, _index|
                break unless price > @round.steel_price_choice[color]

                next_choice = price
              end
              @round.steel_price_choice[color] = (next_choice || MAX_STEEL_COST)
            end

            @round.laid_track[color] = true
          end

          def choice_name
            'Steel cubes'
          end

          def choices
            # never present a choice for gray, it's always the max
            available_colors = @game.phase.tiles - [:gray]

            choices = {}

            available_colors.each do |color|
              @game.available_steel[color].each do |column, prices|
                (prices + [MAX_STEEL_COST]).each do |price|
                  c = "#{column}-#{price}"
                  choices[c] = c
                end
              end
            end

            choices
          end

          def process_choose(action)
            column, price_s = action.choice.split('-')
            price = price_s.to_i

            color = @game.class::COLUMN_COLORS[column]

            @round.steel_column_choice[color] = column
            @round.steel_price_choice[color] = price

            @log << "#{action.entity.name} chooses steel for next #{color} tile: column #{column}, "\
                    "#{@game.format_currency(price)}"
          end

          # choices are accessed via the map_legend
          def render_choices?
            false
          end

          def upgrade_other_royal_gorge_hexes(action)
            @game.class::ROYAL_GORGE_HEXES_TO_TILES.each do |hex_id, tiles|
              _green_tile, brown_tile = tiles
              hex = @game.hex_by_id(hex_id)
              next if hex == action.hex

              tile = @game.tile_by_id("#{brown_tile}-0")
              hex.lay(tile)
            end
          end
        end
      end
    end
  end
end
