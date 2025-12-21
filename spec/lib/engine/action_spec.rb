# frozen_string_literal: true

require './spec/spec_helper'

describe Engine::Action do
  described_class.constants.each do |const|
    action_class = described_class.const_get(const)
    next unless action_class < described_class::Base

    describe action_class do
      it "REQUIRED_ARGS match #initialize()'s default-less keyword arguments" do
        # instance_method(:initialize).parameters doesn't work in the compiled
        # JS, so instead of simply using this code in
        # Engine::Action::Base.from_h to check the appropriate args, this test
        # is used to ensure the action classes have those args listed in their
        # REQUIRED_ARGS
        args = action_class.instance_method(:initialize).parameters.filter_map do |kind, name|
          (kind == :keyreq) && name
        end
        expect(action_class::REQUIRED_ARGS).to match_array(args)
      end
    end
  end
end
