# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1822PNW::Game do
  describe 165_580 do
    it 'does not include associated minors for majors that were started '\
       'directly as valid choices for P20' do
      game = fixture_at_action(926)

      actual = game.active_step.p20_targets
      expected = [game.corporation_by_id('1')]

      expect(actual).to eq(expected)
    end
  end

  describe '1822PNW_game_end_stock_market' do
    it ':stock market ending takes precedence, even when triggered after :bank ending was triggered' do
      game = fixture_at_action(1414)

      expect(game.finished).to eq(false)
      expect(game.bank.broken?).to eq(false)
      expect(game.stock_market.max_reached?).to be_nil
      expect(game.game_ending_description).to be_nil

      game.process_to_action(1415)
      expect(game.finished).to eq(false)
      expect(game.bank.broken?).to eq(true)
      expect(game.stock_market.max_reached?).to be_nil
      expect(game.game_ending_description).to eq('Bank Broken : Game Ends at conclusion of OR 10.2')

      game.process_to_action(1419)
      expect(game.finished).to eq(false)
      expect(game.bank.broken?).to eq(true)
      expect(game.stock_market.max_reached?).to eq(true)
      expect(game.game_ending_description).to eq('Company hit max stock value : Game Ends at conclusion of this OR (10.1)')

      game.process_to_action(1445)
      expect(game.finished).to eq(true)
      expect(game.bank.broken?).to eq(true)
      expect(game.stock_market.max_reached?).to eq(true)
      expect(game.game_ending_description).to eq('Company hit max stock value')
      expect(game.round.round_num).to eq(1)
    end
  end

  describe 'merger_high_value_minors' do
    it 'can only par at $100' do
      game = fixture_at_action(156)

      m6 = game.corporation_by_id('6')
      m18 = game.corporation_by_id('18')

      expect(m6.owner.value).to eq(1920)
      expect(game.active_step.valid_par_prices(m6, m18)).to eq([100])
    end

    it 'merging 6 and 18 will give the president 6 shares and all their cash' do
      game = fixture_at_action(158)

      m6 = game.corporation_by_id('6')
      m18 = game.corporation_by_id('18')
      ornc = game.corporation_by_id('ORNC')

      expect(m6.owner.value).to eq(1920)
      expect(game.active_step.choice_name).to eq('Choose number of shares to make up minors value of $670')
      expect(game.active_step.choices).to eq({ '6' => 'Player 1 receives 6 shares and $31' })
      expect(m6.cash).to eq(0)
      expect(m18.cash).to eq(0)
      expect(ornc.cash).to eq(31)
    end

    it 'president lost value after merge, the major has no cash left' do
      game = fixture_at_action(160)

      m6 = game.corporation_by_id('6')
      m18 = game.corporation_by_id('18')
      ornc = game.corporation_by_id('ORNC')

      expect(m6.closed?).to eq(true)
      expect(m18.closed?).to eq(true)
      expect(ornc.owner.value).to eq(1881)
      expect(ornc.cash).to eq(0)
    end
  end

  describe 'rockport_token' do
    it "does not provide connectivity when cut off from the owning Major's network" do
      game = fixture_at_action(989)

      gnr = game.corporation_by_id('GNR')
      rockport = game.company_by_id('P19')
      coal_hex = game.coal_token.hex

      expect(coal_hex.id).to eq('F17')
      expect(rockport.owner).to eq(gnr)
      expect(game.current_entity).to eq(gnr)
      expect(game.active_step).to be_a(Engine::Game::G1822PNW::Step::Track)

      expect(game).to have_available_hexes(%w[A22 B23 C22 C24 D19 D21 D23 E22 F21 F23])
    end

    it 'does not block the owning Major' do
      game = fixture_at_action(1091)

      gnr = game.corporation_by_id('GNR')
      rockport = game.company_by_id('P19')
      coal_hex = game.coal_token.hex

      expect(coal_hex.id).to eq('F17')
      expect(rockport.owner).to eq(gnr)
      expect(game.current_entity).to eq(gnr)
      expect(game.active_step).to be_a(Engine::Game::G1822PNW::Step::Track)

      expect(game).to have_available_hexes(%w[A10 A12 A14 A16 A22 A8 B17 B23 B7 B9 C10 C12
                                              C18 C22 C24 D11 D13 D19 D21 D23 E10 E2 E20 E22
                                              E8 F1 F15 F17 F19 F21 F23 F3 F5 F7 F9 G12 G14
                                              G16 G18 G2 G20 G22 G4 G6 G8 H11 H13 H19 H7 H9
                                              I10 I12 I14 I16 I8 J11 J13 J15 J7 J9 K10 K12
                                              K6 L13 L19 L3 L5 M12 M14 M18 M2 M4 M6 N15 N19
                                              N5 N7 N9 O10 O12 O14 O16 O18 O20 O4 O6 O8 P11
                                              P13 P15 P17 P19 P5 P7 P9])
    end

    it 'does not count as a token for E-train' do
      game = fixture_at_action(1092)

      gnr = game.corporation_by_id('GNR')
      rockport = game.company_by_id('P19')
      coal_hex = game.coal_token.hex

      expect(gnr.tokens[1].hex.id).to eq('F23')
      expect(coal_hex.id).to eq('F17')
      expect(rockport.owner).to eq(gnr)
      expect(game.current_entity).to eq(gnr)
      expect(game.active_step).to be_a(Engine::Game::G1822::Step::Route)

      action = Engine::Action::RunRoutes.action_from_h(
        {
          'type' => 'run_routes',
          'entity' => 'GNR',
          'entity_type' => 'corporation',
          'routes' => [{
            'train' => '7-2',
            'connections' => [%w[F17 F19 F21 F23]],
            'hexes' => %w[F23 F17],
            'revenue' => 160,
            'revenue_str' => 'F23-F17',
            'nodes' => %w[F17-0 F23-0],
          }],
        },
        game
      )
      route = action.routes.first

      expect do
        game.check_distance(route, route.stops)
      end.to raise_error(Engine::GameError, 'E-train route must have at least 2 tokened cities')
    end
  end

  describe 'mill_ski_coal' do
    it 'does not allow mill or ski companies to use the coal hex' do
      # https://boardgamegeek.com/thread/3533826/article/46291488#46291488
      game = fixture_at_action(592)

      mill = game.company_by_id('P15')
      ski = game.company_by_id('P17')
      coal_hex = game.hex_by_id('J17')

      # coal tile is on the hex
      expect(coal_hex.tile.name).to eq('PNW4')

      assign_step = game.round.step_for(mill, 'assign')
      expect(assign_step.available_hex_mill(mill, coal_hex)).to eq(false)
      expect(assign_step.available_hex_ski(ski, coal_hex)).to eq(false)
    end
  end

  describe '179700' do
    context '17 closes' do
      it 'its home is not reserved by SPS' do
        game = fixture_at_action(967)

        m17 = game.corporation_by_id('17')
        sps = game.corporation_by_id('SPS')
        portland = game.hex_by_id('O8').tile.cities[0]

        expect(sps.tokens.count(&:used)).to eq(0)
        expect(portland.available_slots).to eq(0)
        expect(portland.reserved_by?(m17)).to eq(true)
        expect(portland.reserved_by?(sps)).to eq(false)
        expect(m17.closed?).to eq(false)

        # finish the SR, closing 17 from bidbox 1
        game.process_to_action(968)

        expect(sps.tokens.count(&:used)).to eq(0)
        expect(portland.available_slots).to eq(1)
        expect(portland.reserved_by?(m17)).to eq(false)
        expect(portland.reserved_by?(sps)).to eq(false)
        expect(m17.closed?).to eq(true)
      end

      it 'when SPS starts with a full home city, its token goes into an extra slot' do
        game = fixture_at_action(1301)

        gnr = game.corporation_by_id('GNR')
        sps = game.corporation_by_id('SPS')
        portland = game.hex_by_id('O8').tile.cities[0]

        expect(game.current_entity).to eq(gnr)
        expect(portland.available_slots).to eq(0)
        expect(portland.slots(all: true)).to eq(4)
        expect(portland.tokened_by?(sps)).to eq(false)

        game.process_to_action(1302)

        expect(game.current_entity).to eq(sps)
        expect(portland.available_slots).to eq(0)
        expect(portland.slots(all: true)).to eq(5)
        expect(portland.tokened_by?(sps)).to eq(true)
      end
    end
  end
end
