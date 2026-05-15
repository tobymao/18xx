# frozen_string_literal: true

require_relative 'meta'
require_relative '../g_1880_romania/game'
require_relative 'map'
require_relative '../g_1880_romania/entities'

module Engine
  module Game
    module G1880RomaniaRegatul
      class Game < G1880Romania::Game
        include_meta(G1880RomaniaRegatul::Meta)
        include Map

        attr_reader :vaclav

        CERT_LIMIT = { 2 => 22, 3 => 18 }.freeze

        STARTING_CASH = { 2 => 700, 3 => 500 }.freeze

        GAME_END_REASONS_TEXT = {
          final_train: '6E train sold or exported',
        }.freeze

        GAME_END_REASONS_TIMING_TEXT = {
          one_more_full_or_set: '3 ORs ending with the Corporation that triggered game end',
        }.freeze

        GAME_END_DESCRIPTION_REASON_MAP_TEXT = {
          final_train: '6E train was sold or exported',
        }.freeze

        def optional_hexes
          map_optional_hexes
        end

        def game_companies
          companies = COMPANIES.map(&:dup)
          kept_companies = %w[P1 P4 P5 P6 P7]
          companies.select { |c| kept_companies.include?(c[:sym]) }
        end

        def game_minors
          minors = MINORS.map(&:dup)

          kept_minors = %w[1 2 3 6]
          coordinates = {
            '1' => 'I7',
            '2' => 'V2',
            '3' => 'Z10',
            '6' => 'N8',
          }.freeze
          minors
          .select { |m| kept_minors.include?(m[:sym]) }
          .each { |m| m[:coordinates] = coordinates[m[:sym]] }
        end

        def game_corporations
          corporations = CORPORATIONS.map(&:dup)
          kept_corporations = %w[LCR MR Bess VRL CFR GWR LWR DR]
          coordinates = {
            'LCR' => 'Q1',
            'MR' => 'U3',
            'Bess' => 'X4',
            'VRL' => 'P8',
            'CFR' => 'Q9',
            'GWR' => 'Q9',
            'LWR' => 'J10',
            'DR' => 'X10',
            'TR' => 'L6',
          }.freeze
          corporations
          .select { |c| kept_corporations.include?(c[:sym]) }
          .each { |m| m[:coordinates] = coordinates[m[:sym]] }
        end

        def game_trains
          unless @train_games
            @train_games = super.map(&:dup)
            t_2, t_2p2, t_3, t_3p3, t_4, t_4p4, t_6, t_6e, t_8, t_8e, t_2r = @train_games
            t_2[:num] = 8
            t_2p2[:num] = 4
            t_3[:num] = 4
            t_3p3[:num] = 4
            t_3p3[:events] = [{ 'type' => 'communist_takeover' }]
            t_4[:num] = 4
            t_4p4[:num] = 4
            t_6[:num] = 2
            t_6e[:num] = 1
            t_6e[:events] = [{ 'type' => 'signal_end_game', 'when' => 1 }]
            t_8[:num] = 'unlimited'
            t_8e[:num] = 0
            t_2r[:num] = 0
          end
          @train_games
        end

        def par_chart
          @par_chart ||=
            share_prices.sort_by { |sp| -sp.price }.to_h { |sp| [sp, [nil, nil, nil]] }
        end

        def dummy_company
          @dummy ||= Company.new(
            name: 'Dummy Company',
            sym: 'DUMMY',
            value: 0,
          )
          @dummy.close!
          @dummy
        end

        # P2 not used in this variant
        def consortiu
          dummy_company
        end

        # Base P5 not used in this variant
        def p5
          dummy_company
        end

        # Not used in this variant
        def ferry_company
          dummy_company
        end

        # Not used in this variant
        def taiwan_company
          dummy_company
        end

        # Not used in this variant
        def trans_siberian_bonusd(_)
          false
        end

        def upgrades_to_correct_label?(from, to)
          return from.label == to.label if from.color == :white && from.cities.size == 2 && to.label&.to_s == 'B'

          super
        end

        # Modified compared to 1880 as no BCR, and potential Amira corporation has only one tile lay
        def tile_lays(entity)
          return [] unless can_build_track?(entity)

          tile_lays = [{ lay: true, upgrade: true }]
          return tile_lays if entity.minor? || !@phase.tiles.include?(:green)

          tile_lays << { lay: :not_if_upgraded, upgrade: false }
          tile_lays
        end
      end
    end
  end
end
