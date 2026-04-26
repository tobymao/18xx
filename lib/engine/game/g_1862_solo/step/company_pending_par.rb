# frozen_string_literal: true

require_relative '../../../step/company_pending_par'

module Engine
  module Game
    module G1862Solo
      module Step
        class CompanyPendingPar < Engine::Step::CompanyPendingPar
          def description
            type = @round.chartered_par ? 'Chartered' : 'Unchartered'
            "Choose #{type} Corporation Par Value"
          end

          def entities
            [@game.players.first]
          end

          def active_entities
            [@game.players.first]
          end

          def current_entity
            @game.players.first
          end

          def get_par_prices(_entity, _corp)
            @round.chartered_par ? @game.chartered_par_prices : @game.uncharted_par_prices
          end

          def companies_pending_par
            @round.companies_pending_par
          end

          def process_par(action)
            share_price = action.share_price
            corporation = action.corporation

            company = companies_pending_par.first
            type = @round.chartered_par ? 'chartered' : 'unchartered'
            @log << "#{corporation.name} pars #{type} at #{share_price.price}"

            corporation.ipoed = true
            @game.par_corporation(corporation, share_price)
            @game.share_pool.buy_shares(action.entity, ShareBundle.new([company.treasury]), allow_president_change: false)
            @game.after_par(corporation)

            @game.remove_corporation(@game.random_corporation, 'due to unchartered par') unless @round.chartered_par

            companies_pending_par.shift
          end
        end
      end
    end
  end
end
