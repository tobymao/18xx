# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative 'minor_half_pay'

module Engine
  module Game
    module GSystem18
      module Step
        class Dividend < Engine::Step::Dividend
          DIVIDEND_TYPES = %i[payout half withhold].freeze
          SIMPLE_DIVIDEND_TYPES = %i[payout withhold].freeze
          include Engine::Step::HalfPay
          include GSystem18::Step::MinorHalfPay

          def share_price_change(entity, revenue = 0)
            return super if @game.share_price_change_for_dividend_as_full_cap_by_map?
            return super if entity.type == :minor

            price = entity.share_price.price
            LOGGER.debug { "price: #{price}, revenue: #{revenue}" }

            if revenue.zero?
              { share_direction: :left, share_times: 1 }
            elsif revenue >= 2 * price
              { share_direction: :right, share_times: 2 }
            elsif revenue >= price
              { share_direction: :right, share_times: 1 }
            else
              {}
            end
          end

          def pass!
            super
          end

          def dividend_types
            if @game.half_dividend_by_map?
              DIVIDEND_TYPES
            else
              SIMPLE_DIVIDEND_TYPES
            end
          end

          def process_dividend(action)
            super
            handle_warranties!(action.entity)
          end

          def handle_warranties!(entity)
            # remove one warranty from each train and see if it rusts
            entity.trains.dup.each do |train|
              train.name = train.name[0..-2] if train.name.include?('*')
              next if !@game.deferred_rust.include?(train) || train.name.include?('*')

              @log << "#{train.name} rusts after warranty expires"
              @game.deferred_rust.delete(train)
              @game.rust(train)
            end
          end
        end
      end
    end
  end
end
