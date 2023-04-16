# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative '../../../action/convert'

module Engine
  module Game
    module G18OE
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          PURCHASE_ACTIONS = (Engine::Step::BuySellParShares::PURCHASE_ACTIONS + [Engine::Action::Convert]).freeze

          def actions(entity)
            return corporation_actions(entity) if entity.corporation? #&& entity.owned_by?(current_entity)
            return [] unless entity == current_entity
            return ['sell_shares'] if must_sell?(entity)

            actions = []
            actions << 'buy_shares' if can_buy_any?(entity)
            actions << 'par' if can_ipo_any?(entity) || can_float_minor?(entity)
            actions << 'buy_company' if !purchasable_companies(entity).empty? || !buyable_bank_owned_companies(entity).empty?
            actions << 'sell_shares' if can_sell_any?(entity)

            actions << 'pass' if !can_float_minor?(entity) && !bought? && !actions.empty?
            actions
          end

          def corporation_actions(entity)
            return [] if bought? || !can_convert?(entity)

            %w[convert pass]
          end

          def can_buy_any_from_ipo?(entity)
            return unless @game.corporations.reject { |c| c.type == :minor }.all?(&:ipoed)

            super
          end

          def can_convert?(corporation)
            # puts(current_entity.shares.inspect)
            # puts(corporation.share_holders[current_entity]) if corporation.share_holders.include?(current_entity)
            corporation.total_shares == 4 && corporation.share_holders.include?(current_entity) && corporation.share_holders[current_entity] >= 50
          end

          def can_float_minor?(entity)
            return unless entity.player?

            !bought? && entity.companies.any? { |company| @game.company_becomes_minor?(company) }
          end

          def float_major(corporation)
            puts('float major')
            shares = @_shares.values.select { |share| share.corporation == corporation }

            if corporation.total_shares == 4
              shares.each { |share| share.percent = 10 }
              shares[0].percent = 20
              shares = 6.times.map { |i| Share.new(corporation, percent: 10, index: i + 3) }

              # Majors are affected by the stock market, set tokens in the correct place
              #corporation.always_market_price = true
              stock_market.move_right(corporation)
              stock_market.move_up(corporation)
              stock_market.move_up(corporation)
              # corporation.tokens needs to be added in
              corporation.tokens += [40, 60, 60, 80, 80, 80].map { |price| Token.new(corporation, price: price) }
              # Lastly, remove major from minor/regional turn order
              @minor_regional_order -= [corporation]
            else
              riase GameError, "Cannot convert a major corporation"
            end

            shares.each do |share|
              corporation.shares_by_corporation[corporation] << share
              @_shares[share.id] = share
            end
          end

          def float_minor(action)
            share_price = action.share_price
            corporation = action.corporation
            entity = action.entity
            company = find_minor_company(corporation)

            @log << "#{entity.name} floats #{company.sym}"
            @log << "Available track rights zones: #{@game.minor_available_regions}"

            @game.stock_market.set_par(corporation, share_price)
            share = corporation.ipo_shares.first
            @round.players_bought[entity][corporation] += share.percent
            buy_shares(entity, share.to_bundle, exchange: company, silent: true)
            company.close!
            track_action(action, action.corporation)
          end

          def find_minor_company(minor)
            @game.companies.find { |c| c.id == minor.id }
          end

          def ipo_type(entity)
            if entity.type == :minor && current_entity.companies.include?(find_minor_company(entity))
              :form
            elsif entity.type == :minor
              'Must have bought minor in auction phase'
            else
              :par
            end
          end

          def visible_corporations
            @game.sorted_corporations.reject { |c| (c.type == :minor && c.ipoed) }
          end

          def process_convert(action)
            corporation = action.entity
            float_major(corporation)
            track_action(action, action.corporation)
            @log << "#{corporation.name} converts from regional to major"
          end

          def process_par(action)
            if action.corporation.type == :minor
              float_minor(action)
            else
              super
              @game.regional_corps_floated += 1
            end

            # Add regional to the minor/regional operating order
            @game.minor_regional_order << action.corporation

            # Remove unfloated regional corporations once max number floated reached
            return unless @game.regional_corps_floated == @game.class::MAX_FLOATED_REGIONALS

            corps = @game.corporations.dup
            corps.each do |corp|
              next if corp.ipoed || corp.type == :minor

              @game.close_corporation(corp)
            end
          end

          def get_par_prices(entity, corp)
            return super unless corp.type == :minor

            @game.stock_market.par_prices
          end

          def check_legal_buy(entity, shares, exchange: nil, swap: nil, allow_president_change: true)
            raise GameError, "Cannot buy a share of #{shares&.corporation&.name}" if
              !can_buy?(entity, shares.to_bundle) && !swap && !exchange
          end
        end
      end
    end
  end
end
