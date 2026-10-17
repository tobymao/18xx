# frozen_string_literal: true

require_relative '../../g_1867/step/merge'

module Engine
  module Game
    module G1864
      module Step
        class Merge < G1867::Step::Merge
          def setup
            super
            @extra_station_choices = {}
          end

          def extra_station_choices
            @extra_station_choices ||= {}
          end

          def actions(entity)
            return [] if !@converting && !@merge_major && !major_available?
            return %w[choose] if entity == current_entity && undecided_extra_station

            super
          end

          def major_available?
            @game.corporations.any? { |c| c.type == :major && !c.floated? }
          end

          def undecided_extra_station
            return if !@converting && !@merge_major

            (@merging || [@converting]).flat_map { |corporation| @game.extra_stations(corporation) }
              .find { |company, _token| !extra_station_choices.key?(company) }
          end

          def choice_name
            company, token = undecided_extra_station
            "#{company.name} in #{token.city.hex.location_name}"
          end

          def choices
            company, = undecided_extra_station
            {
              'replace' => "Replace #{company.name} with a regular station",
              'keep' => "Keep as the #{company.name} (removed at Phase 6)",
            }
          end

          def process_choose(action)
            company, token = undecided_extra_station
            raise GameError, 'No extra station to decide' unless company
            raise GameError, "Invalid choice #{action.choice}" unless choices.key?(action.choice)

            extra_station_choices[company] = action.choice
            location = token.city.hex.location_name
            @log <<
              if action.choice == 'replace'
                "#{action.entity.name} replaces its #{company.name} in #{location} with a regular station"
              else
                "#{action.entity.name} keeps its #{company.name} in #{location}"
              end
          end

          def process_merge(action)
            super
            target = @round.converted
            @game.attach_extra_stations!(target) if target && !@round.corporations_removing_tokens
          end

          def move_tokens(from, to)
            stations = @game.extra_stations(from)
            kept, replaced = stations.partition { |company, _token| extra_station_choices[company] == 'keep' }
            kept.each { |_company, token| from.tokens.delete(token) }
            replaced.each { |company, _token| @game.forget_extra_station!(company) }

            super

            kept.each do |company, token|
              station = Engine::Token.new(to)
              token.swap!(station, check_tokenable: false)
              @game.record_extra_station!(company, station)
            end
          end
        end
      end
    end
  end
end
