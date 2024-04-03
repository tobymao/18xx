# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G18RoyalGorge
      module Step
        class Route < Engine::Step::Route
          CHOOSE_STATES = %i[coal_mines coal_depot engineer].freeze

          CHOICE_NAMES = {
            engineer: "may increase one train's number by 1",
            coal_mines: "may spend up to 2 coal cubes to increase one train's number 1 per cube",
            coal_depot: "may spend up to 2 coal cubes to increase one train's number 1 per cube",
          }.freeze

          MAX_COAL_CUBES = 2

          def round_state
            super.merge(
              {
                hanging_bridge_lease_payment: 0,
              }
            )
          end

          def setup
            @choices_already_setup = false
            @original_variants = {}
            @chosen_trains = {}
          end

          def setup_choices
            @choices_already_setup = true

            @choose_companies = {
              engineer: @game.track_engineer,
              coal_mines: @game.coal_creek_mines,
              coal_depot: @game.coal_depot,
            }.select { |_, c| c&.owner == current_entity }

            @choose_states = CHOOSE_STATES.select { |s| valid_choose_state?(s) }
            advance_choose_state!

            @choice_names = @choose_companies.to_h do |choice_sym, company|
              [choice_sym, "#{company.name} - #{current_entity.name} #{CHOICE_NAMES[choice_sym]}"]
            end
          end

          def valid_choose_state?(choose_state)
            return false unless @choose_companies[choose_state]
            return false if @chosen_trains.include?(choose_state)
            return true if choose_state == :engineer

            ability = coal_cube_ability(choose_state)
            ability.count.positive?
          end

          def available_hex(entity, hex)
            return true if entity == @game.hanging_bridge_lease&.owner

            @game.graph_for_entity(entity).reachable_hexes(entity)[hex]
          end

          def process_run_routes(action)
            super

            restore_original_variants unless @original_variants.empty?

            if @game.coal_creek_mines&.owner&.corporation? &&
               (route = action.routes.find { |r| r.hexes.any? { |h| h.id == @game.class::COAL_CREEK_MINES_HEX } })
              @game.move_coal_creek_mines_cube!(action.entity)
            end

            return unless action.entity == @game.hanging_bridge_lease&.owner
            return if action.entity == @game.rio_grande
            return unless (route = action.routes.find { |r| r.hexes.any? { |h| h.id == @game.class::ROYAL_GORGE_TOWN_HEX } })

            @round.hanging_bridge_lease_payment = route.revenue / 10
          end

          def actions(entity)
            actions = super.dup
            actions << 'choose' if !actions.empty? && choosing?(entity)
            actions
          end

          def choosing?(entity)
            return false unless entity == current_entity

            setup_choices unless @choices_already_setup
            @choose_state && !choices.empty?
          end

          def advance_choose_state!
            @choose_state = @choose_states.pop
          end

          def choice_name
            @choice_names[@choose_state]
          end

          def choosing_company
            @choose_companies[@choose_state]
          end

          def choices
            return unless @choose_state

            skip_key = "#{@choose_state}/skip/0"
            init_obj = @choose_states.empty? ? {} : { skip_key => 'Skip' }

            choices = (current_entity.trains - @chosen_trains.values).uniq(&:name).each_with_object(init_obj) do |train, obj|
              if @choose_state == :engineer
                obj["engineer/#{train.id}/1"] = "#{train.name} train"
              else
                cubes = [MAX_COAL_CUBES, coal_cube_ability(@choose_state).count].min
                (1..cubes).each do |num_cubes|
                  obj["#{@choose_state}/#{train.id}/#{num_cubes}"] =
                    "Spend #{num_cubes} coal cube#{num_cubes == 1 ? '' : 's'} on #{train.name} train"
                end
              end
            end

            if choices.keys == [skip_key]
              {}
            else
              choices
            end
          end

          def coal_cube_ability(choose_state)
            current_entity.abilities.find { |a| a.type =~ /#{choose_state}/ }
          end

          def spend_coal_cubes!(amount)
            return if @choose_state == :engineer

            ability = coal_cube_ability(@choose_state)
            amount.times { ability.use! }
            ability.description = ability.description.sub(/\d+/, ability.count.to_s)
          end

          def process_choose(action)
            choose_state, train_id, amount = action.choice.split('/')
            unless @choose_state == choose_state.to_sym
              raise GameError,
                    "Expected choice for #{@choose_state}, got #{choose_state}"
            end

            if train_id == 'skip'
              # move current state to end of queue so undoing is not necessary
              # if player changes their mind about using this company
              @choose_states.unshift(@choose_state)
            else
              train = @game.train_by_id(train_id)
              amount = amount.to_i

              spend_coal_cubes!(amount)

              # save train name so it can be restored
              @original_variants[@choose_state] = train.name

              # upgraded info
              new_length = train.distance[0]['visit'] + amount
              new_name = train.name.sub(/\d+/, new_length.to_s)

              # create upgraded variant if necessary
              unless train.variants.include?(new_name)
                distance = train.distance.map.with_index do |dist, index|
                  next { **dist } unless index.zero?

                  {
                    **dist,
                    'pay' => dist['pay'] + amount,
                    'visit' => dist['visit'] + amount,
                  }
                end
                train.add_variant({
                                    name: new_name,
                                    distance: distance,
                                    buyable: false,
                                  })
              end

              # use the upgraded variant
              train.variant = new_name

              # save train so it cannot be upgraded by another company and so it
              # can be restored
              @chosen_trains[@choose_state] = train

              extend_str =
                if @choose_state == :engineer
                  'extends'
                else
                  "spends #{amount} coal cube#{amount == 1 ? '' : 's'} to extend"
                end
              @log << "#{@choose_companies[@choose_state].owner.name} "\
                      "(#{@choose_companies[@choose_state].name}) #{extend_str} a "\
                      "#{@original_variants[@choose_state]} train to a "\
                      "#{@chosen_trains[@choose_state].name} train"
            end

            advance_choose_state!
          end

          def restore_original_variants
            @chosen_trains.each do |choose_state, train|
              train.variant = @original_variants[choose_state]
            end

            @original_variants.clear
            @chosen_trains.clear
          end
        end
      end
    end
  end
end
