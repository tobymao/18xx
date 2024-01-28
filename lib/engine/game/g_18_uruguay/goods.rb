# frozen_string_literal: true

module Engine
  module Game
    module G18Uruguay
      module Goods
        def goods_setup
          @pickup_hex_for_train = {}
        end

        def train_with_goods?(train)
          return unless train

          @pickup_hex_for_train.key?(train.id)
        end

        def attach_good_to_train(train, hex)
          train.name += '+' + self.class::GOODS_TRAIN + '(' + hex.id + ')' if hex
          @pickup_hex_for_train[train.id] = hex
        end

        def good_pickup_hex(train)
          @pickup_hex_for_train[train.id]
        end

        def unload_good(train)
          train.name = train.name.partition('+')[0] unless train.nil?
          @pickup_hex_for_train.delete(train.id) if train_with_goods?(train)
        end

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
      end
    end
  end
end
