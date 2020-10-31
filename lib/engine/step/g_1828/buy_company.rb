# frozen_string_literal: true

require_relative '../../token'
require_relative '../buy_company'

module Engine
  module Step
    module G1828
      class BuyCompany < BuyCompany
        def process_buy_company(action)
          entity = action.entity
          company = action.company
          super

          return unless (minor = @game.minor_by_id(company.id))

          cash = minor.cash
          minor.spend(cash, entity) if cash.positive?
          minor.tokens[0].swap!(Engine::Token.new(entity))
          @log << "#{entity.name} receives #{@game.format_currency(cash)} "\
            "and may place a token on #{minor.coordinates} for free"
          @game.graph.clear_graph_for(minor)
          @game.remove_minor(minor)
        end
      end
    end
  end
end
