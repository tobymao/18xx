# frozen_string_literal: true

require_relative '../../g_1880/step/route'

module Engine
  module Game
    module G1880Romania
      module Step
        class Route < G1880::Step::Route
          def actions(entity)
            actions = super.dup
            actions.append('choose') if !actions.empty? && choosing_tender?(entity)
            actions
          end

          def choice_name
            'Attach REMAR tender (+1 town stop) to a train'
          end

          def choices
            choices = {}
            tender_train_choices(current_entity).each_with_index do |train, index|
              choices[index.to_s] = "#{train.name} train"
            end
            choices
          end

          def process_choose(action)
            entity = action.entity
            @round.tender_train = tender_train_choices(entity)[action.choice.to_i]
            @log << "#{entity.name} attaches the REMAR tender to a #{@round.tender_train.name} train"
            attach_tender
          end

          def round_state
            super.merge(
              tender_train: nil,
              tender_original_train: nil,
            )
          end

          def process_run_routes(action)
            super
            detach_tender if @round.tender_train
          end

          private

          def choosing_tender?(entity)
            !@round.tender_train &&
              entity.corporation? &&
              entity.assigned?(@game.remar.id) &&
              !tender_train_choices(entity).empty?
          end

          def tender_train_choices(entity)
            entity.runnable_trains
          end

          def attach_tender
            @round.tender_original_train = @round.tender_train.dup

            distance = @round.tender_train.distance
            distance = if distance.is_a?(Numeric)
                         [{ 'nodes' => %w[city offboard town], 'pay' => distance, 'visit' => distance }]
                       else
                         distance.map(&:dup)
                       end

            distance << { 'nodes' => ['town'], 'pay' => 0, 'visit' => 0 } unless distance.any? { |n| n['nodes'] == ['town'] }

            town_part = distance.find { |n| n['nodes'] == ['town'] }
            town_part['pay'] += 1
            town_part['visit'] += 1

            @round.tender_train.distance = distance

            @round.tender_train.name = tender_name(@round.tender_train.name)
          end

          def detach_tender
            @round.tender_train.name = @round.tender_original_train.name
            @round.tender_train.distance = @round.tender_original_train.distance
            @round.tender_original_train = nil
            @round.tender_train = nil
          end

          def tender_name(name)
            if (m = name.match(/^(.+)\+(\d+)(.*)$/))
              "#{m[1]}+#{m[2].to_i + 1}#{m[3]}"
            else
              "#{name}+1"
            end
          end
        end
      end
    end
  end
end
