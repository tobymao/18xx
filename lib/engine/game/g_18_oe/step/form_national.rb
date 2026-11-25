# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18OE
      module Step
        class FormNational < Engine::Step::Base
          ACTIONS = %w[choose].freeze

          def actions(entity)
            entity && entity == @game.national_formation_player ? ACTIONS : []
          end

          def active_entities
            [@game.national_formation_player].compact
          end

          def active?
            !!@game.national_formation_player
          end

          def description
            'Form Nationals'
          end

          def choice_name
            "#{current_entity.name} forms nationals"
          end

          def choices
            options = @game.national_candidates(current_entity).to_h { |major| [major.id, "Convert #{major.name}"] }
            options['done'] = 'Done'
            options
          end

          def process_choose(action)
            player = action.entity
            choice = action.choice
            if choice == 'done'
              @log << "#{player.name} declines to form a national"
              return @game.national_formation_done!(player)
            end

            major = @game.national_candidates(player).find { |candidate| candidate.id == choice }
            raise GameError, "Cannot convert #{choice} to a national" unless major

            @game.form_national!(major)
            @game.national_formation_done!(player) if @game.national_candidates(player).empty?
          end
        end
      end
    end
  end
end
