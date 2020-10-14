# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G1846
      class DraftDistribution < Base
        attr_reader :companies, :choices

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

        def may_purchase?(_company)
          false
        end

        def may_choose?(_company)
          true
        end

        def auctioning; end

        def bids
          {}
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

        def players_visible?
          false
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

        def process_pass(_action)
          @game.game_error('Cannot pass') unless only_one_company?

          company = @companies[0]
          old_price = company.min_bid
          company.discount += 10
          new_price = company.min_bid
          @log << "#{company.name} price decreases from #{@game.format_currency(old_price)} "\
            "to #{@game.format_currency(new_price)}"

          @round.next_entity_index!

          return unless new_price == company.min_auction_price

          choose_company(current_entity, company)
          action_finalized
        end

        def process_bid(action)
          choose_company(action.entity, action.company)
          @round.next_entity_index!
          action_finalized
        end

        def choose_company(player, company)
          available_companies = available

          raise @game.game_error "Cannot choose #{company.name}" unless available_companies.include?(company)

          @choices[player] << company

          if only_one_company?
            @log << "#{player.name} chooses #{company.name}"
            @companies.clear
          else
            @log << "#{player.name} chooses a company"
            @companies -= available_companies
            discarded = available_companies.sort_by { @game.rand }
            discarded.delete(company)
            @companies.concat(discarded)
          end

          company.owner = player
        end

        def action_finalized
          return unless finished?

          @round.reset_entity_index!

          @choices.each do |player, companies|
            companies.each do |company|
              if blank?(company)
                company.owner = nil
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
          return unless (minor = @game.minors.find { |m| m.id == company.id })

          minor.owner = company.player
          @game.bank.spend(company.treasury, minor)
          minor.float!
        end

        def committed_cash(player, show_hidden = false)
          return 0 unless show_hidden

          choices[player].sum(&:min_bid)
        end
      end
    end
  end
end
