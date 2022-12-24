# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1858
      module Round
        class Closure < Engine::Round::Operating
          def setup
            @game.private_closure_round = :in_progress
            # Close unsold privates and the H&G.
            @game.companies.each do |company|
              next if (company.sym != 'H&G') && (company.owner != @game.bank)

              @game.close_private(company)
            end
            super
          end

          def self.round_name
            'Private Closure Round'
          end

          def self.short_name
            'PCR'
          end

          def description
            'Private Closure Round'
          end

          def select_entities
            @game.minors.reject(&:closed?)
          end

          def next_entity!
            return unless pending_tokens.empty?

            super
          end

          def any_to_act?
            super || !pending_tokens.empty?
          end
        end
      end
    end
  end
end
