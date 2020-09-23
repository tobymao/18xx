# frozen_string_literal: true

require_relative '../base'
require_relative '../auctioner'

module Engine
  module Step
    module G1848
      class DutchAuction < Base
        include Auctioner
        
        attr_reader :companies

        ACTIONS = %w[bid lower].freeze
        ACTIONS_WITH_PASS = %w[bid lower pass].freeze

        def description
          'Buy Companies'
        end
        
        def setup
          setup_auction
          @companies = @game.companies.sort_by(&:min_bid)
          @cheapest = @companies.first
          #@choices = Hash.new { |h, k| h[k] = [] } <FIXME> delete?
          #@bidders = Hash.new { |h, k| h[k] = [] } <FIXME> delete?
        end

        def committed_cash(_player, _show_hidden = false)
          0
        end
        
        def pass_description
          'Pass (Buy)'
        end

        def min_bid(company)
          puts "company = #{company}"
          return unless company
          puts "company.value = #{company.value}"
          puts "company.discount = #{company.discount}"
          return company.value-company.discount if may_purchase?(company)
        end

        def process_bid(action)
          company = action.company
          price = company.min_bid
          buy_company(current_entity, company, price)
          @round.next_entity_index! #not sure about this
        end

        def process_lower(action)
          company = action.company
          company.discount -= 5;
          @round.next_entity_index! #not sure about this
        end        

        def available
          @companies
        end

        def may_purchase?(_company)
          true
        end

        def auctioning; end

        def actions(entity)
          return [] if @companies.empty?
          return [] unless entity.player?

          actions = entity.player.companies.empty? ? ACTIONS : ACTIONS_WITH_PASS
          
          entity == current_entity ? actions : []
        end

        def buy_company(player, company, price)
          company.owner = player
          player.companies << company
          player.spend(price, @game.bank) if price.positive?
          @companies.delete(company)
          @log << "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"

          company.abilities(:share) do |ability|
            share = ability.share

            if share.president
              @round.company_pending_par = company
            else
              @game.share_pool.buy_shares(player, share, exchange: :free)
            end
          end
        end

        def bids
          {}
        end
                
      end
    end
  end
end
