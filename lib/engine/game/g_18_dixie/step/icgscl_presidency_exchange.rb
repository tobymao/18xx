# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18Dixie
      module Step
        class PresidencyExchange < Engine::Step::Base
          def round_state
            {
              presidency_exchange_merging_corp: nil,
              presidency_exchange_primary_corp: nil,
              presidency_exchange_secondary_corp: nil,
              presidency_exchange_pending_corps: [],
              presidency_exchange_shares_remaining: nil,
              presidency_exchange_subsidy: nil,
            }
          end

          def merger_corp_name
            @round.presidency_exchange_merging_corp&.name || 'SCL/ICG'
          end

          def active_corp_name
            @round.presidency_exchange_pending_corps[0]&.name || 'current corporation'
          end

          def primary_corp_name
            @round.presidency_exchange_primary_corp&.name || 'first forming corporation'
          end

          def secondary_corp_name
            @round.presidency_exchange_secondary_corp&.name || 'second forming corporation'
          end

          def secondary_corp_president
            @round.presidency_exchange_pending_corps[1]&.owner&.name || 'other merging corporation\'s president'
          end

          def shares_remaining
            shares_remaining = @round.presidency_exchange_shares_remaining
            raise Engine::GameError << "presidency_exchange_shares_remaining should be set" unless shares_remaining

            shares_remaining
          end

          def merge_description
            raise Engine::GameError << "DO NOT USE"
          end

          def active_entities
            @round.presidency_exchange_pending_corps.map { |c| c.owner }
          end

          def active?
            !@round.presidency_exchange_pending_corps.empty?
          end

          def actions(entity)
            return %w[choose] if turn_to_choose(entity)

            []
          end

          def show_other
            [@round.presidency_exchange_primary_corp,
             @round.presidency_exchange_secondary_corp,
             @round.presidency_exchange_merging_corp].freeze - [current_entity]
          end

          def turn_to_choose(entity)
            return false unless entity.corporation
            return false unless @round.presidency_exchange_merging_corp
            return false if @round.presidency_exchange_pending_corps.empty?
            return false unless entity == @round.presidency_exchange_pending_corps[0]

            true
          end

          def help
            return "Choosing to merge WILL form the #{merger_corp_name}" if @round.presidency_exchange_pending_corps.length < 2

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
            @round.presidency_exchange_pending_corps.shift
            return unless @round.presidency_exchange_pending_corps.empty?

            @game.start_merge(
              @round.presidency_exchange_primary_corp,
              @round.presidency_exchange_secondary_corp,
              @round.presidency_exchange_merging_corp,
              @round.presidency_exchange_subsidy
            )
            reset_presidency_exchange
          end

          def decline_to_merge(action)
            @game.log << "#{action&.entity&.owner&.name} declines to merge into #{merger_corp_name}"
            @game.close_merger_corp(@round.presidency_exchange_merging_corp)
            reset_presidency_exchange
          end

          def reset_presidency_exchange
            @round.presidency_exchange_merging_corp = nil
            @round.presidency_exchange_pending_corps = []
            @round.presidency_exchange_primary_corp = nil
            @round.presidency_exchange_secondary_corp = nil
            @round.presidency_exchange_subsidy = nil
          end
        end
      end
    end
  end
end
