# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18Ireland
      module Step
        class MergerVote < Engine::Step::Base
          def actions(entity)
            return [] if !entity.player? || @round.to_vote.empty?

            ['choose']
          end

          def choice_name
            'Vote for Merger'
          end

          def choices
            votes = current_voter.last
            { for: "#{votes} votes For Merger", against: "#{votes} votes Against Merger" }
          end

          def description
            return 'Failed merge, please undo' if @broken_merge

            'Voting on Merger'
          end

          def process_choose(action)
            vote = action.choice
            entity = action.entity
            votes = current_voter.last
            raise GameError, 'Not players turn' unless entity == current_voter.first

            if vote == :for
              @round.votes_for += votes
            else
              @round.votes_against += votes
            end

            @round.to_vote.shift
            @game.log << "#{entity.name} casts #{votes} votes #{vote} merger"\
            " (For: #{@round.votes_for}, Against: #{@round.votes_against})"
            check_result
          end

          def check_result
            if @round.votes_for >= @round.votes_needed
              @game.log << 'Majority has voted for merger and proposal is accepted'
              @round.vote_outcome = :for
              @round.to_vote = []
            elsif @round.votes_against > @round.votes_needed
              @game.log << 'Majority has voted against merger and proposal is rejected'
              @round.vote_outcome = :against
              @round.to_vote = []
            elsif @round.to_vote.empty?
              @game.log << 'Votes are tided and proposal is rejected'
              @round.vote_outcome = :against
            end
          end

          def corporation
            @round.converted
          end

          def active?
            !@round.to_vote.empty?
          end

          def eligible_players
            @round.to_vote.first.first
          end

          def current_voter
            @round.to_vote.first
          end

          def active_entities
            return [] unless active?

            [current_voter.first]
          end

          def show_other_players
            true
          end

          def mergeable(_entity)
            @round.merging
          end
        end
      end
    end
  end
end
