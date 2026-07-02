# frozen_string_literal: true

require_relative '../../lib/email_canonical'

describe EmailCanonical do
  def n(e) = described_class.normalize(e)

  it 'strips gmail dots' do
    expect(n('first.last@gmail.com')).to eq('firstlast@gmail.com')
  end

  it 'strips a +tag and gmail dots together' do
    expect(n('First.Last+18xx@Gmail.com')).to eq('firstlast@gmail.com')
  end

  it 'treats googlemail like gmail' do
    expect(n('foo.bar+x@googlemail.com')).to eq('foobar@googlemail.com')
  end

  it 'keeps dots for non-gmail domains but still strips the +tag' do
    expect(n('a.b.c+tag@yahoo.com')).to eq('a.b.c@yahoo.com')
  end

  it 'downcases and trims surrounding whitespace' do
    expect(n('  User@Example.COM ')).to eq('user@example.com')
  end

  it 'returns a value with no @ unchanged except case/space' do
    expect(n('  SomeUser ')).to eq('someuser')
  end

  it 'splits on the last @ only' do
    expect(n('a.b+t@weird@gmail.com')).to eq('ab@weird@gmail.com')
  end
end
