# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18Mag
      module Step
        class SimpleDraft < Engine::Step::Base
          ACTIONS = %w[bid].freeze
          MAX_NUM_MINORS = {
            2 => 3,
            3 => 4,
            4 => 3,
            5 => 2,
            6 => 2,
          }.freeze

          MAX_NUM_MINORS_OPTIONAL = {
            2 => 3,
            3 => 5,
            4 => 4,
            5 => 3,
            6 => 2,
          }.freeze

          MAX_NUM_SHARES = {
            2 => 1,
            3 => 2,
            4 => 1,
            5 => 2,
            6 => 2,
          }.freeze

          LEFTOVER_NUM_MINORS = {
            2 => 1,
            3 => 1,
            4 => 1,
            5 => 3,
            6 => 1,
          }.freeze

          LEFTOVER_NUM_MINORS_OPTIONAL = {
            2 => 1,
            3 => 1,
            4 => 0,
            5 => 1,
            6 => 1,
          }.freeze

          LEFTOVER_NUM_SHARES = {
            2 => 2,
            3 => 1,
            4 => 3,
            5 => 4,
            6 => 2,
          }.freeze

          def setup
            @game.remove_minors! if @game.new_minors_simple?
            @minors = @game.minors.reject { |m| m.name == 'mine' }.sort_by { |m| m.name.to_i }
            @minor_count = Hash.new(0)
            @share_count = Hash.new(0)
            @max_minors = if @game.new_minors_challenge?
                            MAX_NUM_MINORS_OPTIONAL[@game.players.size]
                          else
                            MAX_NUM_MINORS[@game.players.size]
                          end
            @max_shares = MAX_NUM_SHARES[@game.players.size]
            @leftover_minors = if @game.new_minors_challenge?
                                 LEFTOVER_NUM_MINORS_OPTIONAL[@game.players.size]
                               else
                                 LEFTOVER_NUM_MINORS[@game.players.size]
                               end
            @leftover_shares = LEFTOVER_NUM_SHARES[@game.players.size]

            @shares_a = @game.corporations.dup
            @shares_b = @game.players.size > 4 ? @game.corporations.dup : []
          end

          def available
            avail = []
            avail.concat(@minors) if @minor_count[current_entity] < @max_minors
            avail.concat((@shares_a + @shares_b).uniq.sort) if @share_count[current_entity] < @max_shares
            avail
          end

          def may_choose?(_company)
            true
          end

          def auctioning; end

          def auctioneer?
            false
          end

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
            'Draft a Company or Share'
          end

          def finished?
            @minors.size == @leftover_minors && (@shares_a + @shares_b).size == @leftover_shares
          end

          def actions(entity)
            return [] if finished?

            entity == current_entity ? ACTIONS : []
          end

          def process_bid(action)
            player = action.entity

            if action.minor
              assign_minor(player, action.minor)
            elsif action.corporation
              assign_ipo_share(player, action.corporation)
            else
              raise GameError, 'Logic error: must specify minor or corporation on bid action'
            end

            @round.next_entity_index!
            action_finalized
          end

          def assign_minor(player, minor)
            minor.owner = player
            @minors.delete(minor)
            @minor_count[player] += 1

            @log << "#{player.name} chooses Minor #{minor.name} (#{minor.full_name})"

            @game.float_minor(minor)
          end

          def assign_ipo_share(player, corp)
            @share_count[player] += 1
            if @shares_a.include?(corp)
              @shares_a.delete(corp)
            else
              @shares_b.delete(corp)
            end

            @log << "#{player.name} chooses share of #{corp.name} (#{corp.full_name})"

            @game.share_pool.transfer_shares(
              @game.share_pool.shares_of(corp).find { |s| s.percent == 10 }.to_bundle,
              player,
              spender: player,
              receiver: @game.bank,
              price: 0
            )
          end

          def action_finalized
            return unless finished?

            @minors.each do |minor|
              @log << "Minor #{minor.name} is removed from the game"
              hex = @game.hex_by_id(minor.coordinates)
              hex.tile.cities[minor.city || 0].remove_tokens!
              hex.tile.cities[minor.city || 0].remove_reservation!(minor)

              @game.minors.delete(minor)
            end
            @round.reset_entity_index!
          end

          def committed_cash(_player, _show_hidden = false)
            0
          end

          def min_bid(company)
            return unless company

            company.value
          end
        end
      end
    end
  end
end
