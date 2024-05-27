# frozen_string_literal: true

module Engine
  module Game
    module G18Uruguay
      module Goods
        GOODS_DESCRIPTION_STR = 'Number of goods: '

        def goods_setup
          @pickup_hex_for_train = {}
          @goods_on_ship = {}
          @number_of_goods_at_harbor = 3
        end

        # Train delivery
        def train_with_goods?(train)
          return unless train

          @pickup_hex_for_train.key?(train.id)
        end

        def attach_good_to_train(train, hex)
          @pickup_hex_for_train[train.id] = hex
        end

        def good_pickup_hex(train)
          @pickup_hex_for_train[train.id]
        end

        def unload_good(train)
          @pickup_hex_for_train.delete(train.id) if train_with_goods?(train)
        end

        # Harbor
        def visits_include_port?(visits)
          visits.any? { |visit| self.class::PORTS.include?(visit.hex.id) }
        end

        def route_include_port?(route)
          route.hexes.any? { |hex| self.class::PORTS.include?(hex.id) }
        end

        def check_for_goods_if_run_to_port(route, visits)
          true if route.corporation == @rptla
          visits_include_port?(visits) || !train_with_goods?(route.train)
        end

        def check_for_port_if_goods_attached(route, visits)
          true if route.corporation == @rptla
          !visits_include_port?(visits) || train_with_goods?(route.train)
        end

        def number_of_goods_at_harbor
          @number_of_goods_at_harbor
        end

        def add_good_to_rptla
          ability = @rptla.abilities.find { |a| a.type == :Goods }
          return if ability.nil?

          @number_of_goods_at_harbor += 1
          ability.description = GOODS_DESCRIPTION_STR + @number_of_goods_at_harbor.to_s
        end

        def remove_goods_from_rptla(goods_count)
          return if @number_of_goods_at_harbor < goods_count

          ability = @rptla.abilities.find { |a| a.type == :Goods }
          return if ability.nil?

          @number_of_goods_at_harbor -= goods_count
          ability.description = GOODS_DESCRIPTION_STR + @number_of_goods_at_harbor.to_s
        end

        # Ship gooods
        def add_goods_to_ship(ship, count)
          @goods_on_ship[ship.id] = count
        end

        def remove_goods_from_ship(ship)
          return unless @goods_on_ship.key?(ship.id)

          @goods_on_ship[ship.id] = 0
        end

        def goods_on_ship(ship)
          return 0 unless @goods_on_ship.key?(ship.id)

          @goods_on_ship[ship.id]
        end

        # Clean up
        def remove_goods_from_map
          hexes.select do |hex|
            hex.assignments.keys.each do |assignment|
              hex.remove_assignment!(assignment) if assignment.include? 'GOODS'
            end
          end
        end
      end
    end
  end
end
