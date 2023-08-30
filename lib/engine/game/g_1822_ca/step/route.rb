# frozen_string_literal: true

require_relative '../../g_1822/step/route'

module Engine
  module Game
    module G1822CA
      module Step
        class Route < G1822::Step::Route
          CHOICE_SKIP = 'None'

          TRAIN_STR = {
            pullman: 'pullman',
            grain: 'grain train',
          }.freeze

          def setup
            @choosing = nil
            @skipped = { pullman: false, grain: false }

            @game.train_with_pullman = @pullman_train = nil
            @game.train_with_grain = @grain_train = nil
          end

          def choosing?(entity)
            @choosing =
              if choosing_pullman?(entity)
                :pullman
              elsif choosing_grain_train?(entity)
                :grain
              end
          end

          def choice_name
            case @choosing
            when :pullman
              super
            when :grain
              'Attach grain train (G) to a train'
            else
              ''
            end
          end

          def choices
            choices = { CHOICE_SKIP => CHOICE_SKIP }
            train_choices =
              case @choosing
              when :pullman
                super
              when :grain
                grain_train_choices(current_entity).each_with_index.with_object({}) do |(train, index), c|
                  c[index.to_s] = "#{train.name} train"
                end
              else
                raise GameError, 'Unexpected value for @choosing when calling `choices`'
              end
            choices.merge!(train_choices)
            choices
          end

          def process_choose(action)
            entity = action.entity

            if action.choice == CHOICE_SKIP
              @skipped[@choosing] = true
              @log << "#{entity.id} skips attaching #{TRAIN_STR[@choosing]}"
              return
            end

            case @choosing
            when :pullman
              super
              @game.train_with_pullman = @pullman_train
            when :grain
              @grain_train = grain_train_choices(entity)[action.choice.to_i]
              @game.train_with_grain = @grain_train
              @log << "#{entity.id} attaches the grain train to a #{@grain_train.name} train"
              attach_grain_train
            else
              raise GameError, 'Unexpected value for @choosing when processing action "choose"'
            end
          end

          def process_run_routes(action)
            super

            detach_grain_train if @grain_train
          end

          def attach_pullman
            @pullman_original_train = @pullman_train.dup
            distance = train_city_distance(@pullman_train)

            towns = 2 * distance

            @pullman_train.name += "+#{towns}"
            @pullman_train.distance = [
              {
                'nodes' => ['town'],
                'pay' => towns,
                'visit' => towns,
              },
              {
                'nodes' => %w[city offboard town],
                'pay' => distance,
                'visit' => distance,
              },
            ]
          end

          def detach_pullman
            super
            @game.train_with_pullman = @pullman = nil
          end

          def choosing_pullman?(entity)
            !@skipped[:pullman] && super
          end

          def choosing_grain_train?(entity)
            @grain_train ||= nil
            !@skipped[:grain] && !@grain_train && find_grain_train(entity) && !grain_train_choices(entity).empty?
          end

          def find_grain_train(entity)
            entity.trains.find { |t| @game.grain_train?(t) }
          end

          def grain_train_choices(entity)
            @game.route_trains(entity).reject do |t|
              t.name == @game.class::E_TRAIN || t == @pullman_train
            end
          end

          def attach_grain_train
            @grain_original_train = @grain_train.dup

            grain_distance = {
              'nodes' => [@game.class::GRAIN_ELEVATOR_TYPE],
              'pay' => @game.class::GRAIN_ELEVATOR_COUNT,
              'visit' => @game.class::GRAIN_ELEVATOR_COUNT,
            }
            original_distance =
              if @grain_train.distance.is_a?(Numeric)
                [
                  {
                    'nodes' => %w[city offboard town],
                    'pay' => @grain_train.distance,
                    'visit' => @grain_train.distance,
                  },
                ]
              else
                @grain_train.distance
              end
            @grain_train.distance = [grain_distance, *original_distance]

            # allows selecting routes in the UI with more than 2 stops, if
            # attached to the LP
            @grain_train.no_local = true

            @grain_train.name += (@grain_train.name[-1] == 'P' ? '-G' : 'G')
          end

          def detach_grain_train
            @grain_train.name = @grain_original_train.name
            @grain_train.no_local = false

            @grain_original_train = nil
            @game.train_with_grain = @grain_train = nil
          end
        end
      end
    end
  end
end
