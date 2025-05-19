# frozen_string_literal: true

require_relative '../../g_1867/step/merge'

module Engine
  module Game
    module G1807
      module Step
        class Merge < G1867::Step::Merge
          def description
            return 'Choose public company' if @converting || @merge_major
            return 'Merge public company' if @merging

            'Convert, merge or takeover minor company'
          end

          def mergeable_type(corporation)
            if @converting
              'New public company for conversion:'
            elsif @merge_major
              'New public company for merger:'
            else
              "Minor companies that can merge with #{corporation.name}:"
            end
          end

          def exchange_name(_entity = nil)
            'Take over'
          end

          def exchangeable_type(corporation)
            "Public companies that can take over #{corporation.name}:"
          end

          def round_state
            super.merge({ corporations_acquiring_minors: nil })
          end

          def actions(entity)
            return [] unless entity == current_entity
            return [] unless entity.corporation?
            return [] if @round.converted

            actions = super
            # FIXME: need to avoid checking graph in actions method
            actions << 'buy_shares' if !@merging && can_exchange?(entity)
            actions
          end

          def mergeable(corporation)
            if @converting || @merge_major
              @game.corporations.select do |target|
                target.type == :public &&
                !target.floated?
              end
            else
              {
                mergeable_type(corporation) => mergeable_candidates(corporation),
                exchangeable_type(corporation) => exchange_candidates(corporation),
              }
            end
          end

          def exchanging?(corporation)
            can_exchange?(corporation)
          end

          def process_buy_shares(action)
            bundle = action.bundle
            major = bundle.corporation
            minor = action.entity
            player = minor.owner

            if !@game.loading && !exchange_candidates(minor).include?(major)
              raise GameError, "#{major.name} cannot take over #{minor.name}"
            end

            @game.share_pool.buy_shares(player, bundle, exchange: :free)
            takeover(minor, major)
          end

          private

          def london_token?(corporation)
            corporation.placed_tokens.map(&:city).intersect?(@game.london_cities)
          end

          # Cities that a corporation can trace a route to.
          def connected_cities(corporation)
            return super unless london_token?(corporation)

            super | @game.london_cities
          end

          # Cities that are on the same hex as one where the corporation has a token.
          # This will include the cities where the corporation's tokens are.
          def colocated_cities(corporation)
            cities = corporation.placed_tokens.flat_map { |t| t.hex.tile.cities }

            if london_token?(corporation)
              cities | @game.london_cities
            else
              cities
            end
          end

          # Finds the public companies (majors) that are able to acquire a
          # minor company. To do this they need to have a treasury share and
          # must be able to trace a route to one of the minor's tokens, or have
          # tokens co-located on the same tile.
          def exchange_candidates(minor)
            cities = connected_cities(minor) | colocated_cities(minor)
            cities.flat_map { |city| city.tokens.compact.map(&:corporation) }
                  .uniq
                  .select { |corp| corp.type == :public && corp.num_treasury_shares.positive? }
          end

          def can_exchange?(corporation)
            return false unless corporation.corporation?
            return false unless corporation.type == :minor

            !exchange_candidates(corporation).empty?
          end

          def remove_duplicate_tokens(surviving, others)
            # When minors are merging, or a minor is being acquired by a public
            # company then duplicate tokens are allowed in London.
            return if surviving.type == :minor && london_token?(surviving)

            # When public companies are merging to form a system then there
            # are no restrictions on duplicate tokens.
            return if surviving.type == :public

            super
          end

          def takeover(minor, major)
            remove_duplicate_tokens(minor, [major])
            received = move_assets(minor, major)
            if !minor.placed_tokens.empty? && !major.unplaced_tokens.empty?
              @round.corporations_acquiring_minors = { major: major, minor: minor }
              received << "a token in #{@game.token_location(minor.placed_tokens.first)}"
            else
              @game.close_corporation(minor)
            end
            @log << "#{major.name} takes over #{minor.name} receiving #{received.join(', ')}"
          end
        end
      end
    end
  end
end
