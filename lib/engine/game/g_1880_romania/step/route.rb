# frozen_string_literal: true

require_relative '../../g_1880/step/route'

module Engine
  module Game
    module G1880Romania
      module Step
        class Route < G1880::Step::Route
          def actions(entity)
            regular_actions = super
            return regular_actions if regular_actions.empty?
            return regular_actions + ['choose'] if choosing_tender?(entity)

            regular_actions
          end

          def choosing?(entity)
            choosing_tender?(entity)
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
            @tender_train = tender_train_choices(entity)[action.choice.to_i]
            @log << "#{entity.name} attaches the REMAR tender to a #{@tender_train.name} train"
            attach_tender
          end

          def process_run_routes(action)
            super
            detach_tender if @tender_train

            bonus = @game.stock_market_bonus(action.entity)
            return unless bonus.positive?

            @round.extra_revenue = (@round.extra_revenue || 0) + bonus
            @log << "#{action.entity.name} receives #{@game.format_currency(bonus)} stock market bonus"
          end

          private

          def choosing_tender?(entity)
            @tender_train ||= nil
            !@tender_train &&
              !@game.remar.closed? &&
              entity.corporation? &&
              entity.assigned?(@game.remar.id) &&
              !tender_train_choices(entity).empty?
          end

          def tender_train_choices(entity)
            entity.runnable_trains
          end

          def attach_tender
            @tender_original_train = @tender_train.dup

            if @tender_train.distance.is_a?(Numeric)
              city_dist = @tender_train.distance
              @tender_train.distance = [
                { 'nodes' => %w[city offboard town], 'pay' => city_dist, 'visit' => city_dist },
                { 'nodes' => ['town'], 'pay' => 1, 'visit' => 1 },
              ]
            else
              town_part_index = @tender_train.distance.index { |n| n['nodes'] == ['town'] }
              if town_part_index
                new_distance = @tender_train.distance.map(&:dup)
                new_distance[town_part_index]['pay'] += 1
                new_distance[town_part_index]['visit'] += 1
                @tender_train.distance = new_distance
              else
                @tender_train.distance = @tender_train.distance + [{ 'nodes' => ['town'], 'pay' => 1, 'visit' => 1 }]
              end
            end

            @tender_train.name = tender_name(@tender_train.name)
            @game.clear_graph
          end

          def detach_tender
            @tender_train.name = @tender_original_train.name
            @tender_train.distance = @tender_original_train.distance
            @tender_original_train = nil
            @tender_train = nil
            @game.clear_graph
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
