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
          puts "got to description"
          'Buy Companies'
        end
        
        def setup
          setup_auction
          @companies = @game.companies.sort_by(&:min_bid)
          @cheapest = @companies.first
          @bidders = Hash.new { |h, k| h[k] = [] }
        end

        def committed_cash(_player, _show_hidden = false)
          0
        end
        
        def pass_description
          'Pass (Buy)'
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
        
        #def bids #<FIXME> What is this?
        #  {}
        #end

      end
    end
  end
end
