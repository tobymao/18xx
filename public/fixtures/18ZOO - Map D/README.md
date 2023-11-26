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

```
URLs: http://localhost:9292/fixture/18ZOO/{name}

Working:
SR powers:
- sr_power.days_off.json
- sr_power.it_is_all_greek_to_me.json
- sr_power.leprechaun_pot_of_gold.json
- sr_power.midas.json
- sr_power.too_much_responsibility.json
- sr_power.whatsup.json
OR powers:
- or_power.ancient_maps
- or_power.a_tip_of_sugar
- or_power.a_squeeze
- or_power.wheat
- or_power.hole
- or_power.moles
- or_power.on_a_diet
- or_power.rabbits
- or_power.shining_gold
- or_power.two_barrels
- or_power.that_s_mine
- or_power.wings
- or_power.work_in_progress
```

```
Not working:
- or_power.patch.not_yet_working
```
