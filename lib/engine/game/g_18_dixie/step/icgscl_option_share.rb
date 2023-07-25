# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18Dixie
      module Step
        class OptionShare < Engine::Step::Base
          def actions(entity)
            return [] unless entity == pending_entity

            ['choose']
          end

          def description
            'Option share choice'
          end

          def active_entities
            [pending_entity]
          end

          def active?
            pending_entity
          end

          def pending_entity
            pending_option[:entity]
          end

          def pending_option
            @round.pending_options&.first || {}
          end

          def process_choose(action)
            entity = action.entity
            corp = pending_option[:corporation]
            primary_corp = pending_option[:primary_corp]
            secondary_corp = pending_option[:secondary_corp]
            share = corp.shares_by_corporation[corp].last
            if action.choice.to_s == 'sell'
              @game.bank.spend(pending_option[:sell_price], entity)
              @log << "#{entity.name} sells #{corp.name} 10% "\
                      "option share for #{@game.format_currency(pending_option[:sell_price])}"
            else
              entity.spend(pending_option[:buy_price], @game.bank)
              @game.transfer_share(share, entity)
              @log << "#{entity.name} redeems #{corp.name} 10% "\
                      "option share for #{@game.format_currency(pending_option[:buy_price])}"
            end

            @round.pending_options.shift
            @game.after_option_choice(primary_corp, secondary_corp, corp)
          end

          def choice_name
            'Sell or Buy option (half) share'
          end

          def can_buy_share
            return false if pending_option[:corporation].shares_by_corporation[:corporation].empty?

            pending_option[:entity].cash >= pending_option[:buy_price]
          end

          def choices
            if can_buy_share
              {
                sell: "Sell #{pending_option[:corporation].name} 10% option share "\
                      "for #{@game.format_currency(pending_option[:sell_price])}",
              }
            else
              {
                sell: "Sell #{pending_option[:corporation].name} 10% option share "\
                      "for #{@game.format_currency(pending_option[:sell_price])}",
                redeem: "Redeem (buy) #{pending_option[:corporation].name} 10% option share "\
                        "for #{@game.format_currency(pending_option[:buy_price])}",
              }
            end
          end

          def round_state
            {
              pending_options: [],
            }
          end
        end
      end
    end
  end
end
