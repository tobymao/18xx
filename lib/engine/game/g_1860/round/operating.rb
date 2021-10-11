# frozen_string_literal: true

require_relative '../../../round/operating'
require_relative '../../../action/dividend'
require_relative '../../../action/run_routes'

module Engine
  module Game
    module G1860
      module Round
        class Operating < Engine::Round::Operating
          def after_process(action)
            if (entity = @entities[@entity_index]).receivership? || @game.insolvent?(entity)
              case action
              when Engine::Action::RunRoutes
                process_action(Engine::Action::Dividend.new(entity, kind: 'withhold')) if action.routes.any?
              end
            elsif @game.nationalization
              case action
              when Engine::Action::RunRoutes
                process_action(Engine::Action::Dividend.new(entity, kind: 'payout'))
              end
            end

            super
          end

          def next_entity!
            after_operating(@entities[@entity_index])
            super
          end

          def after_operating(entity)
            return unless entity.corporation?

            @game.check_bankruptcy!(entity)
            return if @game.bankrupt?(entity)

            if entity.trains.empty? && @game.legal_route?(entity)
              @game.make_insolvent(entity)
            elsif !entity.trains.empty?
              @game.clear_insolvent(entity)
            end
          end

          def start_operating
            entity = @entities[@entity_index]
            @current_operator = entity
            @current_operator_acted = false
            entity.trains.each { |train| train.operated = false }
            @log << "#{@game.acting_for_entity(entity).name} operates #{entity.name}" unless finished?
            @game.place_home_token(entity) if @home_token_timing == :operate
            @game.update_crowded(entity)
            clear_cache!
            skip_steps
            next_entity! if finished?
          end
        end
      end
    end
  end
end
