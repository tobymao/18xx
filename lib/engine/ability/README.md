# Abilities

This page documents the different ability types and the attributes
which may be set for each type.

Abilities are mainly used to describe private company powers, but may
also apply to other entities such as corporations. Examples of how
their use can be seen in the [game configuration
directory](../config/game).

## Generic attributes

These attributes may be set for all ability types

- `type`: The name of the ability type
- `owner_type`: The company must be owned by this type of entity in
  order for the ability to be active. Either "player" or
  "corporation".
- `remove`: Game phase when this ability is removed
- `count`: The number of times the ability may be used
- `count_per_or`: The number of times the ability may be used in each OR; the
  property `count_this_or` is reset to 0 at the start of each OR and increments
  each time the ability is used
- `on_phase`: The phase when this ability is active
- `when`: (string or array of strings) The game steps or special time descriptor
  when this ability is active. If no values are provided, this ability is
  considered to be "passive", i.e., its effect applies without the user needinng
  to click on the abilities button to activate it. For an ability to be included
  in an `abilities()` call, either a `time` kwarg or the name of the current
  game phase class must match (one of) the ability's `when` string(s). Examples:
    - `any`: usable at any time during the game
    - `buying_train`: train buying step
    - `Track`, `TrackAndToken`: track-laying step; if normal track lays are used
      up, but there is still a `Track` ability, then the active step will not
      pass on to the next step automatically
    - `special_track`: make the ability available to the SpecialTrack step
    - `sold`: when the company is bought from a player by a corporation
    - `bought_train`: when the owning corporation has bought a train; generally
      used with `close` abilities
    - `other_or`: usable during the OR turn of another corporation
    - `owning_corp_or_turn`: usable at any point during the owning corporation's OR turn
    - `never`: use with `close` abilities to prevent a company from closing
    - `has_train`: when the owning corporation owns at least one train

## additional_token

Adds 'count' additional tokens to a purchasing company (1817)

## assign_corporation

Designate a specific corporation to be the beneficiary of the ability,
for example Steamboat Company in 1846.

When a company with this ability is sold to a corporation, the company is
automatically assigned to the new owning corporation. With this configuration,
the automatic assignment will happen and the company cannot be further
reassigned:

```
{
  "type": "assign_corporation",
  "when": "sold",
  "count": 1,
  "owner_type": "corporation"
}
```

## assign_hexes

Designate a hex to the ability. Usually simulates placement of a
special power token.

- `hexes`: An array of hex coordinates where this ability may be used.

## blocks_hexes

Designate hexes which are blocked by this ability. Use the
`owner_type: "player"` to specify that the blocking ends when the
company is bought in by a corporation.

- `hexes`: An array of hex coordinates that are blocked

## blocks_partition

Designate a type of partition which this ability disallows crossing.
A partition separates an hex in 2 halves. Use the `owner_type: "player"`
to specify that the blocking ends when the company is bought in by a
corporation.

- `partition_type`: The name of the partition type that is to be
  blocked, akin to terrain and border types.

## close

Describe when the company closes, using the `when` attribute.

- `corporation'`: If `when` is set to `"train"`, this value is the name
  of the corporation whose train purchase closes this company.

## description

Provide a description for an ability that is implemented outside of the ability framework.

- `description`: Description of the ability.

## exchange

This company may be exchanged for a single share of a specified corporation during a step
that allows exchange.

- `corporations`: An array with corporation names, whose share may be exchanged.
  Use a simple `"any"` (no array) to allow for any corporation.
- `from`: Where the share may be take from, either `"ipo"`,
  `"market"`, or an array containing both.

## hex_bonus

Give a route bonus if at least one of the hexes are included in the route.

- `hexes`: Name of hexes that gives a bonus.
- `amount`: Revenue bonus.

## no_buy

This company may not be bought in.

## reservation

Reserve a token slot

- `hex`: Hex coordinate
- `slot`: A specific token slot to designate
- `city`: Which city to reserve, if multiple cities are on one hex

## return_token

Take a station token off the board and place back on the charter
in the most expensive open location

- `reimburse`: If true, the corporation is reimbursed the token cost
  of the location where the token is placed

## revenue_change

The revenue for this company changes when the conditions set by `when`
and `owner_type` are satisfied.

- `revenue`: The new revenue value

## shares

This company comes with a share of a corporation when acquired.

- `share`: If a string in the form of `sym_x`, where `sym` is a
  corporation symbol, and `x` is a numeric index, gives the
  certificate of the corporation at index `x` (`x = 0` is the
  president's certificate). If `"random_president"`, gives a
  president's certificate randomly selected at game setup. Gives one
  ordinary share of one the corporations listed in `corporations`,
  randomly selected at game setup.
- `corporations`: A list of corporations to be used with `"share": "random_share"`

## teleport

Lay a tile and place a station token without connectivity

- `hexes`: An array of hex coordinates that can be used as the
  teleport destination.
- `tiles`: An array of tile numbers which may be placed at the
  teleport destination.
- `cost`: Cost to use the teleport ability.
- `free_tile_lay`: If true, the tile is laid with 0 cost. Default false.

## tile_discount

Discount the cost for laying tiles in the specified terrain type

- `discount`: Discount amount
- `terrain`: If set, type of terrain for which discount is provided, otherwise the discount is off the total cost
- `hexes`: If not specified, all applicable hexes qualifies for
  the discount. If specified, only specified hexes qualify

## tile_income

Generate extra revenue when tiles are laid on specified terrain types.

- `terrain`: Terrain type for this ability
- `income`: Extra income per tile lay
- `owner_only`: Does this income apply to any tile lay (1882 Tresle Bridge) or just the owner (1817 Mountain Engineers)

## tile_lay

Lay or upgrade one or more track tiles without connectivity, in addition to
normal tile lay actions.

- `hexes`: Array of hex coordinates where tiles may be laid.
- `tiles`: Array of tile numbers which may be laid.
- `cost`: Cost to use the ability.
- `closed_when_used_up`: This ability has a count that is decreased each time it is used. If this attribute is true the private is closed when count reaches zero, if false the private
remains open but the discount can no longer be used. Default false.
- `free`: If true, the tiles are laid with 0 cost. Default false.
- `discount`: Discount the cost of laying the tile by the given
  amount. Default 0.
- `special`: If true, do not check that the tile upgrade preserves
  labels and city count. Default true.
- `connect`: If true, and `count` is greater than 1, tiles laid must
  connect to each other. Default true.
- `blocks`: If true and `when` is `sold`, then the step
  `TrackLayWhenCompanySold` will require a tile lay. Default false.
- `reachable`: If true, when tile layed, a check is done if one of the
  controlling corporation's station tokens are reachable; if not a game
  error is triggered. Default false.
- `must_lay_together`: If true and `count` is greater than 1, all the tile lays
  must happen at the same time. Default false.
- `must_lay_all`: If true and `count` is greater than 1 and `must_lay_together`
  is true, all the tile lays must be used; if false, then some tile lays may be
  forfeited. Default false.

## train_buy

Modify train buy in some way.

- `face_value`: If true, any inter corporation train buy must be at
  face value. Default false.

## train_discount

Discount the train buy cost. The `count` attribute specify how many times the discount can be used.

- `discount`: Discount amount. If > 1 this is an absolute amount. If 0 < amount < 1 it is the fraction, e.g. 0.75 is a 75% discount.
- `trains`: An array of all train names that the discount applies to.
- `closed_when_used_up`: This ability has a count that is decreased each time it is used. If this attribute is true the private is closed when count reaches zero, if false the private
remains open but the discount can no longer be used. Default true.

## train_limit

Modify train limit in some way.
For performance reasons, the supporting code needs to be added directly to the game class. See G18MEX#train_limit for an example.

- `increase`: If positive, this will increase the train limit with this
  amount in all faces. Default 0.

## token

Modified station token placement

- `hexes`: Array of hex coordinates where this ability may be used
- `price`: Price for placing token
- `teleport_price`: If present, this ability may be used to place a
  token without connectivity, for the given price.
- `extra`: If true, this ability may be used in addition to the turn's
  normal token placement step. Default false.
- `cheater`: If an integer is given, this token will be placed into a city at
  whichever is the lowest unoccupied slot index of the following: a regular slot
  in the city; the `cheater` value; one slot higher than the city actually has,
  effectively increasing the city's size by one. (See 18 Los Angeles's optional
  company "Dewey, Cheatham, and Howe" or the corporations which get removed in
  1846 2p Variant for examples). Default nil.
- `extra_slot`: Simlar to `cheater` except this token does not take a slot -
  When `cheater` is used, when the city gets an extra city slot the 'cheater' token
  goes into the newly opened slot. If `extra_slot` is used, when the city gets an extra
  token slot, the new token slot is open - the extra token does not consume it. This
  also means that an `extra_slot` token lay in an city with an open slot does not use
  up the open slot.
- `special_only`: If true, this ability may only be used by explicitly.
  activating the company to which it belongs (i.e., using the `SpecialTrack`
  step); if unset or false, `Engine::Step::Tokener#adjust_token_price_ability!`
  infers that the special ability ought to be used whenever a token is being
  placed in a location that the ability is allowed to use. Default false.


## sell_company

This company can be sold to bank for face value. This closes the company.