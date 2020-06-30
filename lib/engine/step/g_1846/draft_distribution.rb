# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G1846
      class DraftDistribution < Base
        attr_reader :companies

        ACTIONS = %w[bid].freeze
        ACTIONS_WITH_PASS = %w[bid pass].freeze

        def setup
          @companies = @game.companies.sort_by { @game.rand }
          @choices = Hash.new { |h, k| h[k] = [] }
          @draw_size = entities.size + 2
        end

        def pass_description
          'Pass (Buy)'
        end

        def available
          @companies.first(@draw_size)
        end

        def blank?(company)
          company.name.include?('Pass')
        end

        def all_blank?
          @companies.size < @draw_size && available.all? { |company| blank?(company) }
        end

        def only_one_company?
          @companies.one? && !blank?(@companies[0])
        end

        def visible?
          only_one_company?
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

        def actions(entity)
          return [] if finished?

          actions = only_one_company? ? ACTIONS_WITH_PASS : ACTIONS

          entity == current_entity ? actions : []
        end

        def process_pass(action)
          raise GameError, 'Cannot pass' unless only_one_company?

          company = @companies[0]
          old_value = company.min_bid
          company.discount += 10
          new_value = company.min_bid
          @log << "#{company.name} price decreases from #{@game.format_currency(old_value)} "\
            "to #{@game.format_currency(new_value)}"

          @round.next_index!
          return if new_value.positive?

          @companies.clear
          @choices[action.entity] << company
          @log << "#{action.entity.name} chooses #{company.name}"
          action_finalized
        end

        def process_bid(action)
          company = action.company
          @choices[action.entity] << company

          discarded = available.sort_by { @game.rand }
          discarded.delete(company)

          @companies -= available
          @log << "#{action.entity.name} chooses a company"
          @companies.concat(discarded)
          @round.next_index!
          action_finalized
        end

        def action_finalized
          return unless finished?

          @round.reset_index!

          @choices.each do |player, companies|
            companies.each do |company|
              if blank?(company)
                @log << "#{player.name} chose #{company.name}"
              else
                company.owner = player
                player.companies << company
                price = company.min_bid
                player.spend(price, @game.bank) if price.positive?

                float_minor(company)

                @log << "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"
              end
            end
          end
        end

        def float_minor(company)
          player = company.player
          michigan_southern = @game.michigan_southern
          big4 = @game.big4

          minor =
            case company.name
            when michigan_southern.full_name
              michigan_southern.owner = player
              michigan_southern
            when big4.full_name
              big4.owner = player
              big4
            end

          @game.bank.spend(company.value, minor) if minor
        end
      end
    end
  end
end
