# frozen_string_literal: true

require_relative '../../../round/merger'

module Engine
  module Game
    module G1893
      module Round
        class Merger < Engine::Round::Stock
          attr_accessor :offering, :voters, :votes, :yes, :no, :done

          def self.short_name
            'MR'
          end

          def self.round_name
            'Merger Round'
          end

          def setup
            super

            skip_steps
            next_entity! if @offering.empty? || merger_candidates_for(current_entity).empty?
          end

          def finished?
            @offering.empty? && @game.potential_discard_trains.empty?
          end

          def merge_target
            @offering.first
          end

          def handle_vote(choice)
            percent = @votes[current_entity]
            case choice
            when :yes
              @log << "#{current_entity.name} approves merge of #{names(merger_candidates_for(current_entity))}"
              @yes += percent
              @done = @yes >= 50
              @log << "Yes has #{@yes}, No has #{@no}"
              return unless @done

              @log << "-- #{merge_target.name} are founded due to a 50%+ Yes vote"
              @log << "#{names(merger_candidates)} are merged into #{merge_target.name}"

              merge_target == @game.agv ? @game.found_agv : @game.found_hgk
            when :no
              @log << "#{current_entity.name} declines merge of #{names(merger_candidates_for(current_entity))}"
              @no += percent
              @done = @no > 50
              @log << "Yes has #{@yes}, No has #{@no}"
              return unless @done

              @log << "#{names(merger_candidates)} are not merged into #{merge_target.name} at this time"
            end
            @offering.delete(merge_target)
          end

          def current_entity
            @voters[@entity_index]
          end

          def select_entities
            @offering = []
            @voters = []
            @votes = {}
            @yes = 0
            @no = 0
            if @game.agv_auto_found
              @log << "-- #{@game.agv.name} is founded as phase 5 has been reached"
              @log << "#{names(merger_candidates(@game.agv))} are merged into #{@game.agv.name}"
              @game.found_agv
            elsif @game.agv_mergable
              add_merge_info_agv
            else
              skip_message(@game.agv)
            end
            if @game.hgk_auto_found
              @log << "-- #{game.hgk.name} is founded as phase 6 has been reached"
              @log << "#{names(merger_candidates(@game.hgk))} are merged into #{@game.hgk.name}"
              @game.found_hgk
            elsif @game.hgk_mergable
              add_merge_info_hgk
            else
              skip_message(@game.hgk)
            end
            return @game.players if @offering.empty?

            @no = 100 - @votes.sum { |_player, percent| percent }
            @voters
          end

          def merger_candidates(mergable = nil)
            @game.mergers(mergable || @game.round.merge_target)
          end

          def merger_candidates_for(player)
            merger_candidates.select { |c| c.owner == player }
          end

          def names(merger_candidates)
            merger_candidates.map(&:name).join(', ')
          end

          private

          def add_merge_info_agv
            @offering << @game.agv
            add_player_vote_info_for_reserved_share(@game.ekb_reserved_share)
            add_player_vote_info_for_reserved_share(@game.ksz_reserved_share)
            add_player_vote_info_for_reserved_share(@game.bkb_reserved_share)
            add_players_vote_info_for_bought_shares(@game.agv)
          end

          def add_merge_info_hgk
            @offering << @game.hgk
            add_player_vote_info_for_reserved_share(@game.kfbe_reserved_share)
            add_player_vote_info_for_reserved_share(@game.kbe_reserved_share)
            add_player_vote_info_for_reserved_share(@game.hdsk_reserved_share)
            add_players_vote_info_for_bought_shares(@game.hgk)
          end

          def add_player_vote_info_for_reserved_share(reserved_share)
            player = reserved_share[:minor] ? reserved_share[:minor].owner : reserved_share[:private].owner
            add_player_vote_info(player, reserved_share[:share].percent)
          end

          def add_player_vote_info(player, percent)
            if @voters.include?(player)
              @votes[player] += percent
              @log << "Player #{player} adds another #{percent} votes, to get #{@votes[player]}"
            else
              @voters << player
              @log << "Player #{player} has #{percent} votes"
              @votes[player] = percent
            end
          end

          def add_players_vote_info_for_bought_shares(corporation)
            @game.players.each do |player|
              percent = 10 * player.num_shares_of(corporation, ceil: false)
              next unless percent.positive?

              add_player_vote_info(player, percent)
            end
          end

          def skip_message(mergable)
            @log << if mergable.floated?
                      "#{mergable.name} merge already done - skipped during MR"
                    else
                      "#{mergable.name} not yet available for merge - skipped during MR"
                    end
          end
        end
      end
    end
  end
end
