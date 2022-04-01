# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../token'
require_relative '../../../step/token_merger'
require_relative '../../../step/programmer_merger_pass'

module Engine
  module Game
    module G18Dixie
      module Step
        class Conversion < Engine::Step::Base
          include Engine::Step::TokenMerger

          def actions(entity)
            return %w[merge] if entity.minor? && entity == current_entity && mergeable(entity).any?

            []
          end

          def merge_name(_entity = nil)
            'Exchange'
          end

          def description
            'Close & Exchange Minor'
          end

          def merger_auto_pass_entity
            # Buying and selling shares are done by other steps
            current_entity
          end

          def others_acted?
            !@round.converts.empty?
          end

          def process_merge(action)
            minor = action.entity
            target = action.corporation

            raise GameError, "Choose a corporation exchange #{minor.name} for" if !target || !mergeable(minor).include?(target)

            receiving = []

            if minor.cash.positive?
              receiving << @game.format_currency(minor.cash)
              minor.spend(minor.cash, target)
            end

            remove_duplicate_tokens(minor, target)
            tokens = move_tokens_to_major(target, minor)
            receiving << "and tokens (#{tokens.size}: hexes #{tokens.compact})"

            @log << "#{minor.name} is exchanged for a preferred share of #{target.name} "\
                    " receiving #{receiving.join(', ')}"

            @round.entities.delete(target)
            @game.exchange_minor(minor, target)

            # Deleting the entity changes turn order, restore it.
            # @round.goto_entity!(corporation) unless @round.entities.empty?
          end

          def mergeable_type(minor)
            "Corporations that #{minor.name} can be exchanged for a share of"
          end

          def show_other_players
            true
          end

          def mergeable(minor)
            return [] unless minor.floated?

            @game.minor_exchange_options(minor).select do |major|
              # Any major exchange option, where there is an exchange share left in the IPO
              @game.preferred_shares_by_major.any? do |m_id, shares|
                major == m_id && shares.any? do |share|
                  share.owner == major
                end
              end
            end
          end

          def round_state
            {
              converted: nil,
              converted_price: nil,
              tokens_needed: nil,
              converts: [],
            }
          end

          def move_tokens_to_major(major, minor)
            tokens = others_tokens(minor).map do |token|
              new_token = Engine::Token.new(major, price: 0)
              if token.hex
                token.swap!(new_token, check_tokenable: true)
                major.tokens << new_token
              else
                puts 'TODO: Confirm if unused minor tokens go onto a majors charter ever'
                # If so, uncomment this, perhaps with additional conditioning
                # unused << new_token
              end
              new_token.hex&.id
            end
            # Owner may no longer have a valid route.
            @game.graph.clear_graph_for(major)

            tokens
          end
        end
      end
    end
  end
end
