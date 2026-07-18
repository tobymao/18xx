# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    # A privileged "god-move" used to build a preset game position without playing
    # through the normal steps. It is handled by Step::Setup, a non-blocking step
    # present in every round (see Round::Base::DEFAULT_STEPS), so its mutations are
    # applied directly and bypass the usual step legality checks. Being additive to
    # the action log, it replays deterministically like any other action.
    #
    # It carries any subset of directive fields; Step::Setup#process_setup applies
    # them in a fixed order. Empty directives are dropped from the serialized form.
    class Setup < Base
      attr_reader :cash, :phase, :shares, :par, :market, :trains, :tiles, :tokens, :companies, :loans, :advance

      # cash:      { entity_id => amount, ... }         corporations, players, or 'bank'
      # phase:     'name'                                          advance the game to this phase
      # par:       [ { 'corporation' => id, 'price' => n, 'president' => player_id }, ... ]
      # market:    [ { 'corporation' => id, 'coordinates' => [row, col] }, ... ]
      # shares:    [ { 'player' => id, 'corporation' => id, 'percent' => n }, ... ]
      # trains:    [ { 'corporation' => id, 'train' => name, 'phase_effects' => bool }, ... ]
      # tiles:     [ { 'hex' => id, 'tile' => name, 'rotation' => n }, ... ]
      # tokens:    [ { 'hex' => id, 'city' => idx, 'corporation' => id }, { 'corporation' => id, 'home' => true }, ... ]
      # companies: [ { 'company' => id, 'owner' => player_or_corp_id }, { 'company' => id, 'close' => true }, ... ]
      # loans:     [ { 'corporation' => id, 'count' => n }, ... ]     (loan-supporting games only)
      # advance:   { 'round' => 'stock'|'operating', 'turn' => n, 'round_num' => n, 'priority' => player_id }
      def initialize(entity, cash: {}, phase: nil, par: [], market: [], shares: [], trains: [],
                     tiles: [], tokens: [], companies: [], loans: [], advance: {})
        super(entity)
        @cash = cash
        @phase = phase
        @par = par
        @market = market
        @shares = shares
        @trains = trains
        @tiles = tiles
        @tokens = tokens
        @companies = companies
        @loans = loans
        @advance = advance
      end

      def self.h_to_args(h, _game)
        {
          cash: h['cash'] || {},
          phase: h['phase'],
          par: h['par'] || [],
          market: h['market'] || [],
          shares: h['shares'] || [],
          trains: h['trains'] || [],
          tiles: h['tiles'] || [],
          tokens: h['tokens'] || [],
          companies: h['companies'] || [],
          loans: h['loans'] || [],
          advance: h['advance'] || {},
        }
      end

      def args_to_h
        {
          'cash' => @cash,
          'phase' => @phase,
          'par' => @par,
          'market' => @market,
          'shares' => @shares,
          'trains' => @trains,
          'tiles' => @tiles,
          'tokens' => @tokens,
          'companies' => @companies,
          'loans' => @loans,
          'advance' => @advance,
        }.reject { |_, v| v.nil? || (v.respond_to?(:empty?) && v.empty?) }
      end

      def free?
        true
      end
    end
  end
end
