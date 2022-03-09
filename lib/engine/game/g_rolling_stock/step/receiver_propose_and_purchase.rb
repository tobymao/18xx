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
            receiver_proposals.map { |p| p[:responder] }.uniq
          end

          def active?
            !receiver_proposals.empty?
          end

          def blocking?
            true
          end

          def round_state
            super.merge(
              {
                proposals: [],
                transacted_cash: Hash.new { |h, k| h[k] = 0 },
                transacted_companies: {},
              }
            )
          end

          def receiver_proposals
            @round.proposals.select { |p| p[:corporation].receivership? }
          end

          def setup
            add_next_receiver_proposal
          end

          def process_response(action)
            super

            add_next_receiver_proposal if receiver_proposals.empty?
          end

          def add_next_receiver_proposal
            while (prop = create_receiver_proposal)
              if prop[:responder_list].empty?
                acquire_company(prop[:corporation], prop[:company], prop[:price])
              else
                @round.proposals << prop
                @log << "#{prop[:corporation].name} (Receivership) proposes to purchase #{prop[:company].sym} from the "\
                        "Foreign Investor for #{@game.format_currency(prop[:price])}"
                @log << "#{prop[:responder_list][0].name} (#{prop[:responder].name}) has right of first refusal"

                break
              end
            end
          end

          def create_receiver_proposal
            receiver, company = elegible_receiver_and_company
            return unless receiver

            responder_list = build_responder_list(nil, receiver, company.max_price)

            {
              proposer: nil,
              corporation: receiver,
              company: company,
              price: company.max_price,
              responder: responder_list[0]&.owner,
              responder_list: responder_list,
            }
          end

          def elegible_receiver_and_company
            # FIXME: Overseas Trading power
            @game.operating_order.select(&:receivership?).each do |candidate|
              @game.foreign_investor.companies.sort_by(&:value).reverse_each do |company|
                return [candidate, company] if candidate.cash >= company.max_price
              end
            end
            [nil, nil]
          end
        end
      end
    end
  end
end
