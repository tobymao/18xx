# frozen_string_literal: true

module Engine
  module Game
    module G18Norway
      module Step
        class NationalizeCorporation < Engine::Step::Base
          def description
            'Nationalization offer'
          end

          def actions(entity)
            return [] if !entity.corporation? || entity != current_entity
            return [] if @game.nationalized?(entity.corporation)

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
            choices_hash['0'] = 'Nationalize company by selling 0 shares to NSB' if @game.hovedbanen?(current_entity)
            choices_hash['1'] = 'Nationalize company by selling 1 share to NSB'
            choices_hash['2'] = 'Nationalize company by selling 2 shares to NSB' if @game.hovedbanen?(current_entity)
            choices_hash['decline'] = 'Decline nationalization offer'
            choices_hash
          end

          def process_choose(action)
            if action.choice == 'decline'
              @log << "#{action.entity.name} declines #{description.downcase}"
              pass!
              return
            end

            @game.nationalize_corporation(action.entity, action.choice.to_i)
            @game.next_round!
          end
        end
      end
    end
  end
end
