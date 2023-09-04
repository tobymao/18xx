# frozen_string_literal: true

module Engine
  module Game
    module G18Ardennes
      module Map
        LAYOUT = :pointy

        LOCATION_NAMES = {
          'B6' => 'Haarlem',
          'B8' => 'Amsterdam',
          'B12' => 'Arnhem-Nijmegen',
          'B16' => 'The Ruhr',
          'C7' => 'Rotterdam',
          'D12' => 'Eindhoven',
          'D14' => 'Mönchengladbach',
          'D18' => 'Cologne',
          'E5' => 'Vlissingen',
          'E9' => 'Antwerp',
          'E13' => 'Maastricht',
          'E15' => 'Aachen',
          'E19' => 'Bonn',
          'E21' => 'Koblenz',
          'E23' => 'Mainz',
          'E25' => 'Frankfurt-am-Main',
          'F4' => 'Brugge',
          'F6' => 'Gent',
          'F10' => 'Brussels',
          'F14' => 'Liège',
          'G3' => 'Dunkerque',
          'G11' => 'Namur',
          'G19' => 'Trier',
          'G25' => 'Mannheim-Ludwigshafen',
          'H2' => 'Calais',
          'H6' => 'Lille-Roubaix',
          'H8' => 'Mons',
          'H10' => 'Charleroi',
          'H18' => 'Luxembourg',
          'H26' => 'Karlsruhe',
          'I1' => 'Boulogne-sur-Mer',
          'I5' => 'Arras',
          'I7' => 'Douai',
          'I13' => 'Charleville-Mézières',
          'I21' => 'Saarbrücken',
          'J8' => 'Saint-Quentin',
          'J18' => 'Metz',
          'J24' => 'Strasbourg',
          'K5' => 'Amiens',
          'K11' => 'Reims',
          'K19' => 'Nancy',
          'K27' => 'Freiburg-im-Breisgau',
          'L22' => 'Épinal',
          'L26' => 'Mulhouse',
          'M3' => 'Rouen',
          'M7' => 'Paris',
          'M13' => 'Troyes',
          'M23' => 'Belfort',
          'M27' => 'Basel',
        }.freeze

        HEXES = {
          white: {
            # Plain track hexes
            %w[
              B14 C17 D10 D16 D20 D22 E11 E17 F8 F12 F22 F24 F26 G5 G7
              G9 H4 I3 I9 I11 I15 I17 I19 I23 I25 I27 J2 J4 J6 J10 J14 J16 J20
              J26 K3 K7 K13 K15 K17 K21 K25 L4 L10 L12 L14 L16 L18 L20
              M11 M15 M17 M19 M21 M25
            ] => '',
            %w[C9 C11 C13] =>
                    'upgrade=cost:20,terrain:water;',
            %w[D8] =>
                    'upgrade=cost:40,terrain:water;',
            %w[F16 F18 F20 G13 G15 G17 G21 G23 H12 H14 H16 H20 H22 H24 J22 K23 L24] =>
                    'upgrade=cost:40,terrain:mountain;',
            %w[L8 J12] =>
                    'stub=edge:0;',
            %w[B10 M9] =>
                    'stub=edge:1;',
            %w[C15] =>
                    'stub=edge:3;',
            %w[K9 M5] =>
                    'stub=edge:4;',
            %w[L6] =>
                    'stub=edge:5;',

            # Town hexes
            %w[D12 D14 E13 E19 E21 F6 F14 G11 H2 H8 I5 I7 I13 J8 K19 K27 L22 L26 M23] =>
                    'town=revenue:0;',
            %w[G19 H18] =>
                    'town=revenue:0;' \
                    'upgrade=cost:40,terrain:mountain;',
            %w[E23] =>
                    'town=revenue:0;' \
                    'stub=edge:4;',

            # City hexes
            %w[B12 E15 H26 I21 J18 K5] =>
                    'city=revenue:0;',
            %w[D18 E9 G25 H6 J24] =>
                    'city=revenue:0;' \
                    'label=Y;',
            %w[F4 G3] =>
                    'city=revenue:0;' \
                    'path=a:1,b:_0;',
            %w[F10] =>
                    'city=revenue:0;' \
                    'label=Y;' \
                    'future_label=label:B,color:brown;',
            %w[H10] =>
                    'city=revenue:0;' \
                    'upgrade=cost:40,terrain:mountain;',
          },

          yellow: {
            %w[B8] =>
                    'label=A;' \
                    'city=revenue:30;' \
                    'city=revenue:30;' \
                    'path=a:1,b:_0;' \
                    'path=a:4,b:_1;',
            %w[B16] =>
                    'label=R;' \
                    'city=revenue:30;' \
                    'town=revenue:10;' \
                    'path=a:0,b:_0;' \
                    'path=a:_0,b:_1;',
            %w[C7] =>
                    'label=Y;' \
                    'city=revenue:30;' \
                    'city=revenue:30;' \
                    'path=a:0,b:_0;' \
                    'path=a:2,b:_1;',
            %w[E25] =>
                    'label=T;' \
                    'city=revenue:30;' \
                    'city=revenue:30;' \
                    'path=a:0,b:_0;' \
                    'path=a:5,b:_0;' \
                    'path=a:1,b:_1;',
            %w[M7] =>
                    'label=P;' \
                    'city=revenue:40;' \
                    'city=revenue:40;' \
                    'path=a:1,b:_0;' \
                    'path=a:2,b:_0;' \
                    'path=a:3,b:_1;' \
                    'path=a:4,b:_1;',
            %w[M27] =>
                    'label=T;' \
                    'city=revenue:30;' \
                    'city=revenue:30;' \
                    'path=a:1,b:_0;' \
                    'path=a:2,b:_0;' \
                    'path=a:3,b:_1;',
          },
          gray: {
            %w[B6] =>
                    'town=revenue:20;' \
                    'path=a:4,b:_0;' \
                    'path=a:5,b:_0;',
            %w[D6] =>
                    'path=a:3,b:4;',
            %w[E5] =>
                    'city=revenue:20;' \
                    'path=a:1,b:_0;' \
                    'path=a:4,b:_0;',
            %w[E7] =>
                    'path=a:1,b:3;',
            %w[F2] =>
                    'offboard=revenue:0;' \
                    'path=a:4,b:_0;' \
                    'path=a:5,b:_0;',
            %w[E3 G1] =>
                    'offboard=revenue:0;' \
                    'path=a:4,b:_0;',
            %w[I1] =>
                    'town=revenue:20;' \
                    'path=a:3,b:_0;' \
                    'path=a:4,b:_0;' \
                    'path=a:5,b:_0;',
            %w[J28 L28] =>
                    'path=a:0,b:2;',
            %w[K11] =>
                    'city=revenue:30,loc:5;' \
                    'path=a:1,b:3;' \
                    'path=a:1,b:_0;' \
                    'path=a:3,b:_0;',
            %w[M3] =>
                    'town=revenue:20;' \
                    'path=a:3,b:_0;' \
                    'path=a:4,b:_0;',
            %w[M13] =>
                    'town=revenue:20;' \
                    'path=a:1,b:_0;' \
                    'path=a:4,b:_0;',
          },
        }.freeze

        NORTH_HEXES = %w[B8 B16].freeze
        SOUTH_HEXES = %w[M7 M27].freeze
        EAST_HEXES = %w[D18 E25 G25 H26].freeze
        WEST_HEXES = %w[E3 F2 G1].freeze
        MINE_HEXES = %w[H10 H10 I21 I21].freeze
        PORT_HEXES = %w[E5 F4 F4 G3 G3].freeze
        FORT_HEXES = %w[J18 J18 K19 L22 M23].freeze
        FORT_DESTINATIONS = %w[M27 J4].freeze

        ASSIGNMENT_TOKENS = {
          'J18' => '/logos/18_ardennes/fort.svg',
          'K19' => '/logos/18_ardennes/fort.svg',
          'L22' => '/logos/18_ardennes/fort.svg',
          'M23' => '/logos/18_ardennes/fort.svg',
          'H10' => '/logos/18_ardennes/mine.svg',
          'I21' => '/logos/18_ardennes/mine.svg',
          'E4' => '/logos/18_ardennes/port.svg',
          'F4' => '/logos/18_ardennes/port.svg',
          'G3' => '/logos/18_ardennes/port.svg',
        }.freeze

        def setup_tokens
          @fort_corp = dummy_corp('Forts', '18_ardennes/fort', FORT_HEXES, true)
          @mine_corp = dummy_corp('Mines', '18_ardennes/mine', MINE_HEXES, false)
          @port_corp = dummy_corp('Ports', '18_ardennes/port', PORT_HEXES, false)
        end

        def dummy_corp(sym, logo, coords, hex_tokens)
          corp = Corporation.new(
            sym: sym,
            name: sym,
            logo: logo,
            simple_logo: logo,
            tokens: Array.new(coords.size, 0),
            type: :dummy
          )
          corp.owner = @bank

          coords.each do |coord|
            hex = hex_by_id(coord)
            city = hex.tile.cities.first
            token = corp.next_token
            if hex_tokens || !city.tokenable?(corp)
              hex.place_token(token)
            else
              city.place_token(corp, token)
            end
          end
        end

        def hexes_by_id(coordinates)
          coordinates.map { |coord| hex_by_id(coord) }
        end

        def fort_hexes
          @fort_hexes ||= hexes_by_id(FORT_HEXES)
        end

        def fort_destination_hexes
          @fort_destination_hexes ||= hexes_by_id(FORT_DESTINATIONS)
        end

        def tee_hexes(direction)
          @tee_hexes ||= {
            north: hexes_by_id(NORTH_HEXES),
            south: hexes_by_id(SOUTH_HEXES),
            east: hexes_by_id(EAST_HEXES),
            west: hexes_by_id(WEST_HEXES),
          }
          @tee_hexes[direction]
        end

        def north_cities
          tee_hexes(:north).map(&:tile).flat_map(&:cities)
        end

        def south_cities
          tee_hexes(:south).map(&:tile).flat_map(&:cities)
        end

        def east_cities
          tee_hexes(:east).map(&:tile).flat_map(&:cities)
        end

        def west_cities
          tee_hexes(:west).map(&:tile).flat_map(&:cities)
        end

        # The number of fort tokens a corporation has collected.
        def fort_tokens(corporation)
          corporation.assignments.keys.intersection(FORT_HEXES).size
        end

        # Returns 2 if a corporation has routes to both Paris and Strasbourg,
        # 1 if connected to just one of these, or zero if neither.
        def fort_destinations(corporation)
          graph_for_entity(corporation)
            .connected_hexes(corporation)
            .keys
            .intersection(fort_destination_hexes)
            .size
        end
      end
    end
  end
end
