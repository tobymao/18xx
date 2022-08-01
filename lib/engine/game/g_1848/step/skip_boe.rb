# frozen_string_literal: true

require_relative '../../../step/buy_company'

module Engine
  module Game
    module G1848
      module SkipBoe
        def actions(entity)
          return [] if @game.boe == entity

          super
        end
      end
    end
  end
end
