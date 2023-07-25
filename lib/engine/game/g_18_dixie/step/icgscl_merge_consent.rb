# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18Dixie
      module Step
        class MergeConsent < Engine::Step::Base
          def round_state
            {
              merge_consent_merging_corp: nil,
              merge_consent_primary_corp: nil,
              merge_consent_secondary_corp: nil,
              merge_consent_pending_corps: [],
              merge_consent_subsidy: nil,
              merge_presidency_cash_crisis_corp: nil,
              merge_presidency_cash_crisis_player: nil,
              merge_presidency_exchange_corps: [],
              merge_presidency_exchange_merging_corp: nil,
              merge_presidency_exchange_subsidy: nil,
            }
          end

          def merger_corp_name
            @round.merge_consent_merging_corp&.name || 'SCL/ICG'
          end

          def active_corp_name
            @round.merge_consent_pending_corps[0]&.name || 'current corporation'
          end

          def primary_corp_name
            @round.merge_consent_primary_corp&.name || 'first forming corporation'
          end

          def secondary_corp_name
            @round.merge_consent_secondary_corp&.name || 'second forming corporation'
          end

          def secondary_corp_president
            @round.merge_consent_pending_corps[1]&.owner&.name || 'other merging corporation\'s president'
          end

          def merge_description
            "merge #{primary_corp_name} and #{secondary_corp_name} to form the #{merger_corp_name}"
          end

          def active_entities
            @round.merge_consent_pending_corps
          end

          def active?
            !@round.merge_consent_pending_corps.empty?
          end

          def actions(entity)
            return %w[choose] if turn_to_choose(entity)

            []
          end

          def show_other
            [@round.merge_consent_primary_corp,
             @round.merge_consent_secondary_corp,
             @round.merge_consent_merging_corp] - [current_entity]
          end

          def turn_to_choose(entity)
            return false unless entity.corporation?
            return false unless @round.merge_consent_merging_corp
            return false if @round.merge_consent_pending_corps.empty?
            return false unless entity == @round.merge_consent_pending_corps[0]

            true
          end

          def help
            return "Choosing to merge WILL form the #{merger_corp_name}" if @round.merge_consent_pending_corps.size < 2

            "The formation of the #{merger_corp_name} is also conditional on the consent of #{secondary_corp_president}"
          end

          def description
            "#{merger_corp_name} formation: #{active_corp_name} president's consent"
          end

          def choices
            @choices = {}
            @choices['merge'] = "Consent to #{merge_description}"
            @choices['decline'] = "Decline to #{merge_description}"
            @choices
          end

          def choice_name
            "Choose whether or not to #{merge_description}"
          end

          def pass_description
            "Decline to merge. #{@merger_corp_name} will not form"
          end

          def process_choose(action)
            return choose_to_merge(action) if action.choice == 'merge'

            decline_to_merge(action)
          end

          def process_pass(_action)
            raise Engine::GameError, "It shouldn't be possible to pass on consenting to merge into the ICG/SCL"
          end

          def choose_to_merge(action)
            @game.log << "#{action&.entity&.name} consents to merge into #{merger_corp_name}"
            @round.merge_consent_pending_corps.shift
            return unless @round.merge_consent_pending_corps.empty?

            @game.start_merge(
              @round.merge_consent_primary_corp,
              @round.merge_consent_secondary_corp,
              @round.merge_consent_merging_corp,
              @round.merge_consent_subsidy
            )
            reset_merge_consent
          end

          def decline_to_merge(action)
            @game.log << "#{action&.entity&.owner&.name} declines to merge into #{merger_corp_name}"
            @game.close_merger_corp(@round.merge_consent_merging_corp)
            reset_merge_consent
          end

          def reset_merge_consent
            @round.merge_consent_merging_corp = nil
            @round.merge_consent_pending_corps = []
            @round.merge_consent_primary_corp = nil
            @round.merge_consent_secondary_corp = nil
            @round.merge_consent_subsidy = nil
          end
        end
      end
    end
  end
end
