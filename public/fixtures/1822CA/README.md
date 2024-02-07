# 1822CA Fixture Manifest

* `1`
  * various destination token (and slot icon) interactions with big city upgrades (issue #10147)
    * destination was in an extra slot, and a major had two tokens on one hex;
      after the upgrade, the cities join up, the duplicate token is returned,
      and so the destination no longer needs an extra slot
  * destination token creating an extra slot next to a minor's home
  * interactions with ICR's variable destination options (issue #10171)

* `2`
    * various destination token (and slot icon) interactions with big city upgrades (issue #10147)
    * 9 tokens in Winnipeg; assets_spec test added to ensure rendering works (issue #10173)

* `3`
    * ICR's destination token staying in the correct city in Quebec when
      upgraded to green (issue #10201)

* `4`
    * upgrading Toronto to T4 (brown, only two slots) after three tokens are
      present--M13's "rondel" token, plus M12 and and GT (issue #10226)
