# frozen_string_literal: true

module Engine
  module Game
    module GSystem18
      module Step
        class GotlandNationalizeCorporation < Engine::Step::Base
          def description
            'Nationalization offer'
          end

          def actions(entity)
            return [] if !entity.corporation? || entity != current_entity
            return [] if @game.nationalized?(entity.corporation)
            return [] if @round.nationalization_complete

            ['choose']
          end

          def choice_name
            'Nationalize Corporation'
          end

          def log_skip(entity)
            return if @game.nationalized?(entity.corporation)

            super
          end

          def choices
            choices_hash = {}
            choices_hash['1'] = 'Nationalize company'
            choices_hash['decline'] = 'Decline nationalization offer'
            choices_hash
          end

          def process_choose(action)
            if action.choice == 'decline'
              @log << "#{action.entity.name} declines #{description.downcase}"
              pass!
              return
            end
            @game.round.nationalization_complete = true
            @game.nationalize_corporation(action.entity) if @game.allow_nationalize?(action.entity.corporation)
          end
        end
      end
    end
  end
end
