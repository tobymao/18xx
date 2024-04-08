# frozen_string_literal: true

module Engine
  module Game
    module G18RoyalGorge
      module Step
        class Dividend < Engine::Step::Dividend
          GOLD_BONUS = 50
          NUGGET_BONUS = 130

          GHOST_BONUS = 10
          GHOST_CHOICE = 'ghost_town'

          def help
            return unless choosing?(current_entity)

            case @choose_state
            when :gold
              "You may ship a gold cube from the map for +#{@game.format_currency(GOLD_BONUS)}"
            end
          end

          def actions(entity)
            actions = super.dup
            actions << 'choose' if choosing?(entity)

            # puts "actions(#{entity.name}) = #{actions.to_s}" if [entity, entity.owner].include?(current_entity)
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
            # puts 'setup!'

            # :gold, :ghost, :done
            @choose_state = :gold

            @shippable_gold = nil
            @gold_hex = nil

            @placed_ghost_town = false
          end

          def choice_name
            case @choose_state
            when :gold
              "Choose a Gold to ship for +#{@game.format_currency(GOLD_BONUS)}"
            when :ghost
              "You may place a Ghost Town in #{@gold_hex.id} for "\
              "+#{@game.format_currency(GHOST_BONUS)} on future routes for "\
              "#{@game.ghost_town_tours&.owner&.name}"
            end
          end

          def choosing?(entity)
            case @choose_state
            when :gold
              gold_shipper?(entity) &&
                @game.gold_slots_available? && !shippable_gold.empty?
            when :ghost
              ghost_town_corp?(entity) &&
                ghost_town_ability&.count&.positive? && @gold_hex.tile.icons.none? { |i| i.name == 'gold' }
            end
          end

          def choices
            case @choose_state
            when :gold
              ship_gold_choices
            when :ghost
              ghost_town_choices
            end
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

          def ghost_town_choices
            { GHOST_CHOICE => 'Place a Ghost Town' }
          end

          def process_choose(action)
            case @choose_state
            when :gold
              ship_gold(action)
              @choose_state = ghost_town_corp?(current_entity) ? :ghost : :done
            when :ghost
              place_ghost_town(action)
              @choose_state = :done
            end
          end

          def ship_gold(action)
            @game.gold_shipped += 1
            @game.update_gold_corp_cash!

            entity = action.entity
            hex_id = action.choice
            hex = @game.hex_by_id(hex_id)
            @gold_hex = hex
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
            case @choose_state
            when :gold
              gold_shipper?(entity) &&
                @game.gold_slots_available? &&
                shippable_gold.include?(hex)
            when :ghost
              hex == @gold_hex
            end
          end

          def render_choices?
            case @choose_state
            when :gold
              # choices are accessed via the map
              false
            when :ghost
              true
            end
          end

          def gold_shipper?(entity)
            entity == current_entity ||
              (entity == @game.gold_nugget && entity.owner == current_entity)
          end

          def ghost_town_corp?(entity)
            entity == current_entity &&
              entity == @game.ghost_town_tours&.owner
          end

          def place_ghost_town(action)
            raise GameError, "Cannot place ghost town for choice \"#{action.choice}\"" unless action.choice == GHOST_CHOICE

            hex = @gold_hex

            @log << "#{action.entity.name} (#{@game.ghost_town_tours.name}) places a Ghost Town in #{hex.id}"

            # place the icon
            hex.tile.icons << Part::Icon.new('cow_skull', 'ghost_town')

            # use the cube
            ability = ghost_town_ability
            ability.use!

            @log << 'no more ghost town tokens' if ability.count.zero?
          end

          def ghost_town_ability
            @ghost_town_ability ||= @game.ghost_town_tours.all_abilities[0]
          end
        end
      end
    end
  end
end
