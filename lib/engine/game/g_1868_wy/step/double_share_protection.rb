# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/share_buying'

module Engine
  module Game
    module G1868WY
      module Step
        class DoubleShareProtection < Engine::Step::Base
          ACTIONS = %w[choose].freeze

          def description
            'Ames Brothers 20% Share Protection'
          end

          def protect
            @game.up_double_share_protection
          end

          def help
            old = protect[:prev_president]
            new = protect[:player]
            cost = protect[:buy_at_price].price * protect[:num_buyable]

            exchange_text =
              case protect[:num_buyable]
              when 0
                'swap two 10% shares for it. '
              when 1
                "buy one 10% share from the bank for #{@game.format_currency(cost)} and then swap two 10% shares for it. "
              when 2
                "buy two 10% shares from the bank for #{@game.format_currency(cost)} and then swap two 10% shares for it. "
              end

            price_text =
              if @game.union_pacific.share_price.price == protect[:new_price].price
                ''
              else
                cash_text =
                  if protect[:cash]
                    ", and #{old.name} will receive #{@game.format_currency(protect[:cash])} from the bank"
                  else
                    ''
                  end
                'If two 10% shares are swapped, the UP share price will increase to '\
                  "#{@game.format_currency(protect[:new_price].price)}#{cash_text}. "
              end

            finish = "Then, the Stock Round will resume from #{old.name}'s turn."

            "The UP president's certificate is temporarily in the bank pool. #{new.name} "\
              "may either swap the Ames Brothers 20% share for it, or #{exchange_text}#{price_text}#{finish}"
          end

          def actions(entity)
            entity == protect[:player] ? ACTIONS : []
          end

          def log_skip; end

          def log_pass(entity)
            @log << "#{entity.name} declines to protect the Ames Brothers 20% UP share"
          end

          def pass_description
            "Pass (Don't Protect 20% Share)"
          end

          def active?
            !protect.empty?
          end

          def choice_available?(entity)
            entity == protect[:player]
          end

          def choices
            cost = protect[:buy_at_price].price * protect[:num_buyable]

            protect_text =
              case protect[:num_buyable]
              when 0
                'Two 10% certs'
              when 1
                "Two 10% certs (buying one for #{@game.format_currency(cost)})"
              when 2
                "Two 10% certs (buying two for #{@game.format_currency(cost)})"
              end

            { 0 => 'Ames Brothers 20% cert', 1 => protect_text }
          end

          def choice_name
            'Swap for Presidency'
          end

          def active_entities
            [protect[:player]]
          end

          def blocking?
            !protect.empty?
          end

          def post_process
            @game.up_double_share_protection = {}
          end

          def process_pass(action)
            log_pass(action.entity)
            pass!
            post_process
          end

          def process_choose(action)
            player = action.entity

            if action.choice.zero?
              @game.swap_up_double_share_and_presidency!
              @log << "#{player.name} swaps the Ames Brothers 20% share for the UP president's certificate"
            else
              old_price = @game.union_pacific.share_price.price

              swap = @game.up_protection_player_bundle

              @game.share_pool.move_share(@game.up_presidency, player)
              swap&.shares&.each { |s| @game.share_pool.move_share(s, @game.share_pool) }
              @game.union_pacific.owner = player

              cost = protect[:buy_at_price].price * protect[:num_buyable]
              player.spend(cost, @game.bank) if cost.positive?

              @log <<
                case protect[:num_buyable]
                when 0
                  "#{player.name} exchanges two 10% UP shares for the UP president's certificate"
                when 1
                  "#{player.name} pays #{@game.format_currency(cost)} for one 10% UP share from the bank "\
                  "pool, then exchanges two 10% shares for the the UP president's certificate"
                when 2
                  "#{player.name} pays #{@game.format_currency(cost)} for two 10% UP shares from the bank pool, "\
                  "then exchanges those two 10% shares for the the UP president's certificate"
                else
                  ''
                end

              @game.stock_market.move(@game.union_pacific, protect[:new_price].coordinates)
              @game.log_share_price(@game.union_pacific, old_price)

              if protect[:cash]
                @game.bank.spend(protect[:cash], protect[:prev_president])
                @log << "#{protect[:prev_president].name} receives #{@game.format_currency(protect[:cash])} from the bank"
              end
            end

            post_process
          end

          def ipo_type(_entity)
            :par
          end
        end
      end
    end
  end
end
