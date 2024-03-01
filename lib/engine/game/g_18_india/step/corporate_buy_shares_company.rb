# frozen_string_literal: true

require_relative '../../../step/corporate_buy_shares'
require_relative '../../../step/share_buying'
require_relative '../../../action/corporate_buy_shares'
require_relative '../../../action/corporate_buy_company'

module Engine
  module Game
    module G18India
      module Step
        class CorporateBuySharesCompany < Engine::Step::CorporateBuyShares
          include Engine::Step::ShareBuying

          PURCHASE_ACTIONS = [Action::CorporateBuyShares, Action::CorporateBuyCompany].freeze

          # for debugging only
          def setup
            entity = current_entity
            LOGGER.debug "G18India::Step::CorporateBuySharesCompany => Setup for #{entity.name}"
            LOGGER.debug "> num_certs: #{@game.num_certs(entity)} / cert_limit: #{@game.cert_limit(entity)}"
            LOGGER.debug "> corporations_bought: #{@round.corporations_bought[entity]}"
          end

          # for debugging only
          def debugging_log(str)
            LOGGER.debug(str)
            LOGGER.debug ">  Num Certs: #{@game.num_certs(current_entity)} / Cert Limit: #{@game.cert_limit(current_entity)}"
            LOGGER.debug ">  Bought?: #{bought?(current_entity)} - Last Bought: #{last_bought(current_entity).name} "
          end

          def description
            'Corporate Purchase Certificates from IPO or Market'
          end

          # TODO: Convert Royal Bond in Phase IV
          def actions(entity)
            return [] if entity.nil? || !entity&.corporation?
            return [] unless entity == current_entity

            # May buy any share from Market (it may may itself from Market) [working]
            # May buy Private Company from Market / Bank [working]
            # May buy Railroad Bond from Market / Bank (doesn't count against Cert Limit of 3) [working]
            # may buy One Proxy Cert from the IPO Row (but NOT itself) [working]
            # convert a Royal Bond to a share of GIPR (Phase IV && must have space) [TODO]
            actions = []
            actions << 'corporate_buy_company' if can_buy_any_companies?(entity)
            actions << 'corporate_buy_shares' if can_buy_any?(entity)
            actions << 'pass' if actions.any?

            actions
          end

          # ----- methods for buying companies (new) -----

          def can_buy_any_companies?(entity)
            return false if bought?(entity)

            buyable_companies(entity).count.positive?
          end

          def buyable_companies(entity)
            return [] unless entity.corporation?

            @game.bank_owned_companies.select { |c| can_buy_comp_from_market?(entity, c) } +
              @game.top_of_ipo_rows.select { |c| can_buy_comp_from_ipo?(entity, c) }
          end

          def can_buy_comp_from_market?(entity, company)
            return false if bought?(entity)
            return false if (@game.num_certs(entity) >= @game.cert_limit(entity)) && (company.type != :bond)

            entity.cash >= company.value
          end

          def can_buy_comp_from_ipo?(entity, company)
            return false if bought?(entity)
            return false if @game.num_certs(entity) >= @game.cert_limit(entity)
            return false if company.type == :share && (entity == company.treasury.corporation) # may NOT buy self from IPO

            _row, index = @game.ipo_row_and_index(company)
            index.zero? && (entity.cash >= company.value)
          end

          def can_buy_company?(entity, company)
            return false if entity.nil?
            return false if bought?(entity)
            return false if @game.bank_owned_companies.include?(company) && !can_buy_comp_from_market?(entity, company)
            return false if @game.in_ipo?(company) && !can_buy_comp_from_ipo?(entity, company)

            entity.cash >= company.value
          end

          def process_corporate_buy_company(action)
            entity = action.entity
            company = action.company
            price = action.price
            owner = company.owner
            what = company.type == :share ? "a share of #{company.name}" : "Private #{company.name}"

            raise GameError, "Cannot buy #{company.name} from #{owner.name}" if owner&.corporation? || owner&.player?

            if @game.in_ipo?(company)
              row, _index = @game.ipo_row_and_index(company)
              location = 'IPO Row: ' + (row + 1).to_s
              @game.ipo_remove(row, company)
            elsif owner == @game.bank
              location = 'the Bank'
              @game.bank.companies.delete(company)
            end
            @log << "#{current_entity.name} buys #{what} from #{location} for #{@game.format_currency(price)}"

            case company.type
            when :share
              share = company.treasury
              corp = share.corporation
              already_floated = corp.floated?
              # transfer share and send payment to corporation
              bundle = ShareBundle.new(share)
              @game.share_pool.transfer_shares(bundle, entity, spender: entity, receiver: corp, price: price)
              if corp.floatable && corp.floated? && (already_floated == false)
                @game.float_corporation(corp)
                maybe_place_home_token(corp)
              end
              @round.corporations_bought[entity] << corp
            when :private, :bond
              company.owner = entity
              entity.companies << company
              entity.spend(price, @game.bank)
              @round.corporations_bought[entity] << company
            end
            debugging_log('Process > Corporate Buy Company')
          end

          # ----- methods for buying shares -----

          # modified to only check market
          def can_buy_any?(entity)
            can_buy_any_from_market?(entity)
          end

          # modified to allow buying self from market
          def can_buy?(entity, bundle)
            return if bought?(entity)
            return unless bundle
            return unless bundle.buyable
            return unless bundle.corporation.ipoed
            return if bundle.presidents_share

            entity.cash >= bundle.price
          end

          def process_corporate_buy_shares(action)
            super
            debugging_log('Process > Corporate Buy Shares')
          end

          # modified to change restrictions and allow self
          def source_list(entity)
            @game.sorted_corporations.select do |corp|
              !corp.closed? &&
              !corp.num_market_shares.zero? &&
              can_buy_corp_from_market?(entity, corp)
            end
          end

          # Added for a hook in View::Game::Round::Operating
          def corporate_stock_round?
            true
          end
        end
      end
    end
  end
end
