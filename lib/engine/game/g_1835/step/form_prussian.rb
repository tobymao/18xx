# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1835
      module Step
        class FormPrussian < Engine::Step::Base
          ACTIONS = %w[choose pass].freeze

          # round_state is initialized once when the round is created and persists
          # for the entire round. DO NOT reset pr_formation_processed in setup —
          # setup is called at the start of each entity's turn, which would re-offer
          # the formation option every turn (and unpass! resets @passed between turns).
          def round_state
            { pr_formation_processed: false }
          end

          def setup
            # Intentionally empty: formation state lives in round_state and must not
            # be reset each time a new company/player starts their turn.
          end

          def actions(entity)
            return [] if @round.pr_formation_processed
            return [] if @game.pr_formed
            return [] unless @game.pr_formation_allowed?
            return [] unless can_form_pr?(entity)

            # If mandatory, only allow 'choose' (no pass)
            @game.pr_formation_mandatory ? %w[choose] : ACTIONS
          end

          def active?
            return false if @round.pr_formation_processed
            return false if @game.pr_formed

            @game.pr_formation_allowed? && !@game.m2_minor&.closed?
          end

          def blocking?
            active?
          end

          def description
            'Form Prussian Railroad'
          end

          def pass_description
            'Decline to form PR'
          end

          def current_entity
            m2 = @game.m2_minor
            m2&.owner
          end

          def active_entities
            m2 = @game.m2_minor
            return [] unless m2&.owner&.player?

            [m2.owner]
          end

          def can_form_pr?(entity)
            m2 = @game.m2_minor
            return false unless m2
            return false if m2.closed?

            m2.owner == entity
          end

          def choice_available?(entity)
            can_form_pr?(entity)
          end

          # Stock round view calls ipo_type unconditionally on the active step.
          # Return nil so render_pre_ipo renders nothing for this step.
          def ipo_type(_entity) end

          def choice_name
            'Form the Prussian Railroad?'
          end

          def choices
            { 'form' => 'Form the Prussian Railroad' }
          end

          def process_choose(action)
            raise GameError, 'Cannot form PR' unless can_form_pr?(action.entity)
            raise GameError, 'Invalid choice' unless action.choice == 'form'

            @game.form_prussian_railroad!
            @round.pr_formation_processed = true
            pass!
          end

          def process_pass(action)
            raise GameError, 'PR formation is mandatory' if @game.pr_formation_mandatory

            @log << "#{action.entity.name} declines to form the Prussian Railroad"
            @round.pr_formation_processed = true
            pass!
          end
        end
      end
    end
  end
end
