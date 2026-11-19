# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'takeover_offer'

module Engine
  module Game
    module G1833NE
      module Step
        class TakeoverConsent < Engine::Step::Base
          include TakeoverOffer

          ACTIONS = %w[choose].freeze
          ACCEPT = 'accept'
          REFUSE = 'refuse'

          def actions(entity)
            return [] unless entity == current_entity

            ACTIONS
          end

          def active?
            awaiting_consent?
          end

          def active_entities
            [consenter]
          end

          def description
            "Respond to takeover of #{takeover[:target].name}"
          end

          def choice_name
            "#{takeover[:acquirer].name} offers to take over #{takeover[:target].name}, redeeming each share at "\
              "#{@game.format_currency(takeover[:target].share_price.price)} in cash or #{takeover[:acquirer].name} shares"
          end

          def choices
            { ACCEPT => 'Accept', REFUSE => 'Refuse' }
          end

          def process_choose(action)
            case action.choice
            when ACCEPT
              @log << "#{action.entity.name} accepts the takeover of #{takeover[:target].name}"
              takeover[:consented] = true
              advance_takeover!
            when REFUSE
              @log << "#{action.entity.name} refuses the takeover of #{takeover[:target].name}"
              @round.takeover = nil
            else
              raise GameError, "Invalid choice #{action.choice}"
            end
          end
        end
      end
    end
  end
end
