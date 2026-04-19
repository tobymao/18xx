# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1835
      module Step
        class Draft < Engine::Step::Base
          attr_reader :companies, :choices, :grouped_companies

          ACTIONS = %w[bid pass].freeze

          def setup
            @companies = @game.companies.select { |c| c.owner.nil? && !c.closed? }

            # set up the tiered companies as 2d array that might contain empty arrays if the starting package was not
            # fully sold in a previous draft round. These empty arrays are important for may_purchase: companies in rows
            # after an empty row can only be purchased if all rows before are empty. If we were to only group_by
            # auction_row, we might loose these empty rows.
            @tiered_companies = Array.new(4) { [] }
            @companies.each do |company|
              @tiered_companies[company.auction_row] << company
            end
          end

          def available
            @tiered_companies.flatten
          end

          def tiered_auction_companies
            @tiered_companies
          end

          def may_purchase?(company)
            # in the vanilla draft a company can only be purchased if it is either in the top-most row or furthest to
            # the left in the second top-most row if the top-most row only has one company
            false unless company
            company_row = company.auction_row
            return true if company_row.zero?
            return true if @tiered_companies[0...company_row].all?(&:empty?)
            return false unless @tiered_companies[0...(company_row - 1)].all?(&:empty?)
            return false unless @tiered_companies[company_row - 1].size == 1

            @tiered_companies[company_row][0].sym == _company.sym
          end

          def may_choose?(_company)
            false
          end

          def auctioning; end

          def bids
            {}
          end

          def visible?
            true
          end

          def players_visible?
            true
          end

          def name
            'Draft'
          end

          def description
            'Draft Private Companies'
          end

          def finished?
            @game.draft_finished = @companies.empty?
            @companies.empty? || entities.all?(&:passed?)
          end

          def actions(entity)
            return [] if finished?

            unless @companies.any? { |c| current_entity.cash >= min_bid(c) }
              @log << "#{current_entity.name} has no valid actions and passes"
              return []
            end

            entity == current_entity ? ACTIONS : []
          end

          def skip!
            current_entity.pass!
            @round.next_entity_index!
            action_finalized
          end

          def log_skip(entity)
            @log << "#{entity.name} cannot afford any company and passes"
          end

          def process_bid(action)
            company = action.company
            player = action.entity
            price = action.price

            company.owner = player
            player.companies << company
            player.spend(price, @game.bank)
            @tiered_companies.each do |row|
              next unless row.index(company)

              row.delete(company)
            end
            @companies.delete(company)

            @log << "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"

            @game.abilities(company, :shares) do |ability|
              ability.shares.each do |share|
                # In case someone else already holds 30% of BY SharePool#transfer_shares needs a previous president for
                # swapping the shares, thus we assign the buyer of the president share even if they immediately lose
                # the presidency. Which is technically correct: The buyer becomes the first president and then players
                # check whether there is someone else with more shares
                if share.president && share.corporation.name == 'BY'
                  share.corporation.owner = player
                  @log << "#{player.name} becomes the president of #{share.corporation.name}"
                end
                @game.bank.spend(share.price, share.corporation)

                # allow president change for SX when LD is being sold, but for BY only if the BY director has been sold,
                # which might be during the current or any earlier action
                allow_president_change = @companies.find { |c| c.sym == 'BY_D' }.nil? || share.corporation.id == 'SX'
                @game.share_pool.transfer_shares(ShareBundle.new(share), player, allow_president_change: allow_president_change)

                @game.place_home_token(share.corporation) if share.corporation.floated?
              end
            end

            company.close! if company.sym == 'BY_D'

            corporation = @game.corporation_by_id(company.id)

            if corporation && corporation.type == :minor
              share = corporation.shares.first
              @game.share_pool.transfer_shares(ShareBundle.new(share), player)
              @game.bank.spend(price, corporation)
              company.close!
              @game.place_home_token(corporation)
            end

            entities.each(&:unpass!)
            @round.last_to_act = player
            @round.next_entity_index!
            action_finalized
          end

          def process_pass(action)
            @log << "#{action.entity.name} passes"
            action.entity.pass!
            @round.next_entity_index!
            action_finalized
          end

          def action_finalized
            return unless finished?

            @round.next_entity_index!
          end

          def committed_cash(_player, _show_hidden = false)
            0
          end

          def min_increment
            0
          end

          def may_bid?
            false
          end

          def min_bid(company)
            return unless company

            company.value
          end

          def max_bid(player, _object)
            player.cash
          end

          def max_place_bid(player, object)
            max_bid(player, object)
          end

          def ipo_type(_entity)
            nil
          end
        end
      end
    end
  end
end
