# frozen_string_literal: true

module BuyMinor
  def draft_object(object, player, price, forced: false)
    company = @game.to_company(object)

    player.spend(price, @game.bank)
    verb = forced ? 'is forced to buy' : 'buys'
    @log << "#{player.name} #{verb} \"#{company.name}\" for #{@game.format_currency(price)}"

    draft_company(company, player)
    return unless @game.minor_proxy?(company)

    treasury = price < 100 ? 100 : price
    float_minor(company, player, treasury)
  end

  def float_minor(minor_proxy, player, treasury)
    minor = @game.minor_by_id(minor_proxy.sym)
    @game.log << "Minor #{minor.name} floats and receives "\
                 "#{@game.format_currency(treasury)} in treasury"
    minor.owner = player
    minor.float!
    @game.bank.spend(treasury, minor)
  end

  def draft_company(company, player)
    company.owner.companies&.delete(company)
    company.owner = player
    player.companies << company
  end

  def initial_minor_price(minor)
    @game.minor_starting_treasury(minor)
  end
end
