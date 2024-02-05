# frozen_string_literal: true

module Engine
  module Game
    module G18Uruguay
      module Farm
        ACTIONS_WITH_PASS = %w[assign pass].freeze
        ACTIONS_WITHOUT_PASS = %w[assign].freeze

        def setup
          @farm_id = nil
        end

        def farm; end

        def goods_type; end

        def goods
          @game.abilities_ignore_owner(farm, :assign_hexes, time: 'or_start', strict_time: false)
        end

        def used_this_or?
          goods
        end

        def blocking_for_farm?
          return false unless @round.operating?

          used_this_or?
        end

        def actions(_entity)
          return [] unless blocking_for_farm?

          ACTIONS_WITHOUT_PASS
        end

        def active_entities
          [farm]
        end

        def active?
          blocking_for_farm?
        end

        def blocks?
          active?
        end

        def neighbor_to_choosen_farm?(farm_id, hex_id)
          @game.hex_by_id(farm_id).neighbors.find do |neighbor|
            neighbor[1].id == hex_id \
            && neighbor[1].tile.city_towns.size.positive?
          end
        end

        def available_hex(entity, hex)
          return unless entity.company?
          return true if !@farm_id.nil? && neighbor_to_choosen_farm?(@farm_id, hex.id)
          # Is it mine?
          return unless entity.abilities[0].hexes&.include?(hex.id)
          # Do we have goods?
          return false if !@farm_id.nil? || !hex.assignments.keys.find { |a| a.include? goods_type }

          @game.hex_by_id(hex.id).neighbors.keys
        end

        def retreive_goods!(farm_id)
          hex = @game.hex_by_id(farm_id)
          good = hex.assignments.keys.find { |a| a.include? 'GOODS' }
          good + goods.count.to_s
        end

        def process_assign(action)
          if @farm_id.nil?
            @farm_id = action.target.id
            return
          end
          target = action.target
          good = retreive_goods!(@farm_id)

          target.assign!(good)

          if (ability = goods)
            ability.use!
            @log <<
                  "Goods has been delivered to #{target.name}"
          end
          @round.start_operating
        end

        def process_pass(action)
          raise GameError, "Not #{action.entity.name}'s turn: #{action.to_h}" unless action.entity == @farm

          if (ability = goods)
            ability.use!
          end
          pass!
        end
      end
    end
  end
end
