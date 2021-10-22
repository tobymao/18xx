# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares_companies'

module Engine
  module Game
    module G1860
      module Step
        class BuySellParSharesCompanies < Engine::Step::BuySellParSharesCompanies
          def actions(entity)
            return [] unless entity == current_entity
            return ['sell_shares'] if must_sell?(entity)

            actions = []
            actions << 'buy_shares' if can_buy_any?(entity)
            actions << 'par' if can_ipo_any?(entity)
            actions << 'buy_company' if can_buy_any_companies?(entity)
            actions << 'sell_shares' if can_sell_any?(entity)
            actions << 'sell_company' if can_sell_any_companies?(entity)

            actions << 'pass' if !actions.empty? || last_chance_to_exchange?(entity)
            actions
          end

          # special case: player just parred a company AND has the private that can
          # be exchanged for a share AND Fishbourne is available
          # This also needs to happen when a player buys any private and the Fishbourne is available
          def last_chance_to_exchange?(player)
            par_action = @round.current_actions.find { |x| x.is_a?(Action::Par) }
            company_buy_action = @round.current_actions.find { |x| x.is_a?(Action::BuyCompany) }
            return false if !par_action && !company_buy_action
            return false if company_buy_action && company_buy_action.company.sym == 'FFC'
            return true if company_buy_action && @game.phase.available?('6')

            return false unless par_action

            corp = par_action.corporation
            xchange_company = player.companies.find do |company|
              company.abilities.any? do |ability|
                ability.type == :exchange && ability.corporations.include?(corp.name)
              end
            end
            return false unless xchange_company

            @game.phase.available?('6')
          end

          def process_buy_shares(action)
            corporation = action.bundle.corporation
            floated = corporation.floated?

            super

            place_home_track(corporation) if corporation.floated? && !floated && !@game.sr_after_southern
            @game.check_new_layer
          end

          def process_sell_shares(action)
            super

            @game.check_bank_broken!
          end

          def process_buy_company(action)
            company = action.company

            super

            @game.close_other_companies!(company) if company.sym == 'FFC'
          end

          def process_sell_company(action)
            super

            @game.check_bank_broken!
          end

          def place_home_track(corporation)
            hex = @game.hex_by_id(corporation.coordinates)
            tile = hex.tile

            # skip if a tile is already in home location
            return unless tile.color == :white

            @log << "#{corporation.name} (#{corporation.owner.name}) must choose tile for home location"

            @round.pending_tracks << {
              entity: corporation,
              hexes: [hex],
            }

            @round.clear_cache!
          end
        end
      end
    end
  end
end
