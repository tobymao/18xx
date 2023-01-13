# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1880
      module Step
        class CheckFIConnection < Engine::Step::Base
          ACTIONS = %w[destination_connection pass].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] unless entity.minor?
            return ['choose'] if @merging

            ACTIONS
          end

          def description
            'Foreign investor merge'
          end

          def blocks?
            true
          end

          def auto_actions(entity)
            return [] if @merging || !current_entity.minor?
            return [Engine::Action::Pass.new(entity)] unless @game.check_for_foreign_investor_connection(entity)

            [Engine::Action::DestinationConnection.new(entity)]
          end

          def process_destination_connection(action)
            corporation = action.entity.shares.first.corporation
            @merging = { corporation: corporation, fi: action.entity, state: nil }
            @game.log << "#{action.entity.full_name} and #{corporation.name} are connected"
            process_merger

            @merging[:state] = :choose_percent
            return if action.entity.cash.positive?

            process_percent(Action::Choose.new(action.entity, choice: nil))
          end

          def skip!
            pass!
          end

          def process_merger
            fi = @merging[:fi]
            share = @merging[:corporation].shares.first
            @game.share_pool.transfer_shares(share.to_bundle, fi.owner)
            @game.bank.spend(50, fi.owner)
            @game.log << "#{fi.owner.name} receives #{@game.format_currency(50)} and a share of #{share.corporation.name}"
          end

          def process_choose(action)
            case @merging[:state]
            when :choose_percent
              process_percent(action)
            when :choose_token
              process_token(action)
            end
          end

          def setup
            @merging
          end

          def process_percent(action)
            fi = @merging[:fi]
            if fi.cash.positive?
              amount = action.choice.include?('treasury') ? fi.cash : fi.cash * 0.2
              destination = action.choice.include?('treasury') ? @merging[:corporation] : current_entity.owner
              fi.spend(amount, destination, check_positive: false)
              log_msg = "#{fi.full_name} transfers #{@game.format_currency(amount)} to #{destination.name}"
            end
            log_msg ||= "#{fi.full_name} has 0 in treasury, no money is transferred"
            @game.log << log_msg
            @merging[:state] = :choose_token
            return if cheapest_unused_token(@merging[:corporation])

            process_token(Action::Choose.new(fi, choice: 'Discard'))
          end

          def process_token(action)
            fi = @merging[:fi]
            replace_token(fi, fi.tokens.first, cheapest_unused_token(@merging[:corporation])) if action.choice == 'Replace'
            discard_token(fi) if action.choice == 'Discard'
            @game.log << "#{fi.full_name} closes"
            fi.close!

            pass!
          end

          def discard_token(fi)
            fi.tokens.first.city.remove_tokens!
            @game.log << "#{fi.name} token is discarded"
          end

          def cheapest_unused_token(corp)
            corp.tokens.reject(&:used).min_by(&:price)
          end

          def replace_token(fi, fi_token, corp_token)
            city = fi_token.city
            @game.log << "#{fi.name}'s token in #{city.hex.name} is replaced with a #{corp_token.corporation.name} token"
            fi_token.swap!(corp_token, check_tokenable: false)
          end

          def choice_name
            case @merging[:state]
            when :choose_percent
              "Choose destination for Foreign Investor cash\n"
            when :choose_token
              "Replace Token of Foreign Investor with Corporation token?\n"
            end
          end

          def choices
            case @merging[:state]
            when :choose_percent
              ["#{@game.format_currency(@merging[:fi].cash)} to #{@merging[:corporation].name} treasury",
               "#{@game.format_currency(@merging[:fi].cash * 0.2)} to #{current_entity.owner.name}"]
            when :choose_token
              %w[Replace Discard]
            end
          end
        end
      end
    end
  end
end
