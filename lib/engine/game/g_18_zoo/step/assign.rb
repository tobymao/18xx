# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module Step
        class Assign < Engine::Step::Assign
          def available_hex(entity, hex)
            return unless entity.company?
            return unless entity.owner&.corporation?
            return if entity == @game.corn && entity.owner.tokens.none? { |token| token&.city&.hex == hex }
            return if entity == @game.hole && hex.tile.label.to_s != 'R'
            return if entity == @game.that_is_mine && !available_hex_for_mine?(entity, hex)
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

            return process_assign_that_is_mine(action) if action.entity == @game.that_is_mine
            return process_assign_work_in_progress(action) if action.entity == @game.work_in_progress

            super

            @game.assign_hole(entity, target) if entity == @game.hole

            @company = entity == @game.hole && !entity.all_abilities.empty? ? entity : nil
            return if @company

            @log << "#{entity.name} closes"
            entity.close!
          end

          private

          def available_hex_for_mine?(entity, hex)
            !hex.tile.cities.empty? &&
              !hex.tile.cities.first.tokened_by?(entity.owner) &&
              hex.tile.cities.first.available_slots.positive?
          end

          def process_assign_that_is_mine(action)
            action.target.tile.cities.first.add_reservation!(action.entity.owner)
            @log << "#{action.entity.owner.name} reserves #{action.target.name}"

            @game.that_is_mine.remove_ability(@game.that_is_mine.all_abilities[0])

            @game.that_is_mine.desc = "Can convert reserved token in #{action.target.name} into own"
            new_ability = Ability::Token.new(type: 'token', hexes: [action.target.id], owner_type: 'corporation',
                                             extra_slot: false, from_owner: true, when: 'owning_corp_or_turn',
                                             special_only: true, discount: 0)
            @game.that_is_mine.add_ability(new_ability)
          end

          def available_hex_for_work_in_progress?(hex)
            !hex.tile.cities.empty? &&
              hex.tile.cities.first.available_slots.positive?
          end

          def process_assign_work_in_progress(action)
            token = Engine::Token.new(nil, price: 0, logo: '/icons/18_zoo/block.svg', type: :blocking)
            action.target.tile.cities.first.exchange_token(token)
            @game.graph.clear_graph_for_all
            @log << "#{action.entity.name} blocks a slot in #{action.target.name}"

            @log << "#{action.entity.name} closes"
            action.entity.close!
          end
        end
      end
    end
  end
end
