# frozen_string_literal: true

require_relative '../../corporation'
# require 'pry-byebug'
module Engine
  module Game
    module G1854
      class Corporation < Engine::Corporation
        def initialize(**opts)
          @shares_split = false
          super
        end

        def shares_split?
          @shares_split
        end

        def split_shares
          @shares_split = true

          # puts "====="
          # puts share_holders
          # share_holders.each do |s_holder,_|
          #   puts s_holder
          #   puts s_holder.shares
          #   puts "------"
          #   s_holder.shares.each do |share|
          #     if share.corporation == self
          #       share.percent = share.percent/2
          #       dup_share = share.dup
          #       # TODO: index
          #       # dup_share.index += 4
          #       s_holder.shares_by_corporation[self] << dup_share
          #     end
          #   end
          #   puts s_holder.shares
          #   puts "------"
          # end
          # puts share_holders
        end
      end
    end
  end
end
