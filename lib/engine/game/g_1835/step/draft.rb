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
            @companies = setup_start_packet
            @first_circuit_count = 0
          end

          def setup_start_packet
            entity_map = (@game.companies + @game.minors + @game.corporations).to_h do |e|
              [entity_sym(e), e]
            end

            @game.class::START_PACKET.map do |sym, row, col|
              entity = entity_map[sym]
              raise GameError, "START_PACKET references unknown entity: #{sym}" unless entity

              { entity: entity, row: row, col: col, available: false }
            end
          end

          def entity_sym(entity)
            # Companies have sym, Minors and Corporations use name as their sym
            entity.respond_to?(:sym) ? entity.sym : entity.name
          end

          def available
            update_availability
            @companies.select { |item| item[:available] }.map { |item| item[:entity] }
          end

          def update_availability
            # Clemens variant: all remaining items are available at once
            if @game.option_clemens?
              remaining = @companies.reject { |item| entity_owned?(item[:entity]) }
              @companies.each { |item| item[:available] = remaining.include?(item) }
              return
            end

            # Standard rules: progressive row-based availability
            remaining = @companies.reject { |item| entity_owned?(item[:entity]) }
            remaining_rows = remaining.group_by { |item| item[:row] }
            return if remaining_rows.empty?

            # Reset availability
            @companies.each { |item| item[:available] = false }

            topmost_row = remaining_rows.keys.min
            topmost_entities = remaining_rows[topmost_row]

            # Rule 1: All entities in topmost row are available
            topmost_entities.each { |item| item[:available] = true }

            # Rule 2: If only one entity left in topmost row, make leftmost of next row available
            return if !topmost_entities.size == 1 || !remaining_rows[topmost_row + 1]

            next_row_entities = remaining_rows[topmost_row + 1].sort_by { |item| item[:col] }
            next_row_entities.first[:available] = true if next_row_entities.any?
          end

          def entity_owned?(entity)
            return true if entity.respond_to?(:closed?) && entity.closed?

            if entity.corporation?
              entity.presidents_share.owner&.player?
            else
              entity.owner&.player?
            end
          end

          def may_choose?(_entity)
            false
          end

          def may_purchase?(_entity)
            true
          end

          def show_min_bid?
            false
          end

          def all_draft_minors
            update_availability
            @companies.reject { |item| entity_owned?(item[:entity]) }
                      .select { |item| item[:entity].minor? }
          end

          def all_draft_companies
            update_availability
            @companies.reject { |item| entity_owned?(item[:entity]) }
                      .select { |item| item[:entity].company? }
          end

          # Returns all start packet items grouped by row (sorted by col within each row),
          # with an :owned key added so the view can grey out purchased items.
          def draft_grid
            update_availability
            @companies
              .group_by { |item| item[:row] }
              .sort_by { |row, _| row }
              .map do |_, items|
              items.sort_by { |item| item[:col] }
                                     .map { |item| item.merge(owned: entity_owned?(item[:entity])) }
            end
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
            'Draft Companies and Minors from Grid'
          end

          def finished?
            all_drafted? || entities.all?(&:passed?)
          end

          def all_drafted?
            @companies.all? { |item| entity_owned?(item[:entity]) }
          end

          def actions(entity)
            return [] if finished?
            return [] unless entity == current_entity

            avail = available
            return ACTIONS if avail.any? { |e| entity.cash >= min_bid(e) }

            # Player can't afford any available item — only pass is valid
            # (auto_actions will auto-pass them without requiring UI interaction)
            ['pass']
          end

          def auto_actions(entity)
            return unless entity == current_entity

            avail = available
            return if avail.any? { |e| entity.cash >= min_bid(e) }

            # Player can't afford any available item — auto-pass
            [Engine::Action::Pass.new(entity)]
          end

          def process_bid(action)
            entity = action.company || action.minor || action.corporation
            player = action.entity
            price = action.price

            advance_clemens_circuit

            if entity.company?
              entity.owner = player
              player.companies << entity

              # Process shares ability (e.g. BYD gives BY_0, LD gives SX_0, OBB/NF/PB give BY shares)
              @game.abilities(entity, :shares) do |ability|
                ability.shares.each do |share|
                  # Track capital owed to the corporation; paid out when the corporation floats.
                  corp = share.corporation
                  @game.add_draft_capital(corp, share.num_shares * corp.par_price.price)
                  @game.share_pool.buy_shares(player, share, exchange: :free)
                end
              end

              # BYD is the Bayerische Direktor Papier — it IS the BY director's share, so close it
              if entity.sym == 'BYD'
                @log << "#{entity.name} is exchanged for the president's share of Bayrische Eisenbahn and closes"
                entity.close!

                # Clemens variant: BY floats immediately when the president's share is purchased
                if @game.option_clemens?
                  by = @game.corporation_by_id('BY')
                  @game.float_corporation(by) unless by.floated?
                end
              end
            elsif entity.minor?
              entity.owner = player
              entity.float!
              # Minor receives its purchase price from the bank as start capital (Rule I / Rule III)
              @game.bank.spend(price, entity)
              @game.place_home_token(entity)
            elsif entity.corporation?
              share = entity.shares.first
              @game.share_pool.buy_shares(player, share.to_bundle, exchange: :free)
            end

            player.spend(price, @game.bank)

            @log << "#{player.name} buys #{entity.name} for #{@game.format_currency(price)}"

            # Track who acted last so the stock round can start with the correct player
            @round.last_to_act = player

            # Unpass all players after a purchase so everyone gets another turn
            entities.each(&:unpass!)
            @round.next_entity_index!
            action_finalized
          end

          def process_pass(action)
            advance_clemens_circuit

            avail = available
            @log << if avail.none? { |e| action.entity.cash >= min_bid(e) }
                      "#{action.entity.name} cannot afford any available item and passes"
                    else
                      "#{action.entity.name} passes"
                    end
            action.entity.pass!
            @round.next_entity_index!

            @log << 'All players passed' if entities.all?(&:passed?)

            action_finalized
          end

          def action_finalized
            return unless finished?

            @round.reset_entity_index!
          end

          def committed_cash(_player, _show_hidden = false)
            0
          end

          def min_bid(entity)
            return unless entity

            entity.value
          end

          private

          # Clemens variant: track how many turns have been taken in the first circuit.
          # After all N players have gone once (in reversed order), flip entities back to
          # normal order. entity_index is at N-1; next_entity_index! wraps to 0 = P1. ✓
          def advance_clemens_circuit
            return unless @game.option_clemens?
            return if @game.clemens_first_circuit_done?

            @game.clemens_advance_first_circuit!
            return unless @game.clemens_first_circuit_done?

            # First circuit just completed — restore normal player order.
            # entity_index is at the last position; next_entity_index! will wrap to 0 (first player).
            @round.entities.replace(@game.players.dup)
          end
        end
      end
    end
  end
end
