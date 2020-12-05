# frozen_string_literal: true

require_relative '../base'
require_relative '../../token'

module Engine
  module Step
    module G1867
      class Merge < Base
        def actions(entity)
          return [] if !entity.corporation? || entity != current_entity

          actions = []

          return ['merge'] if @converting

          actions << 'convert' if can_convert?(entity)
          actions << 'pass' if actions.any?
          actions
        end

        def merge_name
          return 'Convert' if @converting

          'Merge'
        end

        def can_convert?(entity)
          # @todo: share price
          entity.type == :minor
        end

        def description
          'Convert or Merge Minor Corporation'
        end

        def process_convert(action)
          @converting = action.entity
        end

        def finish_convert(action)
          corporation = action.entity
          target = action.corporation

          if !target || !mergeable(corporation).include?(target)
            @game.game_error("Choose a corporation to merge with #{corporation.name}")
          end

          @game.stock_market.set_par(target, corporation.share_price)
          owner = corporation.owner

          @round.entities.delete(corporation)
          @converting = nil
          @game.close_corporation(corporation)

          share = target.shares.first
          @game.share_pool.buy_shares(owner, share.to_bundle, exchange: :free)

          move_tokens(corporation, target)
          receiving = move_assets(corporation, target)

          @log << "#{corporation.name} converts into #{target.name} receiving #{receiving.join(', ')}"
        end

        def move_assets(from, to)
          receiving = []

          if from.cash.positive?
            receiving << @game.format_currency(from.cash)
            from.spend(from.cash, to)
          end

          companies = from.transfer(:companies, to).map(&:name)
          receiving << "companies (#{companies.join(', ')})" if companies.any?

          loans = from.transfer(:loans, to).size
          receiving << "loans (#{loans})" if loans.positive?

          trains = from.transfer(:trains, to).map(&:name)
          receiving << "trains (#{trains})" if trains.any?

          receiving
        end

        def move_tokens(from, to)
          from.tokens.each do |token|
            new_token = to.next_token
            token.swap!(new_token)
          end
        end

        def process_merge(action)
          return finish_convert(action) if @converting

          # @todo: real merge
        end

        def new_share_price(corporation, target)
          new_price =
            if corporation.total_shares == 2
              corporation.share_price.price + target.share_price.price
            else
              (corporation.share_price.price + target.share_price.price) / 2
            end
          @game.find_share_price(new_price)
        end

        def log_pass(entity)
          super unless entity.share_price.liquidation?
        end

        def mergeable_type(corporation)
          if @converting
            'New Major Corporation'
          else
            "Corporations that can merge with #{corporation.name}"
          end
        end

        def mergeable(_corporation)
          if @converting
            @game.corporations.select do |target|
              target.type == :major &&
              !target.floated?
            end
          else
            []
          end
        end

        def show_other_players
          false
        end

        def round_state
          {
            converted: nil,
            converted_price: nil,
            tokens_needed: nil,
            converts: [],
          }
        end
      end
    end
  end
end
