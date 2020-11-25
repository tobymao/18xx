# frozen_string_literal: true

#
# This module supports paying interest on
# loans and taking out extra loans to cover the interest
# returns interest owed if it cannot pay
module InterestOnLoans
  def pay_interest!(entity)
    owed = interest_owed(entity)

    while owed > entity.cash &&
        (loan = loans[0]) &&
        entity.loans.size < maximum_loans(entity)
      take_loan(entity, loan)
      owed = interest_owed(entity)
    end

    owed_fmt = format_currency(owed)

    if owed <= entity.cash
      @log << "#{entity.name} pays #{owed_fmt} interest for #{entity.loans.size} loans"
      entity.spend(owed, bank)
      return
    end
    owed
  end
end
