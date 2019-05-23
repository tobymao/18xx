# frozen_string_literal: true

require 'engine/ownable'

module Engine
  class Share
    include Ownable

    attr_accessor :owner, :president
    attr_reader :corporation, :percent

    def initialize(corporation, owner, president: false, percent: 10)
      @corporation = corporation
      @president = president
      @percent = percent
      @owner = owner
    end
  end
end
