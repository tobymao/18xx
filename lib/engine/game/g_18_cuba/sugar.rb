# frozen_string_literal: true

module Engine
  module Game
    module G18Cuba
      module Sugar
        CUBE_VALUE = 30

        ASSIGNMENT_TOKENS = {
          'SUGAR0' => '/icons/18_cuba/sugar-cube.svg',
          'SUGAR1' => '/icons/18_cuba/sugar-cube.svg',
          'SUGAR2' => '/icons/18_cuba/sugar-cube.svg',
        }.freeze

        ASSIGNMENT_STACK_GROUPS = ASSIGNMENT_TOKENS.transform_values { |_| 'SUGAR' }.freeze

        def sugar_setup
          @sugar_cubes = {}
          reset_cubes_on_train
        end

        def sugar_cane_open_for_majors?
          @sugar_cane_open_for_majors
        end

        def sugar_production(corporation, total_revenue)
          return if total_revenue.zero? || corporation.type != :minor

          sugar_cubes = case total_revenue
                        when 0..29 then 0
                        when 30..79 then 1
                        when 80..150 then 2
                        else 3
                        end

          @sugar_cubes[corporation] = sugar_cubes
          @log << "#{corporation.name} produces #{sugar_cubes} sugar cube(s) "\
                  "from #{format_currency(total_revenue)} revenue."
          update_sugar_cube_icons(corporation, sugar_cubes)
        end

        # Cube loading modelled on 18Uruguay's goods.rb: train-centric, each cube tracked by source minor, up to wagon capacity.
        def train_with_cubes?(train)
          return false unless train

          !cubes_on_train(train).empty?
        end

        def cubes_on_train(train)
          @cubes_on_train[train.id] || []
        end

        def attach_cube_to_train(train, corp)
          (@cubes_on_train[train.id] ||= []) << corp
        end

        def unload_cubes(train)
          @cubes_on_train.delete(train.id)
        end

        # Cubes in a minor's warehouse not yet loaded onto any train.
        def unclaimed_cubes(corp)
          loaded = @cubes_on_train.values.sum { |list| list.count(corp) }
          sugar_cubes_for(corp) - loaded
        end

        def sugar_cubes_for(corp)
          @sugar_cubes[corp] || 0
        end

        def wagon_capacity(train)
          @round.wagon_for_train[train.id]&.distance || 0
        end

        # Minor corps whose sugar mill (home token) lies on this route and still has cubes.
        def mill_corps_on_route(route)
          route.visited_stops.each_with_object([]) do |stop, corps|
            next unless stop.city?

            stop.tokens.each do |token|
              corp = token&.corporation
              next unless corp&.type == :minor
              next unless sugar_cubes_for(corp).positive?

              corps << corp unless corps.include?(corp)
            end
          end
        end

        # Bonus for the cubes explicitly loaded onto this train, delivered to a harbor.
        def wagon_cube_bonus(route)
          cubes_on_train(route.train).size * CUBE_VALUE
        end

        # Delivers the cubes (return to supply); reads the cubes explicitly loaded onto each train.
        def collect_wagon_cubes(routes)
          routes.each do |route|
            cubes = cubes_on_train(route.train)
            next if cubes.empty?

            tally = cubes.tally
            tally.each do |corp, count|
              @sugar_cubes[corp] -= count
              update_sugar_cube_icons(corp, @sugar_cubes[corp])
            end
            sources = tally.map { |corp, count| "#{count} from #{corp.name}" }.join(', ')
            @log << "#{route.train.owner.name} delivers #{cubes.size} sugar cube(s) (#{sources}) "\
                    "for #{format_currency(cubes.size * CUBE_VALUE)}"
          end
        end

        def sugar_cane_hex?(hex)
          self.class::SUGAR_CANE_HEXES.include?(hex.id)
        end

        # TODO: Isla de Tesoros (20/40) special case
        def harbor?(stop)
          stop.hex.tile.icons.any? { |icon| icon.name == 'anchor' }
        end

        private

        def reset_cubes_on_train
          @cubes_on_train = {}
        end

        def extended_harbor_revenue(route, stops)
          return 0 unless @round.wagon_for_train.key?(route.train.id)
          return 0 unless route.train.distance.is_a?(Numeric)
          return 0 unless stops.sum(&:visit_cost) > route.train.distance

          # The wagon-extended harbor scores zero (rule VII.10); with two harbors zero the cheaper.
          # TODO: .min nulls the wrong harbor once harbor values differ (Isla de Tesoros 20/40);
          # today all harbors are 10, so .min is correct. Belongs in the Isla follow-up PR.
          stops.select { |s| harbor?(s) }.map { |s| s.route_revenue(route.phase, route.train) }.min || 0
        end

        def update_sugar_cube_icons(corporation, count)
          home_hex = corporation.tokens.first&.hex
          return unless home_hex

          ASSIGNMENT_TOKENS.each_key { |key| home_hex.remove_assignment!(key) }
          ASSIGNMENT_TOKENS.keys.first([count, 0].max).each { |key| home_hex.assign!(key) }
        end

        def sugar_cane_tile?(tile)
          tile.towns.any?(&:hidden?)
        end
      end
    end
  end
end
