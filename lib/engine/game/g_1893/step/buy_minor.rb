# frozen_string_literal: true

module BuyMinor
  def handle_connected_minor(company, buyer, treasury)
    minor = @game.minor_by_id(company.id)
    return unless (minor = @game.minor_by_id(company.id))

    @game.log << "Minor #{minor.full_name} floats and receives "\
      "#{@game.format_currency(treasury)} in treasury"
    minor.owner = buyer
    minor.float!
    @game.bank.spend(treasury, minor)
  end
end
