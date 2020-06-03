# frozen_string_literal: true

require_relative 'base'

module Engine
  module Round
    class Draft < Base
      attr_reader :companies, :last_to_act

      def initialize(entities, game:)
        super

        @companies = game.companies.sort_by { @game.rand }
        @choices = Hash.new { |h, k| h[k] = [] }
        @draw_size = @entities.size + 2
        @last_to_act = nil
      end

      def pass_description
        'Pass (Buy)'
      end

      def available
        @companies.first(@draw_size)
      end

      def blank?(company)
        company.name.to_i.positive?
      end

      def all_blank?
        @companies.size < @draw_size && available.all? { |company| blank?(company) }
      end

      def only_one_company?
        @companies.one? && !blank?(@companies[0])
      end

      def name
        'Draft Round'
      end

      def description
        'Draft Companies'
      end

      def finished?
        all_blank? || @companies.empty?
      end

      def pass(_action)
        raise GameError, 'Cannot pass' unless only_one_company?

        company = @companies[0]
        old_value = company.min_bid
        company.discount += 10
        new_value = company.min_bid
        @log << "#{company.name} price decreases from #{@game.format_currency(old_value)} "\
          "to #{@game.format_currency(new_value)}"

        return if new_value.positive?

        @companies.clear
        @choices[@current_entity] << company
        @log << "#{@current_entity.name} chooses #{company.name}"
        @last_to_act = @current_entity
      end

      private

      def _process_action(action)
        case action
        when Action::Bid
          company = action.company
          @choices[@current_entity] << company

          discarded = available.sort_by { @game.rand }
          discarded.delete(company)

          @companies -= available
          @log << "#{@current_entity.name} chooses a company"
          @companies.concat(discarded)
          @last_to_act = @current_entity
        end
      end

      def action_finalized(_action)
        return unless finished?

        @choices.each do |player, companies|
          companies.each do |company|
            if blank?(company)
              @log << "#{player.name} chose #{company.name}"
            else
              company.owner = player
              player.companies << company
              price = company.min_bid
              player.spend(price, @game.bank) if price.positive?
              @log << "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"
            end
          end
        end
      end
    end
  end
end
