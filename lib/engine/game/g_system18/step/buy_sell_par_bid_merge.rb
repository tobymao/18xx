# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares_via_bid'

module Engine
  module Game
    module GSystem18
      module Step
        class BuySellParBidMerge < Engine::Step::BuySellParSharesViaBid
          # currently this is very specific to the Russia map (and cohorts)
          MIN_BID = 100
          MERGE_PHASE = 3
          MAJOR_PHASE = 4
          PURCHASE_ACTIONS = [Action::BuyCompany, Action::BuyShares, Action::Par, Action::Choose].freeze

          def actions(entity)
            return corporation_actions(entity) if entity.corporation?
            return [] unless entity == current_entity
            return %w[bid pass] if @auctioning

            actions = []
            actions << 'choose' if can_convert_any?(entity) || can_merge_any?(entity)
            actions.concat(super)
            actions << 'pass' if !actions.empty? && !actions.include?('pass')

            actions
          end

          def setup
            super
            @chosen_corporation = nil
          end

          def win_bid(winner, _company)
            entity = winner.entity
            corporation = winner.corporation
            price = winner.price

            @log << "#{entity.name} wins bid on #{corporation.name} for #{@game.format_currency(price)}"
            par_price = price / 2

            share_price = get_all_par_prices(corporation).find { |sp| sp.price <= par_price }

            # Temporarily give the entity cash to buy the corporation PAR shares
            @game.bank.spend(share_price.price * 2, entity)

            action = Action::Par.new(entity, corporation: corporation, share_price: share_price)
            # give the generated Par action the same time stamp as the action that triggered the auction win
            # this prevents problems with a programmed pass triggering on the Par
            action.created_at = @game.actions.last.created_at
            process_par(action)

            # Clear the corporation of 'share' cash grabbed earlier.
            corporation.spend(corporation.cash, @game.bank)

            # Then move the full amount.
            entity.spend(price, corporation)

            @auctioning = nil

            # Player to the right of the winner is the new player
            @round.goto_entity!(winner.entity)
            pass!
          end

          def can_bid_any?(entity)
            max_bid(entity) >= MIN_BID && !bought? &&
            @game.corporations.any? do |c|
              @game.can_par?(c, entity) && c.type == :minor && can_buy?(entity, c.shares.first&.to_bundle)
            end
          end

          def can_ipo_any?(entity)
            @game.phase.name.to_i >= MAJOR_PHASE && !bought? &&
            @game.corporations.any? do |c|
              @game.can_par?(c, entity) && c.type == :major && can_buy?(entity, c.shares.first&.to_bundle)
            end
          end

          def get_all_par_prices(_corp)
            # minors and majors can start at the same values
            @game.stock_market.share_prices_with_types(%i[par])
          end

          def ipo_type(entity)
            # Major's are par, minors are bid
            phase = @game.phase.name.to_i
            case entity.type
            when :major
              if phase >= MAJOR_PHASE
                if @game.home_token_locations(entity).empty?
                  'No home token locations are available'
                else
                  :par
                end
              else
                "Cannot start till phase #{MAJOR_PHASE}"
              end
            when :national
              'Cannot start'
            else
              :bid
            end
          end

          def can_convert?(minor)
            (minor.owner == current_entity) && (minor.type == :minor) &&
              minor.floated? && !bought?
          end

          def can_convert_any?(_entity)
            return false if @game.phase.name.to_i < MERGE_PHASE
            return false if bought?

            @game.corporations.any? { |corporation| can_convert?(corporation) }
          end

          def connected?(minor_a, minor_b)
            # Mergeable candidates must be connected by track, minors only have one token which simplifies it
            # (partially borrowed from 1867)
            parts = @game.graph.connected_nodes(minor_a).keys
            parts.select(&:city?).any? { |c| c.tokens.compact.any? { |t| t.corporation == minor_b } }
          end

          def possible_mergers(owner)
            possible = []
            @game.corporations.select { |c| c.type == :minor && c.owner == owner }.combination(2) do |pair|
              possible << pair if connected?(pair[0], pair[1])
            end
            possible
          end

          def can_merge_any?(_entity)
            return false if @game.phase.name.to_i < MERGE_PHASE
            return false if bought?

            !possible_mergers(current_entity).empty?
          end

          def corporation_actions(corporation)
            return [] unless choice_available?(corporation)

            %w[choose pass]
          end

          def choice_available?(entity)
            entity.corporation? && entity.type == :major && !entity.floated? && can_convert_any?(entity)
          end

          def entity_choices(entity)
            vals = @game.corporations.select { |c| c.owner == current_entity && c.type == :minor }.to_h do |minor|
              ["#{entity.id}:#{minor.id}", "Convert #{minor.id}"]
            end
            possible_mergers(current_entity).each do |pair|
              vals["#{entity.id}:#{pair[0].id}+#{pair[1].id}"] = "Merge #{pair[0].id} and #{pair[1].id}"
            end
            vals
          end

          def choice_name; end

          def process_choose(action)
            choice = action.choice
            colon_index = choice.index(':')
            plus_index = choice.index('+')
            corp = @game.corporation_by_id(choice[0..colon_index - 1])

            if plus_index
              minor_a = @game.corporation_by_id(choice[colon_index + 1..plus_index - 1])
              minor_b = @game.corporation_by_id(choice[plus_index + 1..-1])
              @game.merge(current_entity, corp, minor_a, minor_b)
            else
              minor = @game.corporation_by_id(choice[colon_index + 1..-1])
              @game.convert(current_entity, corp, minor)
            end

            track_action(action, corp)

            @chosen_corporation = corp
          end

          def can_buy_multiple?(_entity, corporation, _owner)
            return false unless @round.current_actions.any? { |x| x.is_a?(Action::Choose) }

            corporation == @chosen_corporation &&
            @round.current_actions.none? { |x| x.is_a?(Action::Par) } &&
              @round.current_actions.none? { |x| x.is_a?(Action::BuyShares) }
          end
        end
      end
    end
  end
end
