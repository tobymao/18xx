# frozen_string_literal: true

require './spec/support/fixture_specs'

describe FixtureSpecs do
  it 'has one shard_NN_spec.rb file per shard, so no fixture is silently skipped' do
    shard_files = Dir[File.join(__dir__, 'shard_[0-9][0-9]_spec.rb')].map { |f| File.basename(f) }.sort
    expected = (0...FixtureSpecs::SHARDS).map { |i| format('shard_%02d_spec.rb', i) }
    expect(shard_files).to eq(expected)
  end
end
