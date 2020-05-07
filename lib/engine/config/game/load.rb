# frozen_string_literal: true

module Engine
  module Config
    module Game
      module Load
        def load_phases(json)
          phases = JSON.parse(json, symbolize_names: true)
          phases.map do |phase|
            phase[:tiles] = phase[:tiles].map(&:to_sym)
          end
          phases.freeze
        end

        def load_companies(json)
          companies = JSON.parse(json, symbolize_names: true)
          companies.map do |company|
            company[:abilities] = (company[:abilities] || []).map do |ability|
              ability.transform_values do |value|
                value.respond_to?(:to_sym) ? value.to_sym : value
              end
            end
            company
          end
          companies.freeze
        end
      end
    end
  end
end
