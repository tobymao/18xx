# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative '../../../action/convert'

module Engine
  module Game
    module G18OE
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def setup
            super

            @can_convert = []
            @game.corporations.each do |corp|
              if corp.share_holders[current_entity] >= 50 && corp.type == :regional && @game.corporations.all?(&:ipoed)
                @can_convert << corp
              end
            end
          end

          def actions(entity)
            return corporation_actions(entity) if entity.corporation?
            return [] unless entity == current_entity
            return ['sell_shares'] if must_sell?(entity)

            actions = []
            actions << 'buy_shares' if can_buy_any?(entity)
            actions << 'par' if can_ipo_any?(entity) || can_float_minor?(entity)
            actions << 'buy_company' if !purchasable_companies(entity).empty? || !buyable_bank_owned_companies(entity).empty?
            actions << 'sell_shares' if can_sell_any?(entity)
            actions << 'convert' unless @can_convert.empty?
            actions << 'pass' if !can_float_minor?(entity) && !actions.empty?
            actions
          end

          def corporation_actions(entity)
            return [] unless @can_convert.include?(entity)

            %w[convert pass]
          end

          def can_buy_any_from_ipo?(entity)
            return unless @game.corporations.all?(&:ipoed)

            super
          end

          def can_buy?(entity, bundle)
            action = @round.current_actions.find { |a| a.is_a?(Engine::Action::Convert) }
            return false if action && action&.entity != bundle.corporation

            super
          end

          def can_sell?(entity, bundle)
            return unless bundle
            return if bundle.corporation.type == :regional

            super
          end

          def can_float_minor?(entity)
            return unless entity.player?

            !bought? && entity.companies.any? { |company| @game.company_becomes_minor?(company) }
          end

          def float_major(corporation)
            shares = corporation.share_holders.keys.flat_map { |share| share.shares_of(corporation) }

            shares.each { |share| share.percent = share.president ? 20 : 10 }
            6.times do |index|
              share = Share.new(corporation, owner: corporation.ipo_owner, percent: 10, index: 4 + index)
              corporation.ipo_owner.shares_by_corporation[corporation] << share
            end
            corporation.share_holders.keys do |sh|
              corporation.share_holders[sh] = sh.shares_by_corporation[corporation].sum(&:percent)
            end

            # Set corporation type to :major
            corporation.type = 'major'

            # Majors are affected by the stock market, set tokens in the correct place
            @game.stock_market.move_right(corporation)
            @game.stock_market.move_right(corporation)
            @game.stock_market.move_up(corporation)
            corporation.tokens.concat([40, 60, 60, 80, 80, 80].map { |price| Engine::Token.new(corporation, price: price) })
            # Lastly, remove major from minor/regional turn order
            @game.minor_regional_order -= [corporation]
            # Also update the cache so reload works
            @game.update_cache(:shares)
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

          def process_buy_shares(action)
            super
            corp = action.bundle.corporation
            @can_convert = if @can_convert.find { |c| c == corp }
                             [corp]
                           else
                             []
                           end
          end

          def process_sell_shares(action)
            super
            @can_convert = []
          end

          def process_convert(action)
            corporation = action.entity
            float_major(corporation)
            track_action(action, corporation)
            @can_convert = []
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

            pass!
          end

          def get_par_prices(entity, corp)
            return super unless corp.type == :minor

            @game.stock_market.par_prices
          end

          def check_legal_buy(entity, shares, exchange: nil, swap: nil, allow_president_change: true)
            raise GameError, "Cannot buy a share of #{shares&.corporation&.name}" if
              !can_buy?(entity, shares.to_bundle) && !swap && !exchange
          end

          def log_pass(entity)
            return if bought?

            @log << "#{entity.name} passes"
          end
        end
      end
    end
  end
end
