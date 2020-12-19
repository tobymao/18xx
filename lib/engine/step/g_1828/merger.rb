# frozen_string_literal: true

require_relative '../base'
require_relative '../../token'

module Engine
  module Step
    module G1828
      class Merger < Base
        ACTIONS = %w[merge].freeze

        def description
          "Select a corporation to merge with #{initiator.name}"
        end

        def actions(_entity)
          return [] unless initiator

          ACTIONS
        end

        def blocks?
          initiator
        end

        def process_merge(action)
          corporation = action.entity
          target = action.corporation
          @log << "Merging #{corporation.name} with #{target.name}"

          merge_corporations(corporation, target)
        end

        def merging_corporation
          initiator
        end

        def merge_name
          'Merge'
        end

        def mergeable_type(corporation)
          "Corporations that can merge with #{corporation.name}"
        end

        def show_other_players
          false
        end

        def active_entities
          [@round.acting_player]
        end

        def initiator
          @round.merge_initiator
        end

        def round_state
          {
            merge_target: nil,
          }
        end

        def mergeable_entities(entity = @round.acting_player, corporation = initiator)
          return [] if corporation.owner != entity

          @game.corporations.select do |candidate|
            next if candidate == corporation ||
                    !candidate.ipoed ||
                    candidate.operated? != corporation.operated? ||
                    (!candidate.floated? && !corporation.floated?)

            # Mergeable not possible unless a player owns 5+ shares between the corporations
            @game.players.any? do |player|
              num_shares = player.num_shares_of(candidate) + player.num_shares_of(corporation)
              num_shares >= 6 ||
                (num_shares == 5 && !did_sell?(player, candidate) && !did_sell?(player, corporation))
            end
          end
        end

      private

        def merge_corporations(first, second)
          @system = first
          second.spend(second.cash, @system)
          #second.transfer(:trains, @system)
          hexes_to_remove_tokens = merge_tokens(@system, second)

          if hexes_to_remove_tokens.any?
            @round.corporation_removing_tokens = @system
            @round.hexes_to_remove_tokens = hexes_to_remove_tokens
          end

          @system
        end

        def merge_tokens(first, second)
          hexes_to_remove_tokens = []

          used, unused = (first.tokens + second.tokens).partition(&:used)
          first.tokens.clear

          used.group_by { |t| t.city.hex }.each do |hex, tokens|
            if tokens.one? && tokens.first.corporation == first
              first.tokens << tokens.first
            elsif tokens.one?
              replace_token(first, tokens.first)
            elsif tokens[0].city == tokens[1].city
              tokens.find { |t| t.corporation == second }.remove!
              @game.place_blocking_token(hex)
            else
              first.tokens << tokens.find { |t| t.corporation == first }
              replace_token(first, tokens.find { |t| t.corporation == second })
              hexes_to_remove_tokens << hex
            end
          end

          unused.each { |t| first.tokens << Engine::Token.new(first, price: t.price) }

          hexes_to_remove_tokens
        end

        def replace_token(corporation, token)
          new_token = Engine::Token.new(corporation, price: token.price)
          corporation.tokens << new_token
          token.swap!(new_token, check_tokenable: false)
        end
      end
    end
  end
end
