# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1841
      module Step
        class ChooseOption < Engine::Step::Base
          def actions(entity)
            return [] unless entity == pending_entity

            ['choose']
          end

          def round_state
            {
              pending_options: [],
            }
          end

          def setup
            @round.pending_options = []
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

          def pending_type
            pending_option[:type]
          end

          def pending_corp
            pending_option[:corp]
          end

          def pending_choices
            pending_option[:choices]
          end

          def pending_share_owner
            pending_option[:share_owner]
          end

          def pending_option
            @round.pending_options&.first || {}
          end

          def description
            return 'Choose share price' if pending_type == :price
            return 'Optional share buy' if pending_type == :share_offer
            return 'Choose president share to exchange IRSFF president share for' if pending_type == :pick_exchange_pres
            return 'Choose share to exchange IRSFF share for' if pending_type == :pick_exchange_corp
            return 'Continue with share purchase round' if pending_type == :offer_again

            'Choose share upgrade'
          end

          def choice_name
            return 'Choose share price' if pending_type == :price
            return "Optional share purchase by #{pending_entity.name}" if pending_type == :share_offer
            return "Choose president share for #{pending_share_owner.name}" if pending_type == :pick_exchange_pres
            return "Choose share for #{pending_share_owner.name}" if pending_type == :pick_exchange_corp
            return "Perform another share purchase round for #{pending_corp.name}?" if pending_type == :offer_again

            'Decision for exchange of stocks'
          end

          def choices
            case pending_type
            when :price
              {
                first: @game.format_currency(pending_option[:share_prices].first.price).to_s,
                last: @game.format_currency(pending_option[:share_prices].last.price).to_s,
              }
            when :upgrade
              opts = {}
              target = pending_option[:target]
              percent = pending_option[:percent]
              if pending_choices.include?(:pres)
                opts[:pres] = "Upgrade to the president's share of #{target.name}. "\
                              "Cost: #{@game.format_currency(@game.pres_upgrade_cost(percent, target))}"
              end
              if pending_choices.include?(:full)
                opts[:full] = "Upgrade to a full share of #{target.name}. "\
                              "Cost: #{@game.format_currency(@game.full_upgrade_cost(target))}"
              end
              if pending_choices.include?(:cash)
                opts[:cash] = "No exchange for #{target.name} "\
                              "and receive: #{@game.format_currency(@game.full_upgrade_cost(target))}"
              end
              if pending_choices.include?(:no)
                opts[:no] = "Don't upgrade to the president's share of #{target.name}, "\
                            'just receive a normal share'
              end
              opts
            when :share_offer
              target = pending_option[:target]
              price = @game.format_currency(target.share_price.price)
              {
                no: 'Pass',
                yes: "Buy one share of #{target.name} for #{price}",
              }
            when :pick_exchange_pres, :pick_exchange_corp
              corpa = pending_option[:corpa]
              corpb = pending_option[:corpb]
              {
                a: corpa.name.to_s,
                b: corpb.name.to_s,
              }
            when :offer_again
              {
                y: 'Yes',
                n: 'No',
              }
            end
          end

          def process_choose(action)
            case pending_type
            when :price
              sp = action.chioce == :first ? pending_option[:share_prices].first : pending_option[:share_prices].last
              @round.pending_options.shift
              @game.merger_exchange_start(sp)
            when :upgrade
              @round.pending_options.shift
              @game.merger_do_exchange(action.choice)
            when :share_offer
              @round.pending_options.shift
              @game.share_offer_option(action.choice)
            when :pick_exchange_pres
              @round.pending_options.shift
              @game.secession_corp(action.choice)
            when :pick_exchange_corp
              @round.pending_options.shift
              @game.secession_do_exchange(action.choice)
            when :offer_again
              @round.pending_options.shift
              @game.secession_offer_response(action.choice)
            end
          end
        end
      end
    end
  end
end
