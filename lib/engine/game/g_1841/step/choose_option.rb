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

          def pending_title
            pending_option[:title] || ''
          end

          def pending_target
            pending_option[:target]
          end

          def pending_percent
            pending_option[:percent]
          end

          def pending_old_shares
            pending_option[:old_shares]
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
            case pending_type
            when :price
              pending_title + 'Choose share price for new corporation'
            when :share_offer
              pending_title + "Optional purchase of a share of #{pending_target.name} by #{pending_entity.name}"
            when :pick_exchange_pres
              pending_title + "Choose corporation to exchange IRSFF president share for #{pending_share_owner.name}"
            when :pick_exchange_corp
              pending_title + "Choose share that #{pending_share_owner.name} will exchange an IRSFF share for"
            when :offer_again
              pending_title + "Perform another share purchase round for #{pending_corp.name}?"
            when :upgrade
              if pending_percent == 10
                pending_title + "Decision for outgoing 10% share of #{pending_old_shares[0].corporation.name}"\
                                " owned by #{pending_entity.name}"
              elsif pending_percent == 20 && pending_old_shares[0].president
                pending_title + "Decision for outgoing president share of #{pending_old_shares[0].corporation.name}"\
                                " owned by #{pending_entity.name}"
              elsif pending_percent == 20 && pending_old_shares[0].corporation == pending_old_shares[1].corporation
                pending_title + "Decision for outgoing two 10% shares of #{pending_old_shares[0].corporation.name}"\
                                " owned by #{pending_entity.name}"
              elsif pending_percent == 20
                pending_title + "Decision for outgoing 10% share of #{pending_old_shares[0].corporation.name} and"\
                                " 10% share of #{pending_old_shares[1].corporation.name} both owned by #{pending_entity.name}"
              else
                # must be 30%
                pending_title + "Decision for outgoing president share of #{pending_old_shares[0].corporation.name} and"\
                                " 10% share of #{pending_old_shares[1].corporation.name} both owned by #{pending_entity.name}"
              end
            else
              pending_title
            end
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
              if pending_choices.include?(:pres)
                opts[:pres] = "Upgrade to the president's share of #{pending_target.name}. "\
                              "Cost: #{@game.format_currency(@game.pres_upgrade_cost(pending_percent, pending_target))}"
              end
              if pending_choices.include?(:full)
                opts[:full] = "Upgrade to a full share of #{pending_target.name}. "\
                              "Cost: #{@game.format_currency(@game.full_upgrade_cost(pending_target))}"
              end
              if pending_choices.include?(:cash)
                opts[:cash] = "No exchange for #{pending_target.name} "\
                              "and receive: #{@game.format_currency(@game.full_upgrade_cost(pending_target))}"
              end
              if pending_choices.include?(:no)
                opts[:no] = "Don't upgrade to the president's share of #{pending_target.name}, "\
                            'just receive a normal share'
              end
              opts
            when :share_offer
              price = @game.format_currency(pending_target.share_price.price)
              {
                no: 'Pass',
                yes: "Buy one share of #{pending_target.name} for #{price}",
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
            choice = action.choice.to_sym
            case pending_type
            when :price
              sp = choice == :first ? pending_option[:share_prices].first : pending_option[:share_prices].last
              @round.pending_options.shift
              @game.merger_exchange_start(sp)
            when :upgrade
              @round.pending_options.shift
              @game.merger_do_exchange(choice)
            when :share_offer
              @round.pending_options.shift
              @game.share_offer_option(choice)
            when :pick_exchange_pres
              @round.pending_options.shift
              @game.secession_corp(choice)
            when :pick_exchange_corp
              @round.pending_options.shift
              @game.secession_do_exchange(choice)
            when :offer_again
              @round.pending_options.shift
              @game.secession_offer_response(choice)
            end
          end
        end
      end
    end
  end
end
