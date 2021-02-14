# frozen_string_literal: true

require_relative '../buy_sell_par_shares'
require_relative 'par_and_buy_actions'

module Engine
  module Step
    module G1893
      FIRST_SR_ACTIONS = %w[buy_company pass].freeze

      class BuySellParSharesFirstSR < BuySellParShares
        def actions(entity)
          return [] unless entity&.player?

          result = super
          result.concat(FIRST_SR_ACTIONS) if can_buy_company?(entity)
          result
        end

        def can_buy_company?(_player, _company)
          bank_companies.any? && !sold? && !bought?
        end

        def can_buy?(_entity, bundle)
          super && @game.buyable?(bundle.corporation)
        end

        def can_sell?(_entity, _bundle)
          false
        end

        def can_gain?(_entity, bundle, exchange: false)
          return false if exchange

          super && @game.buyable?(bundle.corporation)
        end

        def can_exchange?(_entity)
          false
        end

        def process_buy_company(action)
          entity = action.entity
          company = action.company
          price = action.price

          super

          if bank_companies.one?
            @game.corporations.each do |c|
              next if @game.merged_corporation?(c)

              @game.remove_ability(c, :no_buy)
            end
          end

          @round.last_to_act = entity

          minor = @game.minor_by_id(company.id)
          return unless (minor = @game.minor_by_id(company.id))

          buy_minor(minor, entity, price)
        end

        include ParAndBuy

        private

        def buy_minor(minor, buyer, treasury)
          @game.log << "Minor #{minor.full_name} floats and receives "\
            "#{@game.format_currency(treasury)} in treasury"
          minor.owner = buyer
          minor.float!
          @game.bank.spend(treasury, minor)
        end

        def bank_companies
          @game.companies.select { |c| c.owner == @game.bank }
        end
      end
    end
  end
end
