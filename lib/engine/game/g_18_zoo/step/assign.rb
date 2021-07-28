# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module Step
        class Assign < Engine::Step::Assign
          def available_hex(entity, hex)
            return unless entity.company?
            return unless entity.owner&.corporation?
            return if entity == @game.wheat && entity.owner.tokens.none? { |token| token&.city&.hex == hex }
            return if entity == @game.hole && !available_hex_for_hole?(entity, hex)
            return if entity == @game.that_s_mine && !available_hex_for_mine?(entity, hex)
            return if entity == @game.work_in_progress && !available_hex_for_work_in_progress?(hex)
            return if hex.assigned?(entity.id)

            @game.hex_by_id(hex.id).neighbors.keys
          end

          def description
            "Select hex for #{@company.name}"
          end

          def active_entities
            @company ? [@company] : super
          end

          def blocks?
            @company
          end

          def process_assign(action)
            entity = action.entity
            target = action.target

            return process_assign_that_s_mine(action) if action.entity == @game.that_s_mine
            return process_assign_work_in_progress(action) if action.entity == @game.work_in_progress

            super

            @game.assign_hole(entity, target) if entity == @game.hole

            @company = entity == @game.hole && !entity.all_abilities.empty? ? entity : nil
            return if @company

            @log << "#{entity.name} closes"
            entity.close!
          end

          private

          def available_hex_for_hole?(_entity, hex)
            return false if hex.tile.label.to_s != 'R'
            return false if @game.optional_rules.include?(:base_3) && @game.game_base_3.key?(hex.coordinates)
            return false if @game.optional_rules.include?(:base_2) && !@game.optional_rules.include?(:base_3) &&
              @game.game_base_2.key?(hex.coordinates)

            true
          end

          def available_hex_for_mine?(entity, hex)
            hex.tile.color != :white &&
              !hex.tile.cities.empty? &&
              !hex.tile.cities.first.tokened_by?(entity.owner) &&
              hex.tile.cities.first.available_slots.positive?
          end

          def process_assign_that_s_mine(action)
            hex = action.target
            entity = action.entity
            unless available_hex_for_mine?(entity, hex)
              raise GameError, "Cannot place token on #{hex.name} as the hex is not available"
            end

            hex.tile.add_reservation!(entity.owner, 0)
            @log << "#{entity.owner.name} reserves #{hex.name}"

            @game.that_s_mine.remove_ability(@game.that_s_mine.all_abilities[0])

            @game.that_s_mine.desc = "Can convert reserved token in #{hex.name} into own"
            new_ability = Ability::Token.new(type: 'token', hexes: [hex.id], owner_type: 'corporation',
                                             extra_slot: false, from_owner: true, when: 'owning_corp_or_turn',
                                             special_only: true, discount: 0)
            @game.that_s_mine.add_ability(new_ability)
          end

          def available_hex_for_work_in_progress?(hex)
            hex.tile.color != :white &&
              !hex.tile.cities.empty? &&
              hex.tile.cities.first.available_slots.positive?
          end

          def process_assign_work_in_progress(action)
            hex = action.target
            unless available_hex_for_work_in_progress?(hex)
              raise GameError, "Cannot place token on #{hex.name} as the hex is not available"
            end

            token = Engine::Token.new(nil, price: 0, logo: '/icons/18_zoo/block.svg', type: :blocking)
            hex.tile.cities.first.exchange_token(token)
            @game.graph.clear_graph_for_all
            @log << "#{action.entity.name} blocks a slot in #{hex.name}"

            @log << "#{action.entity.name} closes"
            action.entity.close!
          end
        end
      end
    end
  end
end
