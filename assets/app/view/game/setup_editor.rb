# frozen_string_literal: true

require 'view/form'

module View
  module Game
    # A "god-move" editor for building preset positions. Each panel applies an
    # Engine::Action::Setup through the normal Actionable#process_action path;
    # because Setup#free? is true, edits are allowed regardless of whose turn it
    # is. Available for hotseat games (see game_page.rb menu gating).
    #
    # Tiles/tokens are offered here as simple hex-id forms; richer map-click
    # authoring is a separate follow-up.
    class SetupEditor < Form
      include Actionable

      needs :game, store: true
      needs :user, default: nil
      needs :flash_opts, default: {}, store: true

      SECTION = {
        style: {
          border: '1px solid gray',
          borderRadius: '5px',
          padding: '0.5rem 0.8rem',
          margin: '0.5rem 0',
        },
      }.freeze

      def render_content
        panels = [
          render_cash,
          render_par,
          render_market,
          render_shares,
          render_trains,
          render_phase,
          render_companies,
          render_tokens,
          render_tiles,
        ]
        panels << render_loans if @game.respond_to?(:take_loan)
        panels << render_advance

        h(:div, [
          h(:h2, 'Setup Editor'),
          h(:p, 'Apply god-move edits to build a preset position. Each edit is recorded as a ' \
                'setup action, so it survives export/import like any other move.'),
          *panels,
        ])
      end

      # --- panels ---------------------------------------------------------

      def render_cash
        entities = @game.corporations + @game.players
        options = entities.map { |e| option(e.id, "#{e.name} (#{@game.format_currency(e.cash)})") }
        options << option('bank', "Bank (#{@game.format_currency(@game.bank.cash)})")

        section('Set Cash', [
          render_input('Entity', id: :cash_entity, el: :select, children: options),
          render_input('Amount', id: :cash_amount, type: :number, attrs: { value: 0 }),
          render_button('Apply') { apply_cash },
        ])
      end

      def apply_cash
        v = params
        return unless present?(v['cash_entity'])

        dispatch(Engine::Action::Setup.new(actor, cash: { v['cash_entity'] => v['cash_amount'].to_i }))
      end

      def render_par
        section('Par Corporation', [
          render_input('Corporation', id: :par_corp, el: :select, children: corp_options(unipoed_corps)),
          render_input('Par Price', id: :par_price, el: :select, children: par_price_options),
          render_input('President', id: :par_president, el: :select, children: player_options),
          render_button('Par') { apply_par },
        ])
      end

      def apply_par
        v = params
        return unless present?(v['par_corp'], v['par_price'])

        dispatch(Engine::Action::Setup.new(actor, par: [{
                                             'corporation' => v['par_corp'],
                                             'price' => v['par_price'].to_i,
                                             'president' => v['par_president'].to_i,
                                           }]))
      end

      def render_market
        section('Move on Market', [
          render_input('Corporation', id: :mkt_corp, el: :select, children: corp_options(ipoed_corps)),
          render_input('Cell', id: :mkt_cell, el: :select, children: market_cell_options),
          render_button('Move') { apply_market },
        ])
      end

      def apply_market
        v = params
        return unless present?(v['mkt_corp'], v['mkt_cell'])

        row, col = v['mkt_cell'].split(',').map(&:to_i)
        dispatch(Engine::Action::Setup.new(actor, market: [{ 'corporation' => v['mkt_corp'], 'coordinates' => [row, col] }]))
      end

      def render_shares
        section('Grant Shares', [
          render_input('Player', id: :sh_player, el: :select, children: player_options),
          render_input('Corporation', id: :sh_corp, el: :select, children: corp_options),
          render_input('Percent', id: :sh_percent, type: :number, attrs: { value: 10, step: 10 }),
          render_button('Grant') { apply_shares },
        ])
      end

      def apply_shares
        v = params
        return unless present?(v['sh_player'], v['sh_corp'])

        dispatch(Engine::Action::Setup.new(actor, shares: [{
                                             'player' => v['sh_player'].to_i,
                                             'corporation' => v['sh_corp'],
                                             'percent' => v['sh_percent'].to_i,
                                           }]))
      end

      def render_trains
        train_names = @game.depot.upcoming.map(&:name).uniq
        section('Assign Train', [
          render_input('Corporation', id: :tr_corp, el: :select, children: corp_options),
          render_input('Train', id: :tr_train, el: :select, children: train_names.map { |n| option(n, n) }),
          render_button('Assign') { apply_trains },
        ])
      end

      def apply_trains
        v = params
        return unless present?(v['tr_corp'], v['tr_train'])

        dispatch(Engine::Action::Setup.new(actor, trains: [{ 'corporation' => v['tr_corp'], 'train' => v['tr_train'] }]))
      end

      def render_phase
        options = @game.phase.phases.map { |ph| option(ph[:name], "Phase #{ph[:name]}") }
        section('Advance Phase', [
          render_input('Phase', id: :ph_name, el: :select, children: options),
          render_button('Set Phase') { apply_phase },
        ])
      end

      def apply_phase
        v = params
        return unless present?(v['ph_name'])

        dispatch(Engine::Action::Setup.new(actor, phase: v['ph_name']))
      end

      def render_companies
        company_opts = @game.companies.reject(&:closed?).map { |c| option(c.id, c.name) }
        section('Private Companies', [
          render_input('Company', id: :co_company, el: :select, children: company_opts),
          render_input('Owner', id: :co_owner, el: :select, children: owner_options),
          render_button('Assign') { apply_company_assign },
          render_button('Close') { apply_company_close },
        ])
      end

      def apply_company_assign
        v = params
        return unless present?(v['co_company'], v['co_owner'])

        dispatch(Engine::Action::Setup.new(actor, companies: [{ 'company' => v['co_company'], 'owner' => v['co_owner'] }]))
      end

      def apply_company_close
        v = params
        return unless present?(v['co_company'])

        dispatch(Engine::Action::Setup.new(actor, companies: [{ 'company' => v['co_company'], 'close' => true }]))
      end

      def render_tokens
        section('Place Token', [
          render_input('Corporation', id: :tk_corp, el: :select, children: corp_options),
          render_input('Hex (for non-home)', id: :tk_hex, placeholder: 'e.g. H10'),
          render_input('City index', id: :tk_city, type: :number, attrs: { value: 0 }),
          render_button('Home Token') { apply_token_home },
          render_button('Place on Hex') { apply_token_hex },
        ])
      end

      def apply_token_home
        v = params
        return unless present?(v['tk_corp'])

        dispatch(Engine::Action::Setup.new(actor, tokens: [{ 'corporation' => v['tk_corp'], 'home' => true }]))
      end

      def apply_token_hex
        v = params
        return unless present?(v['tk_corp'], v['tk_hex'])

        dispatch(Engine::Action::Setup.new(actor, tokens: [{
                                             'corporation' => v['tk_corp'], 'hex' => v['tk_hex'], 'city' => v['tk_city'].to_i
                                           }]))
      end

      def render_tiles
        section('Lay Tile', [
          render_input('Hex', id: :ti_hex, placeholder: 'e.g. F8'),
          render_input('Tile name', id: :ti_tile, placeholder: 'e.g. 9'),
          render_input('Rotation', id: :ti_rot, type: :number, attrs: { value: 0, min: 0, max: 5 }),
          render_button('Lay') { apply_tiles },
        ])
      end

      def apply_tiles
        v = params
        return unless present?(v['ti_hex'], v['ti_tile'])

        dispatch(Engine::Action::Setup.new(actor, tiles: [{
                                             'hex' => v['ti_hex'], 'tile' => v['ti_tile'], 'rotation' => v['ti_rot'].to_i
                                           }]))
      end

      def render_loans
        section('Take Loans', [
          render_input('Corporation', id: :ln_corp, el: :select, children: corp_options(ipoed_corps)),
          render_input('Count', id: :ln_count, type: :number, attrs: { value: 1, min: 1 }),
          render_button('Take') { apply_loans },
        ])
      end

      def apply_loans
        v = params
        return unless present?(v['ln_corp'])

        dispatch(Engine::Action::Setup.new(actor, loans: [{ 'corporation' => v['ln_corp'], 'count' => v['ln_count'].to_i }]))
      end

      def render_advance
        round_opts = [option('stock', 'Stock Round'), option('operating', 'Operating Round')]
        section('Advance Round', [
          render_input('Round', id: :adv_round, el: :select, children: round_opts),
          render_input('Turn (optional)', id: :adv_turn, type: :number, placeholder: 'any'),
          render_input('OR # (optional)', id: :adv_ornum, type: :number, placeholder: 'any'),
          render_input('Priority', id: :adv_priority, el: :select, children: [option('', '—'), *player_options]),
          render_button('Advance') { apply_advance },
        ])
      end

      def apply_advance
        v = params
        adv = { 'round' => v['adv_round'] }
        adv['turn'] = v['adv_turn'].to_i if present?(v['adv_turn'])
        adv['round_num'] = v['adv_ornum'].to_i if present?(v['adv_ornum'])
        adv['priority'] = v['adv_priority'].to_i if present?(v['adv_priority'])
        dispatch(Engine::Action::Setup.new(actor, advance: adv))
      end

      # --- helpers --------------------------------------------------------

      def section(title, children)
        h(:div, SECTION, [h(:h3, title), h('div.setup_row', {
                                             style: {
                                               display: 'flex',
                                               flexWrap: 'wrap',
                                               gap: '0.5rem',
                                               alignItems: 'flex-end',
                                             },
                                           }, children)])
      end

      def option(value, label)
        h(:option, { attrs: { value: value } }, label)
      end

      def corp_options(corps = @game.corporations)
        corps.map { |c| option(c.id, c.name) }
      end

      def player_options
        @game.players.map { |p| option(p.id, p.name) }
      end

      def owner_options
        (@game.players + @game.corporations).map { |e| option(e.id, e.name) }
      end

      def par_price_options
        @game.stock_market.par_prices.map { |sp| option(sp.price, @game.format_currency(sp.price)) }
      end

      def market_cell_options
        cells = []
        @game.stock_market.market.each_with_index do |row, r|
          row.each_with_index do |cell, c|
            next unless cell

            cells << option("#{r},#{c}", "#{@game.format_currency(cell.price)} [#{r},#{c}]")
          end
        end
        cells
      end

      def unipoed_corps
        @game.corporations.reject(&:ipoed)
      end

      def ipoed_corps
        @game.corporations.select(&:ipoed)
      end

      # The setup action needs an entity; it is applied regardless of turn order.
      def actor
        @game.players.first || @game.corporations.first
      end

      def present?(*values)
        return true if values.all? { |v| v && !v.to_s.empty? }

        store(:flash_opts, 'Setup Editor: please fill in the fields for that edit.')
        false
      end

      def dispatch(action)
        process_action(action)
      end
    end
  end
end
