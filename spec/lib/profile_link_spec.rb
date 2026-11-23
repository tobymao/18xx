# frozen_string_literal: true

require 'spec_helper'
require 'lib/profile_link'

describe Lib::ProfileLink do
  let(:component) do
    Class.new do
      include Lib::ProfileLink

      def h(tag, props = {}, children = nil)
        [tag, props, children]
      end
    end.new
  end

  it 'links a real player profile' do
    expect(component.profile_link(12, 'Alice').first).to eq(:a)
  end

  it 'renders plain text when links are disabled' do
    link = component.profile_link(12, 'Alice', link: false)
    expect(link.first).to eq(:span)
    expect(link[1]).to eq('Alice')
  end

  it 'renders plain text for dummy players' do
    link = component.profile_link(-1, 'Alice')
    expect(link.first).to eq(:span)
    expect(link[1]).to eq('Alice')
  end
end
