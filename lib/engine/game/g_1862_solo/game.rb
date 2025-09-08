# frozen_string_literal: true

require_relative '../g_1862/game'
require_relative 'meta'

module Engine
  module Game
    module G1862Solo
      class Game < G1862::Game
        include_meta(G1862Solo::Meta)

        # No cert limit
        CERT_LIMIT = {
          1 => 999,
        }.freeze

        STARTING_CASH = {
          1 => 600,
        }.freeze

        # No cert limit
        def show_game_cert_limit?
          false
        end

        def setup_preround
          @original_corporations = @corporations.dup

          super

          @original_corporations.reject { |c| @corporations.include?(c) }.each do |c|
            hex = @hexes.find { |h| h.id == c.coordinates } # hex_by_id doesn't work here
            old_tile = hex.tile
            tile_string = ''
            hex.tile = Tile.from_code(old_tile.name, 'brown', tile_string)
          end
        end

        def game_tiles
          TILES.dup.merge!({
                            'X' =>
                                {
                                  'count' => 4,
                                  'color' => 'brown',
                                  'code' => '',
                                },
                          })
        end

        def next_round!
          @skip_round.clear
          @round =
            case @round
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Engine::Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                if @lner_triggered
                  @lner_triggered = false
                  form_lner
                  new_stock_round
                else
                  new_parliament_round
                end
              end
            else
              raise "round class #{@round.class} not handled"
            end
        end

        def init_round
          @log << "-- #{round_description('Stock', 1)} --"
          @round_counter += 1
          stock_round
        end
        
      end
    end
  end
end
