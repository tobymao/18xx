# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE Concession RR Phase (§8, §8.1)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let!(:a) { game.players[0] }
  let!(:b) { game.players[1] }
  let!(:c) { game.players[2] }

  def concession_round!(holders)
    holders.each_with_index do |holder, index|
      fund!(game, holder)
      give_company!(holder, game.company_by_id("CON#{index + 1}"))
    end
    game.concessions.reject(&:owner).each(&:close!)
    enter_round!(game, game.new_concession_round)
  end

  def float_regional!(round, id, par: 60)
    player = round.current_entity
    act!(game, Engine::Action::Par.new(player, corporation: game.corporation_by_id(id), share_price: cell(game, par, :par)))
  end

  def float_minor!(round, id)
    player = round.current_entity
    minor = game.corporation_by_id(id)
    give_company!(player, game.company_by_id(id))
    fund!(game, minor, 120)
    price = round.active_step.get_par_prices(player, minor).first
    act!(game, Engine::Action::Par.new(player, corporation: minor, share_price: price))
    minor
  end

  def place_home!(minor)
    city = game.home_token_locations(minor).first.tile.cities.first
    act!(game, Engine::Action::PlaceToken.new(minor, city: city, slot: 0))
  end

  it 'starts the Concession RR Phase once the opening packet is sold (§8)' do
    round = concession_round!([b])

    expect(round).to be_a(Engine::Round::G18OE::Concession)
    expect(round.name).to eq('Concession Round')
  end

  it 'starts with the holder of the 1st concession (§8)' do
    round = concession_round!([c, a, b])

    expect(round.current_entity).to eq(c)
    expect(round.current_concession).to eq(game.company_by_id('CON1'))
  end

  it 'executes the concessions in order, letting one player act twice (§8.1)' do
    round = concession_round!([b, b, a])

    expect(round.current_entity).to eq(b)
    float_regional!(round, 'LNWR')
    expect(round.current_entity).to eq(b)
    float_regional!(round, 'PLM')
    expect(round.current_entity).to eq(a)
  end

  it 'leaves out a player who did not purchase a concession (§8.1)' do
    round = concession_round!([c, a])

    float_regional!(round, 'LNWR')

    expect(round.current_entity).to eq(a)
  end

  it 'does not let a concession holder pass (§8.1)' do
    round = concession_round!([a])

    expect(round.active_step.actions(a)).to eq(['par'])
  end

  it 'names the concession being executed and the allowed choices (§8.1)' do
    round = concession_round!([a, b])

    expect(round.active_step.help).to eq(
      'Executing the 1st Concession: float a minor you own or a regional you can afford'
    )
  end

  it 'shows the track rights zones to a holder who owns a minor (§8.1)' do
    round = concession_round!([a, b])
    give_company!(a, game.company_by_id('A'))

    help = round.active_step.help

    expect(help).to start_with('Executing the 1st Concession: float a minor you own or a regional you can afford')
    expect(help).to include('Available track rights zones:')
  end

  it 'tells a holder who can float neither a minor nor a regional to par into the Open Market (§8.1)' do
    round = concession_round!([a, b])
    a.spend(a.cash - 100, game.bank)

    expect(round.active_step.help).to eq(
      'Executing the 1st Concession: you cannot float a minor or afford a regional, ' \
      'so par a regional into the Open Market'
    )
  end

  it 'offers no actions to other players or corporations (§8.1)' do
    round = concession_round!([a])
    lnwr = game.corporation_by_id('LNWR')

    expect(round.active_step.actions(b)).to eq([])
    expect(round.active_step.actions(lnwr)).to eq([])
  end

  it 'lets the holder float a minor they own (§8.1)' do
    round = concession_round!([a, b])
    minor = float_minor!(round, 'A')
    place_home!(minor)

    expect(minor).to be_floated
    expect(a.percent_of(minor)).to eq(100)
  end

  it 'lets the holder float a regional (§8.1)' do
    round = concession_round!([a, b])
    float_regional!(round, 'LNWR')

    lnwr = game.corporation_by_id('LNWR')
    expect(lnwr).to be_floated
    expect(a.percent_of(lnwr)).to eq(50)
    expect(game.regional_corps_floated).to eq(1)
    expect(game.minor_regional_order.last).to eq(lnwr)
  end

  it 'refuses to float a minor owned by another player (§8.1)' do
    round = concession_round!([a, b])
    minor = game.corporation_by_id('B')
    give_company!(b, game.company_by_id('B'))
    fund!(game, minor, 120)
    price = round.active_step.get_par_prices(a, minor).first
    game.process_action(Engine::Action::Par.new(a, corporation: minor, share_price: price))

    expect(game.exception).to be_a(Engine::GameError)
    expect(game.company_by_id('B')).not_to be_closed
    expect(minor).not_to be_floated
  end

  it "finishes the minor's home token before the next concession (§8.1)" do
    round = concession_round!([a, b])
    minor = float_minor!(round, 'A')

    expect(round.active_step).to be_a(Engine::Game::G18OE::Step::HomeToken)
    expect(round.current_entity).to eq(minor)
    expect(round.current_concession).to eq(game.company_by_id('CON2'))

    place_home!(minor)

    expect(round.active_step).to be_a(Engine::Game::G18OE::Step::Concession)
    expect(round.current_entity).to eq(b)
  end

  it "keeps the Concession RR Phase open until the last concession's minor has its home token (§8.1)" do
    round = concession_round!([a])
    minor = float_minor!(round, 'A')

    expect(game.round).to be_a(Engine::Round::G18OE::Concession)
    expect(game.round.active_step).to be_a(Engine::Game::G18OE::Step::HomeToken)

    place_home!(minor)

    expect(minor.tokens.first.used).to be(true)
    expect(game.round).to be_a(Engine::Round::Stock)
    expect(game.round).not_to be_a(Engine::Round::G18OE::Concession)
    expect(game.round.current_entity).to eq(b)
  end

  it 'removes each concession once executed (§8.1)' do
    round = concession_round!([a, b])
    float_regional!(round, 'LNWR')

    expect(game.company_by_id('CON1')).to be_closed
    expect(a.companies.map(&:sym)).not_to include('CON1')
    expect(game.concessions.map(&:sym)).to eq(['CON2'])
  end

  it 'logs the execution of the concession (§8.1)' do
    round = concession_round!([a])
    float_regional!(round, 'LNWR')

    expect(game.log.map(&:message)).to include("#{a.name} executes the 1st Concession")
  end

  it 'starts the Regional/Minor stock round after the last concession (§8)' do
    round = concession_round!([a])
    float_regional!(round, 'LNWR')

    expect(game.round).to be_a(Engine::Round::Stock)
    expect(game.round).not_to be_a(Engine::Round::G18OE::Concession)
    expect(game.round.name).to eq('Stock Round')
  end

  it "gives priority to the player left of the last concession's executor (§3.2, §8)" do
    round = concession_round!([c, a])
    float_regional!(round, 'LNWR')
    float_regional!(round, 'PLM')

    expect(game.round.current_entity).to eq(b)
    expect(game.players.first).to eq(b)
    expect(game.log.map(&:message)).to include("#{b.name} has priority deal")
  end

  it 'wraps priority around the table when the last executor sits last (§3.2)' do
    round = concession_round!([a, c])
    float_regional!(round, 'LNWR')
    float_regional!(round, 'PLM')

    expect(game.round.current_entity).to eq(a)
  end

  describe 'mandatory regional float' do
    def open_market_par!(player, par: 80)
      lnwr = game.corporation_by_id('LNWR')
      act!(game, Engine::Action::Par.new(player, corporation: lnwr, share_price: cell(game, par, :par)))
      lnwr
    end

    it 'requires a regional float when one is affordable and no minor is held (§8.1)' do
      round = concession_round!([a])
      a.spend(a.cash - 120, game.bank)

      expect(round.active_step.must_par_in_open_market?(a)).to be(false)
      expect(round.active_step.get_par_prices(a, game.corporation_by_id('LNWR')).map(&:price)).to eq([60])
    end

    it 'requires the open-market par when no regional is affordable and no minor is held (§8.1)' do
      round = concession_round!([a])
      a.spend(a.cash - 100, game.bank)

      expect(round.active_step.must_par_in_open_market?(a)).to be(true)
      prices = round.active_step.get_par_prices(a, game.corporation_by_id('LNWR')).map(&:price)
      expect(prices).to eq(game.stock_market.par_prices.map(&:price))
      expect(round.active_step.par_price_only(game.corporation_by_id('LNWR'), cell(game, 80, :par))).to be(true)
    end

    it 'does not require the open-market par of a holder who owns a minor (§8.1)' do
      round = concession_round!([a])
      give_company!(a, game.company_by_id('A'))
      a.spend(a.cash - 100, game.bank)

      expect(round.active_step.must_par_in_open_market?(a)).to be(false)
      expect(round.active_step.get_par_prices(a, game.corporation_by_id('LNWR'))).to eq([])
    end

    it 'places the president share of the open-market regional in the Open Market (§8.1)' do
      concession_round!([a])
      a.spend(a.cash - 100, game.bank)
      lnwr = open_market_par!(a)

      expect(lnwr.share_price.price).to eq(80)
      expect(game.share_pool.shares_of(lnwr).map(&:percent)).to eq([50])
      expect(lnwr.owner).to be_nil
      expect(lnwr).not_to be_floated
      expect(a.cash).to eq(100)
      expect(a.percent_of(lnwr)).to eq(0)
      expect(lnwr.cash).to eq(0)
    end

    it 'logs the open-market par (§8.1)' do
      concession_round!([a])
      a.spend(a.cash - 100, game.bank)
      open_market_par!(a)

      expect(game.log.map(&:message)).to include("#{a.name} pars LNWR at #{game.format_currency(80)} into the Open Market")
    end

    it 'gives an open-market regional an operating-order slot without running it (§8.1)' do
      concession_round!([a])
      a.spend(a.cash - 100, game.bank)
      lnwr = open_market_par!(a)

      expect(game.minor_regional_order.last).to eq(lnwr)
      expect(game.operating_order).not_to include(lnwr)
    end

    it 'counts an open-market regional toward the regionals in play (§8.2)' do
      concession_round!([a])
      a.spend(a.cash - 100, game.bank)
      open_market_par!(a)

      expect(game.regional_corps_floated).to eq(0)
      expect(game.regionals_in_play).to eq(1)
    end

    it 'closes the concession of an open-market par (§8.1)' do
      round = concession_round!([a, b])
      a.spend(a.cash - 100, game.bank)
      open_market_par!(a)

      expect(game.company_by_id('CON1')).to be_closed
      expect(round.current_entity).to eq(b)
    end

    it 'does not offer a fresh par of an open-market regional in the stock round (§8.2)' do
      concession_round!([a])
      a.spend(a.cash - 100, game.bank)
      lnwr = open_market_par!(a)
      stock_round!(game)

      expect(game.can_par?(lnwr, a)).to be(false)
    end

    it 'lets a minor holder float a regional instead of the minor (§8.1)' do
      round = concession_round!([a, b])
      give_company!(a, game.company_by_id('A'))
      float_regional!(round, 'LNWR')

      expect(game.corporation_by_id('LNWR')).to be_floated
      expect(game.company_by_id('A')).not_to be_closed
      expect(a.companies.map(&:sym)).to include('A')
    end

    it 'still floats a regional that the holder paid for as before (§8.1)' do
      round = concession_round!([a, b])
      float_regional!(round, 'LNWR')
      lnwr = game.corporation_by_id('LNWR')

      expect(lnwr).to be_floated
      expect(lnwr.owner).to eq(a)
      expect(game.operating_order).to include(lnwr)
    end

    describe 'buying the presidency from the Open Market (§8.2)' do
      let!(:lnwr) do
        concession_round!([a])
        a.spend(a.cash - 100, game.bank)
        open_market_par!(a)
      end
      let(:round) do
        fund!(game, b)
        stock_round!(game)
      end
      let(:step) { round_step(round, Engine::Game::G18OE::Step::BuySellParShares) }
      let(:presidency) { game.share_pool.shares_of(lnwr).first }

      def buy!
        act!(round, Engine::Action::BuyShares.new(b, shares: presidency, percent: 50))
      end

      before { pass_until!(round, b) }

      it "offers an Open-Market regional's presidency in the stock round (§8.2)" do
        expect(step.can_buy?(b, presidency.to_bundle)).to be(true)
        expect(step.actions(b)).to include('buy_shares')
      end

      it "pays twice par into the regional's treasury, less its home token (§8.2, §9.2)" do
        cash = b.cash
        buy!
        expect(b.cash).to eq(cash - 160)
        expect(lnwr.cash).to eq(120)
      end

      it 'makes the buyer president and floats the regional (§8.2)' do
        buy!
        expect([lnwr.owner, b.percent_of(lnwr), lnwr.floated?, game.share_pool.shares_of(lnwr)]).to eq([b, 50, true, []])
      end

      it "places the regional's home token when bought (§9.2)" do
        buy!
        expect(lnwr.tokens.first.used).to be(true)
      end

      it 'operates the bought regional in the slot it was parred into (§8.1)' do
        buy!
        expect(game.minor_regional_order.count(lnwr)).to eq(1)
        expect(game.operating_order).to include(lnwr)
      end

      it 'counts the bought regional as floated (§8.2)' do
        buy!
        expect([game.regional_corps_floated, game.regionals_in_play]).to eq([1, 1])
      end

      it 'refuses a partial bundle of the presidency share (§8.2)' do
        expect(step.can_buy?(b, Engine::ShareBundle.new(presidency, 25))).to be(false)
      end

      it 'refuses the presidency after the buyer already bought or parred this turn (§8.2)' do
        round.current_actions << Engine::Action::Par.new(b, corporation: game.corporation_by_id('PLM'),
                                                            share_price: cell(game, 60, :par))
        expect(step.can_buy?(b, presidency.to_bundle)).to be(false)
      end

      it 'starts the Major RR Phase when the bought regional is the 18th float (§8.2)' do
        game.corporations.select { |c| c.type == :regional && !c.ipoed }.each { |c| game.close_corporation(c) }
        game.regional_corps_floated = game.class::MAX_FLOATED_REGIONALS - 1
        game.minor_floated_regions = game.corporations.select { |c| c.type == :minor }.to_h { |m| [m.id, 'RU'] }
        buy!
        expect(game.major_phase?).to be(true)
      end

      it 'refuses the presidency to a player who cannot pay twice par (§9.2)' do
        b.spend(b.cash - 150, game.bank)
        expect(step.can_buy?(b, presidency.to_bundle)).to be(false)
      end

      it "keeps a parred regional's 25% shares off sale (§8.2)" do
        allow(game).to receive(:major_phase?).and_return(true)
        expect(step.can_buy?(b, lnwr.ipo_shares.first.to_bundle)).to be(false)
      end

      it "records the presidency purchase as the buyer's share action and passes the turn (§8.2)" do
        buy!
        expect([round.players_bought[b][lnwr], round.current_entity]).to eq([50, c])
      end
    end

    it 'does not offer the Open-Market presidency during the Concession round (§8.1)' do
      round = concession_round!([a, b])
      a.spend(a.cash - 100, game.bank)
      open_market_par!(a)

      expect(round.active_step.actions(b)).to eq(['par'])
    end

    it 'still lets a regional parred normally be bought as before (§8.1)' do
      concession_round!([a, b])
      float_regional!(game.round, 'LNWR')
      lnwr = game.corporation_by_id('LNWR')
      round = stock_round!(game)
      step = round_step(round, Engine::Game::G18OE::Step::BuySellParShares)
      allow(game).to receive(:major_phase?).and_return(true)

      expect(game.open_market_regional?(lnwr)).to be(false)
      expect(step.can_buy?(b, lnwr.ipo_shares.first.to_bundle)).to be(true)
    end

    it 'closes the unparred regionals when an open-market par reaches the regional maximum (§8.2)' do
      concession_round!([a, b])
      game.regional_corps_floated = game.class::MAX_FLOATED_REGIONALS - 1
      a.spend(a.cash - 100, game.bank)
      lnwr = open_market_par!(a)

      expect(lnwr).not_to be_closed
      expect(game.regional_corps_floated).to eq(game.class::MAX_FLOATED_REGIONALS - 1)
      expect(game.minor_regional_order).to include(lnwr)
      expect(game.corporations.select { |c| c.type == :regional && !c.ipoed }).to all(be_closed)
    end

    it 'keeps the Regional/Minor phase while a parred regional is unfloated (§8.2)' do
      concession_round!([a, b])
      game.regional_corps_floated = game.class::MAX_FLOATED_REGIONALS - 1
      game.minor_floated_regions = game.corporations.select { |c| c.type == :minor }.to_h { |m| [m.id, 'RU'] }
      a.spend(a.cash - 100, game.bank)
      open_market_par!(a)

      expect(game.major_phase?).to be(false)
    end
  end
end
