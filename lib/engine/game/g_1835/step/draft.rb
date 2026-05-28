# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1835
      module Step
        class Draft < Engine::Step::SimpleDraft
          attr_reader :companies, :choices, :grouped_companies

          ACTIONS = %w[bid pass].freeze

          def setup
            @companies = @game.companies.select { |c| c.owner.nil? && !c.closed? }

            # set up the tiered companies as 2d array that might contain empty arrays if the starting package was not
            # fully sold in a previous draft round. These empty arrays are important for may_purchase: companies in rows
            # after an empty row can only be purchased if all rows before are empty. If we were to only group_by
            # auction_row, we might lose these empty rows.
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
            return false unless company

            # in the vanilla draft a company can only be purchased if it is either in the top-most row or furthest to
            # the left in the second top-most row if the top-most row only has one company
            company_row = company.auction_row
            first_row = @tiered_companies.index { |row| !row.empty? }
            return true if company_row == first_row

            return false unless @tiered_companies[first_row].one?
            return false unless company_row == first_row + 1

            @tiered_companies[company_row].first == company
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
            @round.finished?
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

          def process_bid(action)
            company = action.company
            player = action.entity
            price = action.price

            assign_company(company, player)
            player.spend(price, @game.bank)
            remove_company(company)

            @log << "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"

            @game.abilities(company, :shares) do |ability|
              ability.shares.each do |share|
                transfer_share(company, player, share)
              end
            end

            minor = @game.minor_by_id(company.id)
            float_minor(company, minor, player, price) if minor

            entities.each(&:unpass!)
            @round.last_to_act = player
            @round.next_entity_index!
            action_finalized
          end

          def assign_company(company, player)
            company.owner = player
            player.companies << company
          end

          def remove_company(company)
            @tiered_companies.each do |row|
              next unless row.include?(company)

              row.delete(company)
            end
            @companies.delete(company)
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

          def may_choose?(_company)
            false
          end

          def min_increment
            0
          end

          def may_bid?
            false
          end

          def max_bid(player, _object)
            player.cash
          end

          private

          def transfer_share(company, player, share)
            if share.president && share.corporation.name == 'BY'
              # In case someone else already holds 30% of BY SharePool#transfer_shares needs a previous president for
              # swapping the shares, thus we assign the buyer of the president share even if they immediately lose
              # the presidency. Which is technically correct: The buyer becomes the first president and then players
              # check whether there is someone else with more shares
              share.corporation.owner = player
              @log << "#{player.name} becomes the president of #{share.corporation.name}"
              company.close!
            end

            @game.bank.spend(share.price, share.corporation)

            # allow president change for SX when LD is being sold, but for BY only if the BY director has been sold,
            # which might be during the current or any earlier action
            allow_president_change = share.president || !share.corporation.shares.first.president
            @game.share_pool.transfer_shares(ShareBundle.new(share), player, allow_president_change: allow_president_change)

            @game.place_home_token(share.corporation) if share.corporation.floated?
          end

          def float_minor(company, minor, player, price)
            minor.owner = player
            minor.float!
            @game.bank.spend(price, minor)
            company.close!
            hex = @game.hex_by_id(minor.coordinates)
            hex.tile.cities[minor.city || 0].place_token(minor, minor.next_token)
          end
        end
      end
    end
  end
end
