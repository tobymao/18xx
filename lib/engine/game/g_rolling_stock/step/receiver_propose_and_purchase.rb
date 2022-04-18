# frozen_string_literal: true

require_relative '../step/propose_and_purchase'

module Engine
  module Game
    module GRollingStock
      module Step
        class ReceiverProposeAndPurchase < GRollingStock::Step::ProposeAndPurchase
          def actions(entity)
            return [] unless @round.entities.include?(entity)
            return [] unless can_respond_any?(entity)

            ['respond']
          end

          def active_entities
            receiver_offers.map { |p| p[:responder] }.uniq
          end

          def active?
            !receiver_offers.empty?
          end

          def blocking?
            true
          end

          def round_state
            super.merge(
              {
                offers: [],
                transacted_cash: Hash.new { |h, k| h[k] = 0 },
                transacted_companies: {},
              }
            )
          end

          def receiver_offers
            @round.offers.select { |p| p[:corporation].receivership? }
          end

          def setup
            add_next_receiver_offer
          end

          def process_response(action)
            super

            add_next_receiver_offer if receiver_offers.empty?
          end

          def add_next_receiver_offer
            while (prop = create_receiver_offer)
              price = foreign_price(prop[:corporation], prop[:company])
              if prop[:responder_list].empty?
                acquire_company(prop[:corporation], prop[:company], price)
              else
                @round.offers << prop
                @log << "#{prop[:corporation].name} (Receivership) proposes to purchase #{prop[:company].sym} from the "\
                        "Foreign Investor for #{@game.format_currency(price)}"
                @log << "#{prop[:responder_list][0].name} (#{prop[:responder].name}) has right of first refusal"

                break
              end
            end
          end

          def create_receiver_offer
            receiver, company = elegible_receiver_and_company
            return unless receiver

            responder_list = build_responder_list(nil, receiver, company)
            raise GameError, "no possible responders for #{company.sym}" if responder_list.empty?

            price = foreign_price(receiver, company)
            if responder_list.one?
              # either receiver is OS, or receiver has highest share price of corps that can afford company
              raise GameError, 'Receiver not in responder_list' unless responder_list[0] == receiver

              acquire_company(receiver, company, price)
              return create_receiver_offer
            end

            {
              proposer: nil,
              corporation: receiver,
              company: company,
              responder: responder_list[0]&.owner,
              responder_list: responder_list,
            }
          end

          def elegible_receiver_and_company
            @game.operating_order.select(&:receivership?).each do |candidate|
              @game.foreign_investor.companies.sort_by(&:value).reverse_each do |company|
                return [candidate, company] if candidate.cash >= foreign_price(candidate, company)
              end
            end
            [nil, nil]
          end
        end
      end
    end
  end
end
