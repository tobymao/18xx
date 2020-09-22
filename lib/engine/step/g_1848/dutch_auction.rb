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
          @companies = @game.companies.sort_by(&:min_bid)
          @cheapest = @companies.first
          @bidders = Hash.new { |h, k| h[k] = [] }
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

          actions = player.companies.empty? ? ACTIONS : ACTIONS_WITH_PASS
          
          entity == current_entity ? actions : []
        end
        
        #def bids #<FIXME> What is this?
        #  {}
        #end

      end
    end
  end
end
