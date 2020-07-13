# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class BuyCompany < Base
      ACTIONS = %w[buy_company pass].freeze
      ACTIONS_NO_PASS = %w[buy_company].freeze

      def actions(entity)
        return blocks? ? ACTIONS : ACTIONS_NO_PASS if can_buy_company?(entity)

        []
      end

      def can_buy_company?(entity)
        companies = @game.purchasable_companies

        entity == current_entity &&
          @game.phase.buy_companies &&
          companies.any? &&
          companies.map(&:min_price).min <= entity.cash
      end

      def blocks?
        @opts[:blocks]
      end

      def description
        'Buy Companies'
      end

      def pass_description
        'Pass (Companies)'
      end

      def sequential?
        true
      end

      def process_buy_company(action)
        entity = action.entity
        company = action.company
        price = action.price
        owner = company.owner

        raise GameError, "Cannot buy #{company.name} from #{owner.name}" if owner.is_a?(Corporation)

        min = company.min_price
        max = company.max_price
        unless price.between?(min, max)
          raise GameError, "Price must be between #{@game.format_currency(min)} and #{@game.format_currency(max)}"
        end

        log_later = []
        company.owner = entity
        owner.companies.delete(company)

        company.abilities(:assign_corporation) do |ability|
          Assignable.remove_from_all!(@game.corporations, company.id) do |unassigned|
            if unassigned.name != entity.name
              log_later << "#{company.name} is unassigned from #{unassigned.name}"
            end
          end
          entity.assign!(company.id)
          ability.use!
          log_later << "#{company.name} is assigned to #{entity.name}"
        end

        @round.just_sold_company = company

        entity.companies << company
        entity.spend(price, owner)
        @log << "#{entity.name} buys #{company.name} from #{owner.name} for #{@game.format_currency(price)}"
        log_later.each { |l| @log << l }
      end

      def round_state
        { just_sold_company: nil }
      end
    end
  end
end
