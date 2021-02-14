# frozen_string_literal: true

require_relative '../base'
require_relative '../token_merger'

module Engine
  module Step
    module G18CZ
      class BuyCorporation < Base
        include TokenMerger

        ACTIONS = %w[buy_corporation pass].freeze

        def actions(entity)
          return [] if entity != current_entity || @game.corporations.none? { |item| can_buy?(entity, item) }

          ACTIONS
        end

        def description
          'Buy Corporations'
        end

        def process_buy_corporation(action)
          entity = action.entity
          corporation = action.corporation
          price = action.price

          max_cost = corporation.num_player_shares * price
          raise GameError,
                "#{entity.name} cannot buy #{corporation.name} for #{price} per share.
                 #{max_cost} is needed but only #{entity.cash} available" if entity.cash < max_cost

          @game.players.each do |player|
            num = player.num_shares_of(corporation, ceil: false)
            if num.positive?
              entity.spend(num * price, player)
              @log << "Player #{player.name} receives #{num * price} for #{num} shares from #{entity.name}"
            end
          end
          receiving = []

          companies = @game.transfer(:companies, corporation, entity).map(&:name)
          receiving << "companies (#{companies.join(', ')})" if companies.any?

          trains = @game.transfer(:trains, corporation, entity)
          receiving << "trains (#{trains.map(&:name)})" if trains.any?

          @round.bought_trains << {
            entity: entity,
            trains: trains,
          }

          remove_duplicate_tokens(entity, corporation)
          tokens = move_tokens_to_surviving(entity, corporation, price_for_new_token: 100, check_tokenable: false)
          receiving << "and tokens (#{tokens.size}: hexes #{tokens.compact})"

          @log << "#{entity.name} buys #{corporation.name}
          for #{@game.format_currency(price)} per share receiving #{receiving.join(', ')}"

          corporation.close!
          @game.corporations.delete(corporation)
        end

        def pass_description
          @acted ? 'Done (Corporations)' : 'Skip (Corporations)'
        end

        def can_buy?(entity, corporation)
          return false if entity.type == :small || !corporation.floated? || corporation.closed?

          if entity.type == :medium && corporation.type == :small ||
             entity.type == :large && (corporation.type == :small || corporation.type == :medium)
            return true
          end

          false
        end

        def show_other_players
          false
        end

        def transfer_companies(source, destination)
          return unless source.companies.any?

          transferred = @game.transfer(:companies, source, destination)

          @game.log << "#{destination.name} takes #{transferred.map(&:name).join(', ')} from #{source.name}"
        end

        def price_range(_corporation, corporation_to_boy)
          max_price = (corporation_to_boy.share_price.price * 1.5).ceil
          min_price = (corporation_to_boy.share_price.price * 0.5).ceil
          [min_price, max_price]
        end
      end
    end
  end
end
