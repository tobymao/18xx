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

        return PASS if blocks? &&
                       entity.corporation? &&
                       entity.abilities(time: 'owning_corp_or_turn', owner_type: 'corporation', strict_time: true).any?

        []
      end

      def can_buy_company?(entity)
        companies = @game.purchasable_companies(entity)

        entity == current_entity &&
          @game.phase.status.include?('can_buy_companies') &&
          companies.any? &&
          companies.map(&:min_price).min <= @game.buying_power(entity)
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

        @game.game_error("Cannot buy #{company.name} from #{owner.name}") if owner.is_a?(Corporation)

        min = company.min_price
        max = company.max_price
        unless price.between?(min, max)
          @game.game_error("Price must be between #{@game.format_currency(min)} and #{@game.format_currency(max)}")
        end

        log_later = []
        company.owner = entity
        owner.companies.delete(company)

        company.abilities(:assign_corporation) do |ability|
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

        company.remove_ability_when(:sold)

        @round.just_sold_company = company
        @round.company_seller = owner

        entity.companies << company
        entity.spend(price, owner)
        @log << "#{entity.name} buys #{company.name} from #{owner.name} for #{@game.format_currency(price)}"
        log_later.each { |l| @log << l }
      end

      def assignable_corporations(_company = nil)
        @game.corporations
      end

      def round_state
        { just_sold_company: nil, company_seller: nil }
      end

      def setup
        @blocks = @opts[:blocks] || false
      end
    end
  end
end
