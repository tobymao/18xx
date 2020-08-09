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
- `when`: The game step or phase when this ability is active
- `count`: The number of times the ability may be used

## assign_corporation

Designate a specific corporation to be the beneficiary of the ability,
for example Steamboat Company in 1846

## assign_hexes

Designate a hex to the ability. Usually simulates placement of a
special power token.

- `hexes`: An array of hex coordinates where this ability may be used.

## blocks_hexes

Designate hexes which are blocked by this ability. Use the
`owner_type: "player"` to specify that the blocking ends when the
company is bought in by a corporation.

- `hexes`: An array of hex coordinates that are blocked

## close

Describe when the company closes, using the `when` attribute.

- `corporation'`: If `when` is set to `"train"`, this value is the name
of the corporation whose train purchase closes this company.

## exchange

Exchange this company for a share of a corporation.

- `corporation`: The corporation whose share may be exchanged.
- `from`: Where the share may be take from, either `"ipo"`,
  `"market"`, or an array containing both.

## hex_bonus

????

- `hexes`:
- `amount`:

## no_buy

This company may not be bought in.

## reservation

Reserve a token slot

- `hex`: Hex coordinate
- `slot`: A specific token slot to designate
- `city`: Which city to reserve, if multiple cities are on one hex

## revenue_change

The revenue for this company changes when the conditions set by `when`
and `owner_type` are satisfied.

- `revenue`: The new revenue value

## share

This company comes with a share of a corporation when acquired.

- `share`: If a string in the form of `sym_x`, where `sym` is a
  corporation symbol, and `x` is a numeric index, gives the
  certificate of the corporation at index `x` (`x = 0` is the
  president's certificate). If `"random_president"`, gives a
  president's certificate randomly selected at game setup. Gives one
  ordinary share of one the corporations listed in `corporations`,
  randomly selected at game setup.
- `corporations`: A list of corporations to be used with `"share":
  "random_share"`

## teleport

Lay a tile and place a station token without connectivity

- `hexes`: An array of hex coordinates that can be used as the
  teleport destination.
- `tiles`: An array of tile numbers which may be placed at the
  teleport destination.

## tile_discount

Discount the cost for laying tiles in the specified terrain type

- `discount`: Discount amount
- `terrain`: Type of terrain for which discount is provided

## tile_income

Generate extra revenue when tiles are laid on specified terrain types.

- `terrain`: Terrain type for this ability
- `income`: Extra income per tile lay

## tile_lay

Lay or upgrade one or more track tiles without connectivity, in addition to
normal tile lay actions.

- `hexes`: Array of hex coordinates where tiles may be laid.
- `tiles`: Array of tile numbers which may be laid.
- `free`: If true, the tiles are laid with 0 cost. Default false.
- `discount`: Discount the cost of laying the tile by the given
  amount. Default 0.
- `special`: If true, do not check that the tile upgrade preserves
  labels and city count. Default true.
- `connect`: If true, and `count` is greater than 1, tiles laid must
  connect to each other. Default true.
- `blocks`: If true and `count` is greater than 1, all tile lays must
  be performed at once.

## token

Modified station token placment

- `hexes`: Array of hex coordinates where this ability may be used
- `price`: Price for placing token
- `teleport_price`: If present, this ability may be used to place a
  token without connectivity, for the given price.
- `extra`: If true, this ability may be used in addition to the turn's
  normal token placment step. Default false.
