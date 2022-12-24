# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'minor_exchange'

module Engine
  module Game
    module G18EU
      module Step
        class FinalExchange < Engine::Step::Base
          include MinorExchange

          def actions(entity)
            return [] if entity.corporation?
            return [] unless @round.players_history[entity].empty?

            actions = []
            actions << 'pass' if can_pass?(entity)
            actions << 'buy_shares' if can_merge?(entity)

            actions
          end

          def description
            'Exchange Connected Minors for a Share'
          end

          def log_pass(entity)
            @log << "#{entity.name} passes"
          end

          def log_skip(entity)
            @log << "#{entity.name} has no valid actions and passes"
          end

          def pass_description
            'Discard Minor(s)'
          end

          def round_state
            {
              pending_acquisition: nil,
              players_history: Hash.new { |h2, k2| h2[k2] = [] },
            }
          end

          def setup
            @round.players_history[current_entity].clear
          end

          def process_buy_shares(action)
            entity = action.entity
            exchange_minor(entity, action.bundle)
            @round.players_history[entity.player] << action
          end

          def process_pass(_action)
            @game.minors.dup.each do |minor|
              next unless minor&.owner == current_entity

              merge_minor!(minor, nil, @game.bank)
            end

            super
          end

          def exchange_minor(minor, bundle)
            corporation = bundle.corporation
            source = bundle.owner
            unless can_gain?(minor.owner, bundle, exchange: true)
              raise GameError, "#{minor.name} cannot be exchanged for #{corporation.name}"
            end

            exchange_share(minor, corporation, source)
            merge_minor!(minor, corporation, source)
          end

          def can_merge?(entity)
            entity.minor? || @game.owns_any_minor?(entity)
          end

          def can_pass?(entity)
            owned = @game.minors.select { |minor| minor.owner == entity }
            return false if owned.empty?

            owned.all? { |minor| can_discard?(minor) }
          end

          def can_discard?(minor)
            return true if @game.loading

            connected = connected_corporations(minor)
            return true if connected.empty?

            connected.any? { |c| !exchange?(c) }
          end

          def can_gain?(_entity, bundle, exchange: false)
            return false unless exchange

            bundle.corporation.ipoed
          end

          def buy_shares(entity, shares, exchange: nil, swap: nil, allow_president_change: true, borrow_from: nil)
            raise GameError, "Cannot buy a share of #{shares&.corporation&.name}" unless exchange

            @game.share_pool.buy_shares(entity,
                                        shares,
                                        exchange: exchange,
                                        swap: swap,
                                        allow_president_change: allow_president_change)
          end

          def can_buy?(_entity, _bundle)
            false
          end

          def can_buy_multiple?(_entity, _corporation, _owner)
            false
          end

          def can_sell_any?(_entity)
            false
          end

          def can_ipo_any?(_entity)
            false
          end

          def purchasable_companies(_entity)
            []
          end

          def ipo_type(_entity)
            :par
          end
        end
      end
    end
  end
end
