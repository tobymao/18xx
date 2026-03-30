# frozen_string_literal: true

require_relative '../../g_1858/step/route'

module Engine
  module Game
    module G1858India
      module Step
        class Route < G1858::Step::Route
          def actions(entity)
            actions = super.dup
            actions << 'choose' if !actions.empty? && choosing?(entity)
            actions
          end

          def choice_name
            'Attach Pullman to another train'
          end

          def help
            return unless @game.owns_pullman?(current_entity)
            return unless attachable_trains(current_entity).empty?

            "#{current_entity.id} owns a Pullman but does not own any " \
              'broad gauge trains that it can be attached to.'
          end

          def choices
            attachable_trains(current_entity).to_h do |train|
              [train.id, "#{train.name} train"]
            end
          end

          def round_state
            super.merge({ pullmans: {} })
          end

          def process_choose(action)
            @round.pullmans[action.entity] = @game.train_by_id(action.choice)
          end

          def train_name(corporation, train)
            return train.name unless @round.pullmans[corporation] == train

            "#{train.name} + Pullman"
          end

          def log_extra_revenue(entity, extra_revenue)
            return unless extra_revenue&.nonzero?

            @log << "#{entity.name} receives " \
                    "#{@game.format_revenue_currency(extra_revenue)} " \
                    'revenue from mines and ports.'
          end

          private

          def runnable_trains(entity)
            super.reject { |train| @game.pullman?(train) }
          end

          def choosing?(corporation)
            @game.owns_pullman?(corporation) &&
              !pullman_attached?(corporation) &&
              !attachable_trains(corporation).empty?
          end

          # The trains that a Pullman can be attached to.
          def attachable_trains(corporation)
            corporation.trains.select do |train|
              train.track_type == :broad && !@game.pullman?(train)
            end
          end

          def pullman_attached?(corporation)
            !@round.pullmans[corporation].nil?
          end
        end
      end
    end
  end
end
