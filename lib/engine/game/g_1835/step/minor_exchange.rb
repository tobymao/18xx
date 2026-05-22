module Engine
  module Game
    module G1835
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

          def blocking?
            @game.pr_can_form || @game.corporation_by_id('PR').floated?
          end

          def active_entities
            return [@game.minor_by_id('2')] if @game.pr_can_form
            return @game.minors - @round.declined_minors  if @game.corporation_by_id('PR').floated?

            []
          end

          def active?
            #LOGGER.debug("ChoiceFloatPreussen::active?")
            active_entities.any?
          end

          def description
            'Preußen'
          end

          def can_exchange?(entity)
            return false if entity.closed?
            return true if forming_choice_minors.include?(entity)

            target = exchange_target(entity)
            return false unless target

            exchange_target(entity).floated?
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
            @forming_choice_minors ||= %w[2].map { |id| @game.minor_by_id(id) }
          end

          def choice_available?(entity)
            return true
            can_exchange?(entity)
          end

          def ipo_type(_entity)
            nil
          end

          def process_choose(action)

            @game.pr_can_form = false

            entity = action.entity
            target = exchange_target(entity)
            choice = action.choice
            if CHOICES[:form] == choice
              @log << "#{entity.id} opts to form #{target.id}"
              @game.form_national_railway!(target)
            elsif CHOICES[:fold_in] == choice
              @log << "#{entity.id} opts to fold into #{target.id}"
              @game.merge_minor!(entity, target)
            else
              @round.declined_minors << entity
              @log << if forming_choice_minors.include?(current_entity)
                        "#{entity.id} declines to form #{target.id}"
                      else
                        "#{entity.id} declines to fold into #{target.id}"
                      end
            end

            #pass!
          end

          def log_skip(entity)
            @log << "#{entity.id} has no action"
          end

          def round_state
            {
              declined_minors: [],
            }
          end
        end
      end
    end
  end
end
