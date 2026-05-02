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

            @converting = nil
            @converted = nil
            @sold = false
          end

          def actions(entity)
            return corporation_actions(entity) if entity.corporation?
            return [] unless entity == current_entity
            return ['sell_shares'] if must_sell?(entity)

            # Conversion triggered: president may buy one treasury share then must pass
            if @converting
              actions = []
              ipo_bundle = @converting.ipo_shares.first&.to_bundle
              actions << 'buy_shares' if ipo_bundle && can_buy?(entity, ipo_bundle)
              actions << 'pass'
              return actions
            end

            actions = []
            actions << 'buy_shares' if can_buy_any?(entity)
            actions << 'par' if can_ipo_any?(entity) || can_float_minor?(entity)
            actions << 'buy_company' if !purchasable_companies(entity).empty? || !buyable_bank_owned_companies(entity).empty?
            actions << 'sell_shares' if can_sell_any?(entity)
            actions << 'convert' if can_convert_any?(entity)
            actions << 'pass' if !can_float_minor?(entity) && !actions.empty?
            actions
          end

          def corporation_actions(corporation)
            return [] unless can_convert?(corporation, current_entity)

            %w[convert pass]
          end

          def can_buy_any_from_ipo?(entity)
            return false unless @game.major_phase?

            super
          end

          def can_buy?(entity, bundle)
            return false if @converted && bundle.corporation != @converted

            # §9.3 pre-conversion optional buy: only valid while a conversion has been
            # triggered (@converting). Only the president may buy one treasury share;
            # the 50%-secondary holder cannot (they must complete conversion first).
            if @converting
              return false unless bundle.corporation == @converting
              return false unless bundle.owner == bundle.corporation
              return false unless @converting.president?(entity)
              return false if bought_corporation == @converting
            end

            super
          end

          def can_sell?(entity, bundle)
            return false unless bundle
            return false if bundle.corporation.type == :regional && bundle.presidents_share
            return false if bundle.corporation == @converted

            super
          end

          def can_float_minor?(entity)
            return false unless entity.player?

            !bought? && entity.companies.any? { |company| @game.company_becomes_minor?(company) }
          end

          def can_convert_any?(player)
            return false if @converting

            @game.corporations.any? { |corp| can_convert?(corp, player) }
          end

          def can_convert?(corporation, player)
            return false if @converting
            return false unless @game.major_phase?
            return false unless corporation.type == :regional
            return false if @sold
            return false if @converted
            return false if bought_corporation && bought_corporation != corporation

            unless corporation.president?(player)
              return false unless corporation.share_holders[player] >= 50
              return false if bought_corporation

              new_share_price = @game.stock_market.find_share_price(corporation, %i[right right up])
              return false unless @game.liquidity(player) >= new_share_price.price
            end

            true
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

            corporation.type = :major
            @game.stock_market.move_right(corporation)
            @game.stock_market.move_right(corporation)
            @game.stock_market.move_up(corporation)
            corporation.tokens.concat([40, 60, 60, 80, 80, 80].map { |price| Engine::Token.new(corporation, price: price) })
            @game.minor_regional_order -= [corporation]
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

          def process_sell_shares(action)
            super
            @sold = true
          end

          def process_convert(action)
            @converting = action.entity
            track_action(action, action.entity)
            @log << "#{current_entity.name} triggers conversion of #{action.entity.name}"
          end

          def process_par(action)
            if action.corporation.type == :minor
              float_minor(action)
            else
              super
              @game.regional_corps_floated += 1
            end

            @game.minor_regional_order << action.corporation

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

          def pass!
            if @converting
              complete_conversion
              raise GameError, "Must become president of newly floated major #{@converted&.name}" if
                @converted && !@converted.president?(current_entity)

              return
            end

            raise GameError, "Must become president of newly floated major #{@converted&.name}" if
              @converted && !@converted.president?(current_entity)

            super
          end

          def log_pass(entity)
            return if bought?

            @log << "#{entity.name} passes"
          end

          private

          def bought_corporation
            @round.current_actions.find { |x| x.is_a?(Action::BuyShares) }&.bundle&.corporation
          end

          def complete_conversion
            corporation = @converting
            float_major(corporation)
            @converted = corporation
            @converting = nil
            @log << "#{corporation.name} converts from regional to major"
            @log << "#{current_entity.name} must buy a share to become president of #{corporation.name}" unless
              corporation.president?(current_entity)
          end
        end
      end
    end
  end
end
