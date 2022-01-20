# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1866
      module Step
        class Convert < Engine::Step::Base
          ACTIONS = %w[choose pass].freeze

          def actions(entity)
            if entity != current_entity || !@game.public_corporation?(entity) || !@game.convert_public_corporation? ||
              entity.type != :public_5
              return []
            end

            ACTIONS
          end

          def choice_name
            "Convert #{current_entity.id} from 5 share to 10 share company"
          end

          def choices
            entity = current_entity
            player = current_entity.owner
            price = entity.share_price.price
            share_count = player.num_shares_of(entity)

            choices = {}
            choices['0'] = 'Convert without buying any shares'
            (6 - share_count).times.each do |i|
              index = i + 1
              if player.cash >= (price * index) && (@game.num_certs(player) + index) <= @game.cert_limit
                choices[index.to_s] = "Convert and buy #{index} share (#{@game.format_currency(price * index)})"
              end
            end
            choices
          end

          def description
            'Convert'
          end

          def process_choose(action)
            entity = action.entity
            player = entity.owner
            choice = action.choice.to_i

            # Find all the orginal shares
            original_shares = []
            entity.share_holders.each { |c, _| original_shares.concat(c.shares_of(entity)) }
            original_shares.sort_by!(&:index)

            entity.share_holders.clear
            original_shares.each_with_index do |share, idx|
              share.percent = idx.zero? ? 20 : 10
              entity.share_holders[share.owner] += share.percent
            end

            # Create 5 new shares
            shares = Array.new(5) { |i| Share.new(entity, percent: 10, index: i + 4) }
            shares.each do |share|
              entity.share_holders[entity] += share.percent
              entity.shares_by_corporation[entity] << share
            end
            entity.type = :public_10

            # Buy the shares
            @log << "#{entity.name} converts to a 10-share company"
            choice.times do
              share = entity.treasury_shares.first
              @game.share_pool.buy_shares(player, share.to_bundle)
            end

            pass!
          end

          def skip!
            pass!
          end
        end
      end
    end
  end
end
