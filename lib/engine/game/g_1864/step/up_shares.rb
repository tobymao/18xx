# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1864
      module Step
        class UPShares < Engine::Step::Base
          ACTIONS = %w[choose].freeze

          def actions(entity)
            return [] if entity != current_entity || !share

            ACTIONS
          end

          def active?
            !@game.pending_up_share_buyers.empty?
          end

          def skip!
            return if share

            until @game.pending_up_share_buyers.empty?
              @game.pending_up_share_buyers.each do |buyer|
                @log << "#{buyer[:player].name} cannot buy #{@game.union_pacific.name} shares - the IPO is empty"
              end
              @game.pending_up_share_buyers.clear
              @game.regionalize_pending!
            end
          end

          def active_entities
            [current_entity].compact
          end

          def current_entity
            @game.pending_up_share_buyers.first&.fetch(:player)
          end

          def description
            "Buy #{@game.union_pacific.name} shares"
          end

          def choice_name
            "Buy #{@game.union_pacific.name} shares"
          end

          def choice_available?(entity)
            entity == current_entity
          end

          def hide_corporations?
            true
          end

          def choices
            choices = (1..max_buyable(current_entity)).to_h do |count|
              price = @game.format_currency(share_price * count)
              [count.to_s, "Buy #{count} share#{'s' if count > 1} (#{price})"]
            end
            choices['pass'] = 'Decline'
            choices
          end

          def share
            @game.union_pacific.ipo_shares.first
          end

          def share_price
            @game.union_pacific.share_price.price
          end

          def max_buyable(entity)
            allowed = [@game.pending_up_share_buyers.first&.fetch(:shares).to_i, @game.union_pacific.ipo_shares.size].min
            (1..allowed).take_while { |count| can_buy?(entity, count) }.last || 0
          end

          def can_buy?(entity, count = 1)
            return false if @game.union_pacific.ipo_shares.size < count

            entity.cash >= share_price * count &&
              @game.union_pacific.holding_ok?(entity, share.percent * count) &&
              @game.num_certs(entity) + count <= @game.cert_limit(entity)
          end

          def process_choose(action)
            entity = action.entity
            raise GameError, "Not #{entity.name}'s turn to buy #{@game.union_pacific.name} shares" unless entity == current_entity

            if action.choice == 'pass'
              @log << "#{entity.name} declines to buy #{@game.union_pacific.name} shares"
            else
              count = action.choice.to_i
              raise GameError, "#{entity.name} cannot buy #{action.choice} #{@game.union_pacific.name} shares" if
                count < 1 || count > max_buyable(entity)

              shares = @game.union_pacific.ipo_shares.take(count)
              shares.each { |share| share.buyable = true }
              @game.share_pool.buy_shares(entity, ShareBundle.new(shares))
            end
            @game.pending_up_share_buyers.shift
            @game.regionalize_pending!
          end
        end
      end
    end
  end
end
