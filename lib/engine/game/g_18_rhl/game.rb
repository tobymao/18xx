# frozen_string_literal: true

require_relative '../g_18_rhineland/game'
require_relative 'map'
require_relative 'meta'

module Engine
  module Game
    module G18Rhl
      class Game < G18Rhineland::Game
        include_meta(G18Rhl::Meta)
        include Map

        attr_reader :osterath_tile

        CURRENCY_FORMAT_STR = '%sM'

        CERT_LIMIT = { 3 => 20, 4 => 15, 5 => 12, 6 => 10 }.freeze

        STARTING_CASH = { 3 => 600, 4 => 450, 5 => 360, 6 => 300 }.freeze
        LOWER_STARTING_CASH = { 3 => 500, 4 => 375, 5 => 300, 6 => 250 }.freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'remove_tile_block' => ['Remove tile block', 'Hex E12 can now be upgraded to yellow'],
        ).freeze

        def operating_round(round_num)
          G18Rhineland::Round::Operating.new(self, [
            G18Rhineland::Step::Bankrupt,
            Engine::Step::HomeToken,
            G18Rhl::Step::SpecialTrack,
            G18Rhineland::Step::SpecialToken, # Must be before regular track lay (due to private No. 4)
            G18Rhl::Step::Track,
            G18Rhineland::Step::RheBonusCheck,
            G18Rhineland::Step::Token,
            G18Rhl::Step::Route,
            G18Rhineland::Step::Dividend,
            Engine::Step::DiscardTrain,
            G18Rhineland::Step::BuyTrain,
          ], round_num: round_num)
        end

        def setup
          super

          @essen_tile ||= @tiles.find { |t| t.name == 'Essen' } if optional_promotion_tiles
          @moers_tile_gray ||= @tiles.find { |t| t.name == '950' } if optional_promotion_tiles
          @d_k_tile ||= @tiles.find { |t| t.name == '932V' } if optional_promotion_tiles
          @d_du_k_tile ||= @tiles.find { |t| t.name == '932' } unless optional_promotion_tiles
          @du_tile_gray ||= @tiles.find { |t| t.name == '949' } if optional_promotion_tiles
        end

        def optional_promotion_tiles
          @optional_rules&.include?(:promotion_tiles)
        end

        def optional_ratingen_variant
          @optional_rules&.include?(:ratingen_variant)
        end

        def prinz_wilhelm_bahn
          return if optional_ratingen_variant

          super
        end

        def angertalbahn
          return unless optional_ratingen_variant

          @angertalbahn ||= company_by_id('ATB')
        end

        def game_companies
          # Private 1 is different in base game and in Ratingen Variant
          all = self.class::COMPANIES
          return all.reject { |c| c[:sym] == 'ATB' } unless optional_ratingen_variant

          all.reject { |c| c[:sym] == 'PWB' }
        end

        def game_trains
          trains = self.class::TRAINS.map(&:dup)
          return trains unless optional_ratingen_variant

          # Inject remove_tile_block event
          trains.each do |t|
            next unless t[:name] == '3'

            t[:events] = [{ 'type' => 'remove_tile_block' }]
          end
          trains
        end

        def check_upgrades_to(from, to, selected_company)
          # Osterath cannot be upgraded at all, and cannot be upgraded to in phase 5 or later
          return [false, false] if from.name == @osterath_tile&.name ||
          (to.name == @osterath_tile&.name && @phase.name.to_i >= 5)

          # Private No. 2 allows Osterath tile to be put on E8 regardless
          return [false, true] if from.hex.name == 'E8' &&
          to.name == @osterath_tile&.name &&
          selected_company == konzession_essen_osterath

          # Handle Rhine Metropolis upgrade from green
          return [false, to.name == '927'] if from.color == :green && from.hex.name == 'F9'
          return [false, to.name == '928'] if from.color == :green && from.hex.name == 'I10'
          return [false, to.name == '929'] if from.color == :green && from.hex.name == 'D9'

          # Handle Moers upgrades
          return [false, to.name == '947'] if from.color == :green && from.hex.name == 'D7'
          return [false, to.name == '950'] if from.color == :brown && from.hex.name == 'D7'

          # Handle 3-spokers
          return [false, UPGRADES_FROM_3.include?(to.name)] if from.name == '3'
          return [false, UPGRADES_FROM_4.include?(to.name)] if from.name == '4'
          return [false, UPGRADES_FROM_58.include?(to.name)] if from.name == '58'
          return [false, false] if UPGRADES_FROM_58.include?(from.name)

          # Handle 4-spokers
          return [false, to.name == '87'] if UPGRADES_TO_87.include?(from.name)
          return [false, to.name == '88'] if UPGRADES_TO_88.include?(from.name)
          return [false, to.name == '204'] if from.name == UPGRADE_TO_204

          if optional_promotion_tiles
            # Essen can be upgraded to gray
            return [false, to.name == 'Essen'] if from.color == :brown && from.name == '216' && from.hex.name == 'D13'

            # Dusseldorf and Cologne can be upgraded to gray 932V
            return [false, to.name == '932V'] if from.color == :brown && %w[F9 I10].include?(from.hex.name)

            # Moers can be upgraded to gray 950
            return [false, to.name == '950'] if from.color == :brown && from.hex.name == 'D7'

            # Duisburg can be upgraded to gray 929
            return [false, to.name == '949'] if from.color == :brown && from.hex.name == 'D9'
          elsif from.color == :brown && %w[D9 F9 I10].include?(from.hex.name)
            return [false, to.name == '932']
          end
          # Duisburg, Dusseldorf and Cologne can be upgraded to gray 932

          return [true, nil] unless optional_ratingen_variant

          # Hex E10 have special tile for upgrade to yellow, and green, and no brown
          if from.hex.name == 'E10'
            case from.color
            when :white
              return [false, to.name == '1910']
            when :yellow
              return [false, to.name == '1911']
            else
              return [false, false]
            end
          end

          # Hex E12 is blocked for upgrade in yellow phase
          return [true, nil] if from.hex.name != RATINGEN_HEX || phase.name != '2'

          raise GameError, "Cannot place a tile in #{from.hex.name} until green phase"
        end

        def all_potential_upgrades(tile, tile_manifest: false, selected_company: nil)
          # Osterath cannot be upgraded
          return [] if tile.name == @osteroth_tile&.name

          upgrades = super

          return upgrades unless tile_manifest

          # Tile manifest for 216 should show Essen tile if Essen tile used
          upgrades |= [@essen_tile] if @essen_tile && tile.name == '216'

          # Tile manifest for 947 should show Moers tile if Moers tile used
          upgrades |= [@moers_tile_gray] if @moers_tile_gray && tile.name == '947'

          # Show correct potential upgrades for Rhine Metropolis hexes
          upgrades |= [@d_k_tile] if @d_k_tile && %w[927 928].include?(tile.name)
          upgrades |= [@d_du_k_tile] if @d_du_k_tile && %w[927 928 929].include?(tile.name)
          upgrades |= [@du_tile_gray] if @du_tile_gray && tile.name == '929'

          upgrades
        end

        def hex_blocked_by_ability?(entity, ability, hex, _tile = nil)
          return false if entity.player == ability.owner.player && (hex.name == 'E14' || hex == yellow_block_hex)

          super
        end

        def event_remove_tile_block!
          @log << "Hex #{RATINGEN_HEX} is now possible to upgrade to yellow"
          yellow_block_hex.tile.icons.reject! { |i| i.name == 'green_hex' }
        end

        def revenue_info(route, rge, revenue_stops)
          return [rheingold_express_description(revenue_stops)] if rge

          actual_stops = revenue_stops.map { |rs| rs[:stop] }
          [montan_bonus(route, actual_stops),
           eastern_ruhr_area_bonus(actual_stops),
           iron_rhine_bonus(actual_stops),
           ratingen_bonus(route, actual_stops)]
        end

        def ratingen_bonus(route, stops)
          bonus = { revenue: 0 }
          return bonus if !optional_ratingen_variant ||
                          stops.none? { |s| s.hex.id == RATINGEN_HEX } ||
                          count_steel(route, stops).zero?

          bonus[:revenue] = 30
          bonus[:description] = 'Ratingen (=+30M)'
          bonus
        end

        def montan_bonus_description
          'Montan'
        end
      end
    end
  end
end
