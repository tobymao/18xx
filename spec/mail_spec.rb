# frozen_string_literal: true

require 'spec_helper'
require 'assets'
require 'json'

describe 'Mail' do
  before(:all) { @subject = Assets.new }

  subject { @subject }

  def render(**needs)
    subject.html('assets/app/mail/turn.rb', **needs)
  end

  it 'should render mail' do
    data = JSON.parse(File.read(FIXTURES_DIR + '/1889/962.json'))
    html = render(game_data: data, game_url: '')
    expect(html).to include('Game over: SamK')
  end
end
