# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18USA
      module Step
        class ObsoleteTrain < Engine::Step::Base
          ACTIONS = %w[choose pass].freeze

          def actions(entity)
            return [] unless entity == p13.owner

            ACTIONS
          end

          def description
            "Decide whether to use #{p13.name} ability"
          end

          def choice_available?(_entity)
            true
          end

          def choice_name
            "Select train for #{p13.name} to prevent from rusting"
          end

          def choices
            # Only one type of train rusting at a time
            ["#{trains_rusting_for(p13.owner, purchased_train).first.name} Train"]
          end

          def active_entities
            [p13.owner]
          end

          def active?
            @game.pending_rusting_event
          end

          def p13
            @p13 ||= @game.company_by_id('P13')
          end

          def purchased_train
            @game.pending_rusting_event[:train]
          end

          def trains_rusting_for(corporation, purchased_train)
            corporation.trains.select { |t| @game.rust?(t, purchased_train) }
          end

          def process_choose(action)
            train = trains_rusting_for(p13.owner, purchased_train).first
            @log << "#{action.entity.name} chooses to use #{p13.name} to prevent #{train.name} " \
                    'from rusting. It will become obsolete instead.'
            train.obsolete_on = purchased_train.sym
            train.rusts_on = nil
            @log << "#{p13.name} closes"
            p13.close!
            trigger_rusting_event
          end

          def process_pass(action)
            super
            trigger_rusting_event
          end

          def log_pass(entity)
            @log << "#{entity.name} declines to use #{p13.name}"
          end

          def trigger_rusting_event
            @game.rust_trains!(purchased_train, @game.pending_rusting_event[:entity])
            @game.pending_rusting_event = nil
          end
        end
      end
    end
  end
end
