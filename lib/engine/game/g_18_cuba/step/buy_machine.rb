# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18Cuba
      module Step
        class BuyMachine < Engine::Step::Base
          ACTIONS = %w[choose pass].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] if @game.buyable_machine_generations(entity).empty?

            ACTIONS
          end

          def description
            'Buy Machines'
          end

          def choice_name
            'Buy a sugar mill machine'
          end

          def choices
            @game.buyable_machine_generations(current_entity).to_h do |generation|
              [generation.to_s, "#{generation.to_s.capitalize} (+#{@game.format_currency(@game.machine_bonus(generation))}) "\
                                "for #{@game.format_currency(@game.machine_price(generation))}"]
            end
          end

          def process_choose(action)
            generation = action.choice.to_sym
            unless @game.buyable_machine_generations(action.entity).include?(generation)
              raise GameError, "#{action.entity.name} cannot buy a #{action.choice} machine"
            end

            @game.buy_machine!(action.entity, generation)
          end

          def log_skip(entity)
            super if entity.type == :minor
          end
        end
      end
    end
  end
end
