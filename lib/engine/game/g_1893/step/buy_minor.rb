# frozen_string_literal: true

module BuyMinor
  def draft_object(object, player, price, forced: false)
    player.spend(price, @game.bank)
    verb = forced ? 'is forced to buy' : 'buys'
    @log << "#{player.name} #{verb} \"#{object.name}\" for #{@game.format_currency(price)}"

    if object.minor?
      treasury = price < 100 ? 100 : price
      draft_minor(object, player, treasury)
    else
      draft_company(object, player)
    end
  end

  def draft_minor(minor, player, treasury)
    @game.log << "Minor #{minor.name} floats and receives "\
      "#{@game.format_currency(treasury)} in treasury"
    minor.owner = player
    minor.float!
    @game.bank.spend(treasury, minor)
  end

  def draft_company(company, player)
    @game.bank.companies&.delete(company)
    company.owner = player
    player.companies << company
  end

  def initial_minor_price(minor)
    minor.value
  end
end
