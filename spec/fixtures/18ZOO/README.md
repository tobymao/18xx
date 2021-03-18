18ZOO Mock Game Manifest

* sell_ticket_zoo_in_any_phase (3 players):
  * Player 1 sells ZOOTicket on Monday SR (+4)
  * GI sells ZOOTicket on Monday OR 1 (+5)
  * GI sells ZOOTicket on Monday OR 2 (+6)
  * Player 2 sells ZOOTicket on Tuesday SR (+7)
  * PB sells ZOOTicket on Tuesday OR 1 (+8)
  * PB sells ZOOTicket on Tuesday OR 2 (+9)
  * Player 3 sells ZOOTicket on Wednesday SR (+10)
  * PE sells ZOOTicket on Wednesday OR 1 (+12)
  * PE sells ZOOTicket on Wednesday OR 2 (+15)

```
Flows:

- sell_ticket_zoo_in_any_phase.json - player and corporation can sell tickets in each SR / OR
```

```
Working:
SR powers:
- sr_power.holiday.json
- sr_power.leprechaun_pot_of_gold.json
- sr_power.midas.json
- sr_power.too_much_responsibility.json
- sr_power.whatsup.json
```

```
Not working:
- or_power.ancient_maps.not_yet_working - M / MM cannot be laid
- or_power.sparkling_gold.not_yet_working - M / MM cannot be laid

- or_power.a_spoonful_of_sugar.not_yet_working
- or_power.a_squeeze.not_yet_working
- or_power.bandage.not_yet_working
- or_power.corn.not_yet_working - missing overridee on assign step
- or_power.hole.not_yet_working
- sr_power.it_is_all_greek_to_me.json
- or_power.moles.not_yet_working
- or_power.on_diet.not_yet_working
- or_power.rabbits.not_yet_working
- or_power.that_is_mine.not_yet_working
- or_power.two_barrels.not_yet_working
- or_power.wings.not_yet_working
- or_power.work_in_progress.not_yet_working
```
