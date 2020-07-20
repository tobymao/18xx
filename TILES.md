### Development Routes

Some app routes that may be of interest to developers:

* `/map/<game_title>` - renders the given game's map
* `/tiles/all` - renders all of the track tiles (and generic map hex "tiles")
  defined in `lib/engine/tile.rb`
* `/tiles/<game_title>` - renders all of the track tiles (and map hex "tiles")
  for the given game. Multiple game titles can be given, separated by `+`.
* `/tiles/<tile_name>` - renders a single tile at large scale (tile must be
  defined in `lib/engine/tile.rb`)
* `/tiles/<game_title>/<hex_coord_or_tile_name>` - renders a single hex or tile
  the given game at large scale. Multiple hex coords or tile names can be given,
  separated by `+`.

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
    - **track** - broad/narrow/dual/line/dashed; this option is not yet
      implemented, so track is always broad
- **label** - large letter(s) on tile (e.g., "Chi", "OO", or "Z")
- **upgrade**
    - **cost** - *required* - integer
    - **terrain** - `mountain`/`water` - multiple terrain types separated by `|`
- **border**
    - **edge** - integer - which edge to hide from rendering; a line matching
      the tile's color is drawn on top of the edge's normal black line so that
      two adjacent tiles appear joined
- **junction** - the center point of a Lawson-style tile
- **icon**
    - **image** - *required* - name of image, will be rendered with file at
      `public/icons/#{image}.svg`
    - **name** - name of this icon; default is value given for `image`
    - **sticky** - `1` indicates the icon should remain visible when a tile
      upgrade is placed on this hex
    - **blocks_lay** - indicates this tile cannot be laid normally
  but can only be laid by special ability, such as a private company's ability.

#### Town/City/Offboard sub parts

Towns, cities, and offboards have a few "sub parts" in common:

- **revenue** - *required* - single integer, or revenues for different phases
  (separated by "|")
    - phase based revenue has the phase and revenue separated by an underscore,
      e.g., `yellow_40`
- **groups** - strings separated by `|`; routes cannot contain more than one
  revenue center from a group, e.g., "East" is a group in 1846 as routes cannot run E-E
- **hide** - `1` indicates that the revenue for this revenue center should not be rendered

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
