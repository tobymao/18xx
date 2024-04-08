# frozen_string_literal: true

require_relative '../../depot'

module Engine
  module Game
    module G1854
      class Depot < Engine::Depot
        def available_upcoming_trains
          available = super
          available.reject! { |t| t.name == '3+' } if @upcoming.any? { |t| t.name == '2+' }
          available.reject! { |t| t.name == '2+' } if @upcoming.any? { |t| t.name == '1+' }
          available
        end
      end
    end
  end
end
