# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class BuyCompany < Base
      ACTIONS = %w[buy_company pass].freeze
      ACTIONS_NO_PASS = %w[buy_company].freeze
      PASS = %w[pass].freeze

      def actions(entity)
        # 1846 and a few others minors can't buy companies
        return [] if entity.minor?
        return blocks? ? ACTIONS : ACTIONS_NO_PASS if can_buy_company?(entity)

        return PASS if blocks? && entity.corporation? && @game.abilities(entity, passive_ok: false)

        []
      end

      def can_buy_company?(entity)
        companies = @game.purchasable_companies(entity)

        entity == current_entity &&
          @game.phase.status.include?('can_buy_companies') &&
          companies.any? &&
          companies.map(&:min_price).min <= buying_power(entity)
      end

      def blocks?
        @opts[:blocks]
      end

      def description
        'Buy Companies'
      end

      def pass_description
        @acted ? 'Done (Companies)' : 'Skip (Companies)'
      end

      def process_buy_company(action)
        entity = action.entity
        company = action.company
        price = action.price
        owner = company.owner

        buy_company(entity, company, price, owner)
      end

      def buy_company(entity, company, price, owner)
        raise GameError, "Cannot buy #{company.name} from #{owner.name}" unless @game.company_sellable(company)

        min = company.min_price
        max = company.max_price(entity)
        unless price.between?(min, max)
          raise GameError, "Price must be between #{@game.format_currency(min)} and #{@game.format_currency(max)}"
        end

        log_later = []
        company.owner = entity
        owner&.companies&.delete(company)

        @game.abilities(company, :assign_corporation, time: 'sold') do |ability|
          Assignable.remove_from_all!(assignable_corporations, company.id) do |unassigned|
            log_later << "#{company.name} is unassigned from #{unassigned.name}" if unassigned.name != entity.name
          end
          entity.assign!(company.id)
          ability.use!
          log_later << "#{company.name} is assigned to #{entity.name}"

          log_later <<
            if (assigned_hex = @game.hexes.find { |h| h.assigned?(company.id) })
              "#{company.name} is still assigned to #{assigned_hex.name}"
            else
              "#{company.name} is not assigned to a hex"
            end
        end

        @game.abilities(company, :revenue_change, time: 'sold') { |ability| company.revenue = ability.revenue }

        company.remove_ability_when(:sold)

        @round.just_sold_company = company
        @round.company_sellers[company] = owner

        entity.companies << company
        pay(entity, owner, price, company)

        log_later.each { |l| @log << l }
        @game.after_sell_company(entity, company, price, owner)
      end

      def assignable_corporations(_company = nil)
        @game.corporations
      end

      def round_state
        { just_sold_company: nil, company_sellers: {} }
      end

      def setup
        @blocks = @opts[:blocks] || false
      end

      def pay(entity, owner, price, company)
        entity.spend(price, owner || @game.bank)

        @game.company_bought(company, entity)

        @log << "#{entity.name} buys #{company.name} from "\
                "#{owner.nil? ? 'the market' : owner.name} for "\
                "#{@game.format_currency(price)}"
      end
    end
  end
end
