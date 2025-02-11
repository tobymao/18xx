# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1837
      module Step
        class MinorExchange < Engine::Step::Base
          ACTIONS = %w[choose].freeze
          CHOICES = { :form => 'form', :fold_in => 'fold_in', :decline => 'decline' }.freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] unless can_exchange?(entity)

            ACTIONS
          end

          def auto_actions(_entity)
            []
          end

          def description
            'National Railways'
          end

          def can_exchange?(entity)
            return false if entity.closed? || @game.coal_minor?(entity)
            return true if forming_choice_minors.include?(entity)

            target = exchange_target(entity)
            target_forming?(target) || exchange_target(entity).floated?
          end

          def choice_name
            if forming_choice_minors.include?(current_entity)
              form_choice_label(exchange_target)
            else
              fold_in_choice_label(exchange_target)
            end
          end

          def form_choice_label(target)
            "Form #{target.id}"
          end

          def fold_in_choice_label(target)
            "Fold into #{target.id}"
          end

          def choices
            if forming_choice_minors.include?(current_entity)
              {
                CHOICES[:form] => form_choice_label(exchange_target),
                CHOICES[:decline] => CHOICES[:decline],
              }.freeze
            else
              {
                CHOICES[:fold_in] => fold_in_choice_label(exchange_target),
                CHOICES[:decline] => CHOICES[:decline],
              }.freeze
            end
          end

          def exchange_target(entity = current_entity)
            @game.exchange_target(entity)
          end

          def forming_choice_minors
            @forming_choice_minors ||= %w[KK1 UG1].map { |id| @game.corporation_by_id(id) }
          end

          def target_forming?(target)
            !@round.forming_minors[target].empty?
          end

          def process_choose(action)
            entity = action.entity
            target = exchange_target(entity)
            choice = action.choice
            if CHOICES[:form] == choice
              @log << "#{entity.id} opts to form #{target.id}"
              @round.forming_minors[target] << entity
            elsif CHOICES[:fold_in] == choice
              @log << "#{entity.id} opts to fold into #{target.id}"
              if target_forming?(target)
                @round.forming_minors[target] << entity
              else
                @game.merge_minor!(entity, target)
              end
            else
              @log << if forming_choice_minors.include?(current_entity)
                        "#{entity.id} declines to form #{target.id}"
                      else
                        "#{entity.id} declines to fold into #{target.id}"
                      end
            end

            pass!
            return if !target_forming?(target) || (@game.kk_minors.last != entity && @game.ug_minors.last != entity)

            @game.form_national_railway!(target, @round.forming_minors[target])
          end

          def log_skip(entity)
            @log << "#{entity.id} has no action" unless @game.coal_minor?(entity)
          end

          def round_state
            {
              forming_minors: Hash.new { |h, k| h[k] = [] },
            }
          end
        end
      end
    end
  end
end
