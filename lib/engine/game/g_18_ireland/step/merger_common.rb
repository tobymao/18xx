# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18Ireland
      module Step
        module MergerCommon
          def vote_summary
            " (For: #{@round.votes_for}, Against: #{@round.votes_against})"
          end

          def check_result
            # Assumes @round.votes_needed is half+1
            if @round.votes_for >= @round.votes_needed
              @game.log << 'Majority has voted for merger and proposal is accepted'
              @round.vote_outcome = :for
              @round.to_vote = []
            elsif @round.votes_against >= @round.votes_needed
              @game.log << 'Majority has voted against merger and proposal is rejected'
              @round.vote_outcome = :against
              @round.to_vote = []
            elsif @round.to_vote.empty?
              @game.log << 'Votes are tied and proposal is rejected'
              @round.vote_outcome = :against
            end
          end
        end
      end
    end
  end
end
