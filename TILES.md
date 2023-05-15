### Development Routes

Some app routes that may be of interest to developers:

* `/map/<game_title>` - renders the given game's map
* `/tiles/all` - renders all of the track tiles (and generic map hex "tiles")
  defined in `lib/engine/tile.rb`
* `/tiles/<tile_name>` - renders a single tile at large scale (tile must be
  defined in `lib/engine/tile.rb`)
* `/tiles/<game_title>/<hex_coord_or_tile_name>` - renders a single hex or tile
  the given game at large scale. Multiple hex coords or tile names can be given,
  separated by `+`.
* `/tiles/<game_titles>/all` - renders all of the track tiles (and map hex
  "tiles") for the given games (multiple game titles can be given, separated by
  `+`). The game titles are fuzzy matched.

Optional URL params for above routes:

* `r=<rotation(s)>` - specify the rotation with an `Integer`, multiple rotations
    with `+`-separated `Integer`s, or `all` to see all 6. Preprinted tiles are
    not rotated. This param is ignored at `/tiles/all`.
* `n=<location_name>` - specify a location name to render for tiles that have at
    least one stop. Preprinted tiles with location names are not
    overridden. This param is ignored at `/tiles/all`.
* `grid` - show the triangular grid on the hexes to identify regions on the tile
* Rotation can be specified in `<tile_name>` by adding it after a `-`, e.g.,
  `/tiles/9-1` renders tile #9 with rotation 1, and `/tiles/7-2+8-2` renders
  tiles 7 and 8 both with rotation 2. Tiles that have rotation specified in this
  way ignore the `r=` param.

### Anatomy of a Tile

![Anatomy of a Tile](/public/images/tile_anatomy_flat.png?raw=true "Anatomy of a Flat Tile")


![Anatomy of a Tile](/public/images/tile_anatomy_pointy.png?raw=true "Anatomy of a Pointy Tile")

### Illustrations of Lanes

![Illustration of Lanes 1](/public/images/lane_widths.png?raw=true "Examples of lane widths")

![Illustration of Lanes 2](/public/images/lanes_small.png?raw=true "Examples of lane connections")

### Tile language

Main parts are separated by `;`. Sub parts are separated by `,`. If a sub part
takes a list of properties, those properties are separated by `|`.

Some parts of a tile are not defined in this string but at other parts of the
game config/code:

* color
* location name(s)
* city slots reserved for corporations/companies (e.g., home token locations)
* company "blockers" that prevent tile lays in the hex

#### Main Parts

- **city**
    - **slots** - integer - how many tokens can fit in this city (default: `1`)
- **town**
- **offboard** - this revenue center is not actually rendered, but changes how
  the track to it is rendered; track to offboards are pointed
- **path**
    - **a** and **b** - *required* - the two points connected by this path; can
      be integer to indicate edge number, or an underscore followed by an
      integer to refer by index to a city/town/offboard/junction defined earlier
      on the tile
    - **terminal** - `1` - indicates that path is part of a non-passthru path, typically for off-board cities. Tapered track will be drawn.  If a `2` is used instead, the tapered track will be drawn much shorter.
    - **ignore** - `1` - indicates that path should be ignored when node walk is trying to map available paths and hexes.
    - **a\_lane** - integer.integer - first integer specifies the lane width for the **a** path endpoint, the second integer specifies the lane index, or position within the lane. 0 is the most clockwise position.
    - **b\_lane** - integer.integer - first integer specifies the lane width for the **b** path endpoint, the second integer specifies the lane index, or position within the lane. 0 is the most clockwise position.
    - **lanes** - integer - number of parallel paths. Creates multiple copies of this path with **a\_lane** and **b\_lane** for each path generated automatically and set rationally.
    - **track** - `broad/narrow/dual` - used for display and connectivity. Defaults to `broad`.
- **label** - large letter(s) on tile (e.g., "Chi", "OO", or "Z")
- **upgrade**
    - **cost** - *required* - integer
    - **terrain** - `mountain`/`water` - multiple terrain types separated by `|`
    - **loc** - (currently only supported for `:pointy` layouts) corner to
      render the upgrade in, `5.5` to be where edges `5` and `0` meet, `0.5` for
      edges `0` and `1`, and so on
- **border**
    - **edge** - *required* - integer - which edge to modify
    - **type** - `mountain`/`water`/`impassable` - Border type. If not'
      specified, a line matching the tile's color is drawn on top of the edge's
      normal black line so that two adjacent tiles appear joined.
    - **cost** - integer - cost to cross for mountain/water borders
- **junction** - the center point of a Lawson-style tile
- **icon**
    - **image** - *required* - name of image, will be rendered with file at
      `public/icons/#{image}.svg`
    - **name** - name of this icon; default is value given for `image`
    - **sticky** - `1` indicates the icon should remain visible when a tile
      upgrade is placed on this hex
    - **blocks_lay** - indicates this tile cannot be laid normally
      but can only be laid by special ability, such as a private company's ability.
    - **loc** - (currently only supported for `:pointy` layouts) corner to
      render the upgrade in, `5.5` to be where edges `5` and `0` meet, `0.5` for
      edges `0` and `1`, and so on
- **frame**
    - **color** - *required* - the color of the frame
    - **color2** - A second color to display on the frame

#### Town/City/Offboard sub parts

Towns, cities, and offboards have a few "sub parts" in common:

- **revenue** - *required* - single integer, or revenues for different phases
  (separated by "|")
    - phase based revenue has the phase and revenue separated by an underscore,
      e.g., `yellow_40`
- **groups** - strings separated by `|`; routes cannot contain more than one
  revenue center from a group, e.g., "East" is a group in 1846 as routes cannot run E-E
- **hide** - `1` indicates that the revenue for this revenue center should not be rendered

##### Towns

- **style**
    - `rect` (rectangle) - default when 1 or 2 paths connect to the town
    - `dot` - default when 0 or 3+ paths connect to the town
    - `hidden` - don't show at all, useful for special offboards that count as
      towns instead of cities; construct with a hidden town and `terminal` paths

#### Lanes

Lanes are used to specify paths for tiles that have double-track, treble-track and quad-track. Every
path endpoint (**a** and **b**) has two lane attributes associated with it: *width* and *index*. The
*width* specifies the number of tracks that connect to a given edge. The *index* specifies the position
of that particular path within those tracks. Typically, only the **lanes** sub part for a path needs to
be given. That will automatically create n "parallel" paths between the edges or nodes specified on
the **path**. The only time **a\_lane** or **b\_lane** need to be given is if the endpoints need to be
connected in an unusual way (for instance going from a double-track edge to a single-track edge).

#### Examples

* tile #1

`town=revenue:10;town=revenue:10;path=a:1,b:_0;path=a:_0,b:3;path=a:0,b:_1;path=a:_1,b:4`

![Tile 1](/public/images/tile_1.png?raw=true "Tile 1")

* tile #23

`path=a:0,b:3;path=a:0,b:4`

![Tile 23](/public/images/tile_23.png?raw=true "Tile 23")

* Lawson tile #81

`junction;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0`

![Tile 81](/public/images/tile_81.png?raw=true "Tile 81")

* 1889 - tile 439

`city=revenue:60,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=H;upgrade=cost:80`

![Tile 439](/public/images/tile_1889_439.png?raw=true "Tile 439")

* 1889 - preprinted tile for H5

`upgrade=cost:80,terrain:water|mountain`

![1889 H5](/public/images/tile_1889_H5.png?raw=true "1889 H5")

* 18Chesapeake - preprinted tiles for A3 and B2
    * A3 - `city=revenue:yellow_40|green_50|brown_60|gray_80,hide:1,groups:Pittsburgh;path=a:5,b:_0;border=edge:4`
    * B2 - `offboard=revenue:yellow_40|green_50|brown_60|gray_80,groups:Pittsburgh;path=a:0,b:_0;border=edge:1`

![18Chesapeake A3_B2](/public/images/tile_18Chesapeake_A3_B2.png?raw=true "18Chesapeake A3_B2")

* 18Chesapeake - preprinted tile for H6

`city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:4,b:_1;label=OO;upgrade=cost:40,terrain:water`

![18Chesapeake H6](/public/images/tile_18Chesapeake_H6.png?raw=true "18Chesapeake H6")

* 18Chesapeake - preprinted tile for K3

`town=revenue:0;town=revenue:0`

![18Chesapeake K3](/public/images/tile_18Chesapeake_K3.png?raw=true "18Chesapeake K3")

* 18MEX - Upgrade for Mexico City

`city=revenue:60,slots:3,loc:center;town=revenue:10,loc:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:2,b:_1;path=a:5,b:_0,lanes:2;path=a:_1,b:_0;label=MC`

![18MEX 485MC](/public/images/tile_18MEX_485MC.png?raw=true "18MEX 485MC")

* 18MEX - Upgrade for Puebla

`town=revenue:10;path=a:2,b:_0,a_lane:2.1;path=a:5,b:_0;path=a:2,b:4,a_lane:2.0;label=P`

![18MEX 485P](/public/images/tile_18MEX_485P.png?raw=true "18MEX 485P")

* 1831 - tile 301c (title not implemented)

`path=a:0,b:3,lanes:3`

![1831 301c](/public/images/tile_1831_301c.png?raw=true "1831 301c")
