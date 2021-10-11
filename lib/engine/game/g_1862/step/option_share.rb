# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1862
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
            share = pending_option[:share]
            if action.choice.to_s == 'sell'
              @game.bank.spend(pending_option[:sell_price], entity)
              @game.transfer_share(share, @game.share_pool)
              @log << "#{entity.name} sells #{pending_option[:share].corporation.name} #{pending_option[:percent]}% "\
                      "option share for #{@game.format_currency(pending_option[:sell_price])}"
            else
              entity.spend(pending_option[:redeem_price], @game.bank)
              @log << "#{entity.name} redeems #{pending_option[:share].corporation.name} #{pending_option[:percent]}% "\
                      "option share for #{@game.format_currency(pending_option[:redeem_price])}"
            end

            @round.pending_options.shift
            @game.continue_merge_option(entity)
          end

          def choice_name
            if pending_option[:entity].corporation?
              'Sell or Buy option (partial) share on behalf of surviving company'
            elsif pending_option[:percent] > 10
              'Sell or Buy option (partial) share - may allow retaining presidency'
            else
              'Sell or Buy option (partial) share'
            end
          end

          def choices
            percent_str = pending_option[:percent] > 10 ? '' : "#{pending_option[:percent]}% "
            share_str = pending_option[:percent] > 10 ? "(Director's certificate) " : ''
            {
              sell: "Sell #{pending_option[:share].corporation.name} #{percent_str}option share #{share_str}"\
                    "for #{@game.format_currency(pending_option[:sell_price])}",
              redeem: "Redeem (buy) #{pending_option[:share].corporation.name} #{percent_str}option share #{share_str}"\
                      "for #{@game.format_currency(pending_option[:redeem_price])}",
            }
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
