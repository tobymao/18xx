# frozen_string_literal: true

require_relative '../../../step/assign'

module Engine
  module Game
    module G1868WY
      module Step
        class Assign < Engine::Step::Assign
          def description
            case current_entity
            when @game.lhp_private
              'Assign the LHP 2+1 train to a Railroad Company'
            end
          end

          def help
            case current_entity
            when @game.lhp_private
              "#{@game.lhp_private.name} is closing. You may assign the 2+1 train to a Railroad Company for no compensation."
            end
          end

          def actions(entity)
            actions =
              case entity
              when @game.lhp_private
                %w[assign pass] if @game.lhp_train_pending?
              end
            actions || []
          end

          def process_assign(action)
            case entity
            when @game.lhp_private
              @game.convert_lhp_train!(action.target)
            end
          end

          def process_pass(action)
            return super unless action.entity == @game.lhp_private

            @game.pass_converting_lhp_train!
          end

          def active_entities
            if @game.lhp_train_pending?
              [@game.lhp_private]
            else
              super
            end
          end

          def blocks?
            @game.lhp_train_pending?
          end

          def assignable_corporations(company)
            return [] unless company == @game.lhp_private
            return [] unless @game.lhp_train_pending?

            super
          end

          def log_skip(_entity); end
        end
      end
    end
  end
end
