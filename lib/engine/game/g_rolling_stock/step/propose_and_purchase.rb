# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module GRollingStock
      module Step
        class ProposeAndPurchase < Engine::Step::Base
          def actions(entity)
            return [] unless @round.entities.include?(entity)

            actions = []
            actions << 'offer' if can_offer_any?(entity)
            actions << 'respond' if can_respond_any?(entity)
            actions << 'pass' if can_pass?(entity)
            actions
          end

          def description
            'Propose, accept or reject acquisition offers'
          end

          def setup
            @round.entities.each do |player|
              if @game.corporations.none? { |corp| corp.owner == player }
                player.pass!
                @log << "#{player.name} controls no corporations and must pass"
              end
            end
          end

          def can_pass?(entity)
            !entity.passed?
          end

          # is there a company that a corporation run by this player can afford and isn't
          # currently in a offers?
          def can_offer_any?(entity)
            return unless can_pass?(entity)

            @game.corporations.any? do |corp|
              next unless corp.owner == entity

              @game.companies.any? do |c|
                next if @round.transacted_companies[c]
                next unless c.owner
                next if c.owner.corporation? && c.owner.companies.one?
                next if existing_offers?(corp, c)

                if c.owner == @game.foreign_investor
                  (corp.cash - @round.transacted_cash[corp]) >= c.max_price
                else
                  c.owner != corp && (corp.cash - @round.transacted_cash[corp]) >= c.min_price
                end
              end
            end
          end

          def can_offer?(entity, corporation, company)
            return unless entity
            return if @round.transacted_companies[company]
            return unless corporation&.owner
            return unless company.owner
            return if company.owner.corporation? && company.owner.companies.one?
            return if existing_offers?(corporation, company)

            if company.owner == @game.foreign_investor
              (corporation.cash - @round.transacted_cash[corporation]) >= company.max_price
            else
              company.owner != corporation && (corporation.cash - @round.transacted_cash[corporation]) >= company.min_price
            end
          end

          def can_respond_any?(entity)
            responder_in_any_offer?(entity)
          end

          def can_respond?(entity, offer)
            offer[:responder] == entity
          end

          def existing_offers?(corporation, company)
            @round.offers.any? { |prop| prop[:corporation] == corporation && prop[:company] == company }
          end

          def responder_in_any_offer?(entity)
            return false unless entity.player?

            @round.offers.any? { |prop| prop[:responder] == entity }
          end

          # toss any offers that can no longer complete. This can happen:
          # - if multiple offers are made for the same company
          # - if multiple offers are made by the same corporation without enough cash to cover all
          #
          # in certain right-of-refusal cases, the responder list may have to be filtered
          #
          def filter_offers!
            @round.offers.dup.each do |prop|
              company = prop[:company]
              corporation = prop[:corporation]
              price = prop[:price]
              responder_list = prop[:responder_list]
              if @round.transacted_companies[company] || (corporation.cash - @round.transacted_cash[corporation]) < price
                @round.offers.delete(prop)
              elsif responder_list
                # toss any right-of-refusal corps that can't afford the company
                # - this may trigger a purchase
                first = responder_list[0]
                responder_list.dup.each do |corp|
                  responder_list.delete(corp) if (corp.cash - @round.transacted_cash[corp]) < price
                end
                next_responder!(prop) if responder_list[0] != first
              end
            end
          end

          def process_pass(action)
            log_pass(action.entity)
            action.entity.pass!
          end

          def process_offer(action)
            proposer = action.entity
            corporation = action.corporation
            company = action.company
            price = action.price
            responder = company.owner.player? ? company.owner : company.owner.owner

            raise GameError, 'illegal offer' unless can_offer?(proposer, corporation, company)

            return foreign_propose(action) if company.owner == @game.foreign_investor
            return acquire_company(corporation, company, price) if responder == proposer

            offer = {
              proposer: proposer,
              corporation: corporation,
              company: company,
              price: price,
              responder: responder,
            }
            @round.offers << offer

            @log << "#{corporation.name} (#{proposer.name}) offers to purchase #{company.sym} from #{responder.name} "\
                    "for #{@game.format_currency(price)}"
          end

          # Offering to buy from FI requires asking all companies with higher share price first
          def foreign_propose(action)
            proposer = action.entity
            corporation = action.corporation
            company = action.company
            price = action.price

            responder_list = build_responder_list(proposer, corporation, price)

            raise GameError, "no possible responders for #{company.sym}" if responder_list.empty?
            return acquire_company(corporation, company, price) if responder_list[0].owner == proposer

            responder = responder_list[0].owner

            offer = {
              proposer: proposer,
              corporation: corporation,
              company: company,
              price: price,
              responder: responder,
              responder_list: responder_list,
            }
            @round.offers << offer

            @log << "#{corporation.name} (#{proposer.name}) proposes to purchase #{company.sym} from the Foreign Investor "\
                    "for #{@game.format_currency(price)}"
            @log << "#{responder_list[0].name} (#{responder.name}) has right of first refusal"
          end

          def build_responder_list(proposer, corporation, price)
            responder_list = @game.operating_order.reject(&:receivership?)
              .reject { |c| c.share_price.price < corporation.share_price.price || (c.cash - @round.transacted_cash[c]) < price }

            # ignore corporations owned by proposer at top of list except for the one wanting to buy
            responder_list.shift while proposer && responder_list[0].owner == proposer && responder_list.size > 1

            responder_list
          end

          def process_respond(action)
            responder = action.entity
            corporation = action.corporation
            company = action.company
            accept = action.accept
            offer = find_offer(corporation, company)
            raise GameError, "Unable to find offer for #{company.sym} by #{corporation.name}" unless offer
            raise GameError, 'Wrong responder to offer' if responder != offer[:responder]
            return foreign_respond(action, offer) if company.owner == @game.foreign_investor

            @round.offers.delete(offer)

            unless accept
              @log << "#{responder.name} rejects offer for #{company.sym} by #{corporation.name} (#{offer[:proposer].name})"
              return
            end

            @log << "#{responder.name} accepts offer for #{company.sym} by #{corporation.name} (#{offer[:proposer].name})"
            acquire_company(corporation, company, offer[:price])
          end

          def foreign_respond(action, offer)
            responder = action.entity
            original_corp = offer[:corporation]
            responder_list = offer[:responder_list]
            corporation = responder_list.shift
            proposer = offer[:proposer]
            company = action.company
            accept = action.accept

            if accept
              @round.offers.delete(offer)
              @log << "#{corporation.name} (#{responder.name}) preempts purchase of #{company.sym} by "\
                      "#{original_corp.name} (#{proposer&.name || 'Receivership'})"
              acquire_company(corporation, company, offer[:price])
            else
              @log << "#{corporation.name} (#{responder.name}) refuses right of purchase of #{company.sym}"

              next_responder!(offer)
            end
          end

          def next_responder!(offer)
            responder_list = offer[:responder_list]
            proposer = offer[:proposer]
            company = offer[:company]

            # ignore corporations owned by proposer at top of list except for the one wanting to buy
            responder_list.shift while proposer && responder_list[0]&.owner == proposer && responder_list.size > 1

            if responder_list[0]&.owner == proposer
              @round.offers.delete(offer)
              acquire_company(offer[:corporation], company, offer[:price])
            else
              offer[:responder] = responder_list[0].owner
              @log << "#{responder_list[0].name} (#{offer[:responder].name}) has next right of refusal"
            end
          end

          def find_offer(corporation, company)
            @round.offers.find { |p| p[:corporation] == corporation && p[:company] == company }
          end

          def acquire_company(corporation, company, price)
            raise GameError, "#{company.syn} is not available for acquisition" if @round.transacted_companies[company]
            if (corporation.cash - @round.transacted_cash[corporation]) < price
              raise GameError, "#{corporation.name} cannot afford #{@game.format_currency(price)} for #{company.syn}"
            end

            old_owner = company.owner
            corporation.spend(price, old_owner)
            old_owner.companies.delete(company)
            @round.transacted_cash[old_owner] += price

            company.owner = corporation
            corporation.companies << company
            @round.transacted_companies[company] = true

            rcvr = corporation.receivership? ? ' (Receivership)' : ''
            @log << "#{corporation.name}#{rcvr} acquires #{company.sym} from #{old_owner.name} "\
                    "for #{@game.format_currency(price)}"

            filter_offers!
          end

          def offers
            @round.offers
          end

          def player_corporations(player)
            @game.corporations.select { |c| c.owner == player }
          end

          def active_entities
            (@round.entities.reject(&:passed?) + @round.offers.map { |p| p[:responder] }).uniq
          end

          def active?
            true
          end

          def blocking?
            true
          end

          def fixed_price(company)
            company.owner == @game.foreign_investor && company.max_price
          end

          def offer_text(offer)
            if offer[:company].owner == @game.foreign_investor
              "Right of Refusal -> Purchase #{offer[:company].sym} (Foreign Investor) for "\
                "#{@game.format_currency(offer[:price])} by #{offer[:responder_list][0].name} (#{offer[:responder].name})"
            else
              "Offer: From #{offer[:proposer].name} -> purchase #{offer[:company].sym} (#{offer[:responder].name}) "\
                "for #{@game.format_currency(offer[:price])}"
            end
          end
        end
      end
    end
  end
end
