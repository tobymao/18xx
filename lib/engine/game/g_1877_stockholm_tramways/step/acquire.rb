# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1877StockholmTramways
      module Step
        class Acquire < Engine::Step::Base
          include Engine::Step::ShareBuying

          def actions(entity)
            return [] if @merge_finished || @game.sl

            if @finish_action
              return @finish_action if entity == current_entity.owner
            else
              return [] unless entity == current_entity
            end

            %w[merge pass]
          end

          def description
            if @finish_action
              'Buy Additional Shares for Half Price'
            else
              'Acquire Corporation'
            end
          end

          def setup
            @finish_action = nil
            @finish_corporation = nil
            @merge_finished = false
          end

          def auto_actions(entity)
            if @finish_action
              return [Engine::Action::Pass.new(entity)] if entity.cash < @finish_corporation.share_price.price / 2
            elsif mergeable(entity).empty?
              return [Engine::Action::Pass.new(entity)]
            end

            super
          end

          def merge_name(_entity = nil)
            'Acquire'
          end

          def merger_auto_pass_entity
            current_entity
          end

          def can_merge?(entity)
            mergeable(entity).any?
          end

          def log_pass(entity)
            return super unless @finish_action

            @log << "#{entity.name} skips buying additional shares"
          end

          def pass!
            if @finish_action
              @finish_action = nil
              @finish_corporation = nil
              @merge_finished = true
            end
            super
          end

          def process_merge(action)
            @log << "#{action.entity.name} will acquire #{action.corporation.name}"
            @game.start_merge(action.entity, action.corporation)
            @finish_action = %w[buy_shares pass]
            @finish_corporation = action.entity
          end

          def can_buy?(entity, bundle)
            return unless bundle&.buyable

            bundle.corporation == @finish_corporation &&
              entity.cash >= bundle.price / 2 &&
              can_gain?(entity, bundle)
          end

          def ipo_type(_)
            nil
          end

          def process_buy_shares(action)
            entity = action.entity
            corporation = action.bundle.corporation

            # buy share for half its price
            share_price = corporation.share_price
            corporation.share_price = SharePrice.new(share_price.coordinates, price: share_price.price / 2)
            buy_shares(entity, action.bundle)
            corporation.share_price = share_price

            return if entity.cash >= share_price.price / 2 && entity.percent_of(corporation) < 60

            pass!
          end

          def mergeable_type(corporation)
            "Corporations that #{corporation.name} can acquire"
          end

          def mergeable(corporation)
            return [] unless corporation.operated?

            president = corporation.owner
            parts = @game.graph.connected_nodes(corporation).keys
            parts.select(&:city?).flat_map { |hex| hex.tokens.compact.map(&:corporation) }.uniq
              .reject { |other| other == corporation }
              .select do |other|
                other.operated? &&
                (president.percent_of(corporation) + president.percent_of(other)) * 2 >
                200 - (@game.share_pool.percent_of(corporation) + @game.share_pool.percent_of(other)) &&
                (corporation.tokens.select(&:used).map(&:hex) +
                other.tokens.select(&:used).map(&:hex)).uniq.length <= 6
              end
          end

          def show_other_players
            true
          end

          def active_entities
            if @finish_action
              [@finish_corporation.owner]
            else
              super
            end
          end

          def visible_corporations
            if @finish_action
              [@finish_corporation]
            else
              super
            end
          end
        end
      end
    end
  end
end
