# frozen_string_literal: true

module Engine
  module Game
    module G18RoyalGorge
      module Step
        class Dividend < Engine::Step::Dividend
          GOLD_BONUS = 50
          NUGGET_BONUS = 130

          def help
            "You may ship a gold cube from the map for +#{@game.format_currency(GOLD_BONUS)}" if choosing?(current_entity)
          end

          def actions(entity)
            actions = super.dup
            actions << 'choose' if choosing?(entity) ||
                                   (shipper?(entity) && choosing?(entity.owner))
            actions
          end

          def share_price_change(entity, revenue = 0)
            price = entity.share_price.price
            return { share_direction: :left, share_times: 1 } if revenue.zero?

            times = [(revenue / price).to_i, 3].min
            if times.positive?
              { share_direction: :right, share_times: times }
            else
              {}
            end
          end

          def setup
            @shippable_gold = nil
            @shipped_gold = false
          end

          # choices that still need to be implemented:
          #
          # - Y2: after last gold is shipped from a hex, may place a ghost town
          # token there

          def choice_name
            "Choose a Gold to ship for +#{@game.format_currency(GOLD_BONUS)}"
          end

          def choosing?(entity)
            entity == current_entity && !@shipped_gold && @game.gold_slots_available? && !shippable_gold.empty?
          end

          def choices
            ship_gold_choices
          end

          def ship_gold_choices
            shippable_gold.to_h do |hex, _|
              if hex.location_name
                [hex.id, "#{hex.id} (#{hex.location_name})"]
              else
                [hex.id, hex.id]
              end
            end
          end

          def process_choose(action)
            ship_gold(action)
          end

          def ship_gold(action)
            @shipped_gold = true
            @game.gold_shipped += 1
            @game.update_gold_corp_cash!

            entity = action.entity
            hex_id = action.choice
            hex = @game.hex_by_id(hex_id)
            location = hex.location_name ? " (#{hex.location_name})" : ''

            if entity == @game.gold_nugget
              log_entity = "#{entity.owner.name} (#{entity.name})"
              bonus = NUGGET_BONUS
              @log << "#{entity.name} closes"
              entity.close!
            else
              log_entity = entity.name
              bonus = GOLD_BONUS
            end
            @round.extra_revenue += bonus
            @log << "#{log_entity} ships gold from #{hex_id}#{location} for +#{@game.format_currency(bonus)}"

            @game.gold_cubes[hex_id] -= 1
            icons = hex.tile.icons
            icon = icons.find { |i| i.name == 'gold' }
            icons.delete(icon)

            if @game.local_jeweler&.player
              jeweler_bonus = 5
              @game.local_jeweler_cash += jeweler_bonus
              @log << "#{@game.local_jeweler.player.name}'s #{@game.local_jeweler.name} receives "\
                      "#{@game.format_currency(jeweler_bonus)}"
            end

            @game.gold_cubes.delete(hex_id) if @game.gold_cubes[hex_id].zero?
          end

          def shippable_gold
            @shippable_gold ||=
              begin
                hexes = @round.routes.flat_map(&:all_hexes).uniq
                hexes = hexes.select do |hex|
                  @game.gold_cubes.include?(hex.id)
                end.sort
                hexes
              end
          end

          def available_hex(entity, hex)
            !@shipped_gold &&
              shipper?(entity) &&
              shippable_gold.include?(hex)
          end

          # choices are accessed via the map
          def render_choices?
            false
          end

          def shipper?(entity)
            entity == current_entity ||
              (entity == @game.gold_nugget && entity.owner == current_entity)
          end
        end
      end
    end
  end
end
