# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1880
      module Step
        class Choose < Engine::Step::Base
          ACTIONS = %w[choose pass].freeze

          def actions(_entity)
            ACTIONS
          end

          def auto_actions(entity)
            return [Engine::Action::Choose.new(entity, choice: '')] if @game.phase.name == 'B2' && award_company

            []
          end

          def active_entities
            [award_company]
          end

          def active?
            award_company
          end

          def choice_name
            "Receive #{@game.p0.name} payment?"
          end

          def choices
            ["Receive #{@game.p0.name} payment of #{@game.format_currency(sell_price)}"]
          end

          def round_state
            super.merge(
            { passed_on_p0: false }
          )
          end

          def description
            "#{@game.p0.name} payment"
          end

          def process_choose(action)
            action.entity.owner.companies.delete(@game.p0)
            @game.bank.spend(sell_price, @game.p0.owner) if sell_price.positive?
            @game.p0.close!
            @log << "#{action.entity.name} receives #{@game.format_currency(sell_price)} one-time payment from #{@game.p0.name}"
            pass!
          end

          def hide_corporations?
            true
          end

          def choice_available?(_entity)
            true
          end

          def skip!
            pass!
          end

          def can_receive_payment?
            @game.class::P0_AWARD.key?(@game.phase.name) && !@game.p0.closed?
          end

          def award_company
            return nil if @game.p0.closed? || @round.passed_on_p0 || !can_receive_payment?

            @game.p0
          end

          def sell_price
            @game.class::P0_AWARD[@game.phase.name]
          end

          def process_pass(action)
            super
            @round.passed_on_p0 = true
          end
        end
      end
    end
  end
end
