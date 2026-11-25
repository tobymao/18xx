# frozen_string_literal: true

require 'spec_helper'
require 'assets'

describe 'Mail' do
  before(:all) { @subject = Assets.new }

  subject { @subject }

  def render(**needs)
    subject.html('assets/app/mail/turn.rb', **needs)
  end

  it 'should render mail' do
    html = render(game_id: '1', game_url: '')
    expect(html).not_to be_nil
    expect(html).not_to include('BG Stats')
  end

  it 'links to BG Stats when given a URL' do
    html = render(game_id: '1', game_url: '/game/1', bg_stats_url: '/game/1?bgstats=1')
    expect(html).to include('href="/game/1?bgstats=1"', 'Log to BG Stats')
  end
end
