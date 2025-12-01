18ZOO Mock Game Manifest

* sell_ticket_zoo_in_any_phase (3 players) - tests selling in SR-BuyShare and OR-Track:
  * Player 1 sells ZOOTicket on Monday SR (+4)
  * GI sells ZOOTicket on Monday OR 1 (+5)
  * GI sells ZOOTicket on Monday OR 2 (+6)
  * Player 2 sells ZOOTicket on Tuesday SR (+7)
  * PB sells ZOOTicket on Tuesday OR 1 (+8)
  * PB sells ZOOTicket on Tuesday OR 2 (+9)
  * Player 3 sells ZOOTicket on Wednesday SR (+10)
  * PE sells ZOOTicket on Wednesday OR 1 (+12)
  * PE sells ZOOTicket on Wednesday OR 2 (+15)

* sell_ticket_zoo_in_any_step (2 players) - tests selling in OR steps:
  * GI sells on G18ZOO::Step::Token
  * GI sells on G18ZOO::Step::BuyTrain
  * GI sells on G18ZOO::Step::BuyOrUsePowerOnOr (and the blocking step is unblocked)
  * GI sells on G18ZOO::Step::Route
  * GI sells on G18ZOO::Step::Dividend

URLs: http://localhost:9292/fixture/18ZOO%20-%20Map%20A/{name}
