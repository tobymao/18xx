# Graph

This page explains how `Engine::Graph` works out what a corporation is connected
to, and how the track walk in `Part::Node#walk` and `Part::Path#walk` explores
the map.

The code lives in:

- [graph.rb](graph.rb): `Graph`, `Graph#compute` and `Graph::Pruner`
- [part/node.rb](part/node.rb): `Node#walk` (cities, towns, offboards)
- [part/path.rb](part/path.rb): `Path#walk`

## Terms

- **Path**: one piece of track on one tile. It joins two of: a tile edge, a
  node or a junction. A city tile with five exits has five paths, each one going
  from the city to an edge.
- **Node**: a city, town or offboard. A train stops at nodes. Tokens go in
  cities.
- **Edge**: one side of a hex, numbered 0 to 5. A path that ends at edge 0
  meets whatever path ends at the matching edge of the neighboring hex.
- **Junction**: a point in the middle of a tile where several paths meet
  without a node.
- **Converging exit**: a tile edge used by more than one path on that tile, like
  the shared end of a switch. `Tile#converging_exit?(edge)` is true when the
  tile has two or more paths on that edge.

## Example map

The rest of this page uses this small made-up map. Corporation A has tokens in
cities X and Y. Corporation B has filled city Z.

```
   H8         H1              H2                   H3              H4
   R ---i--- (X) ---a--- [ switch ] ---b--------- T ------c------ (Y)
              A              \                    | \              A
                              d                   e  g
                               \                  |   \
                                H5 ---------------+    H6 [Z] ---h--- H7
                                                          B
```

The letters `a` to `i` are hex sides: `a` is the border between H1 and H2, and
so on. Real tiles number their edges 0 to 5. Letters keep the example short.

| Hex | What is on it | Paths |
| --- | --- | --- |
| H1 | City X, A's token | `x1`: X to a, `x2`: X to i |
| H2 | A switch, no node | `s1`: a to b, `s2`: a to d |
| H3 | Town T | `t1`: T to b, `t2`: T to c, `t3`: T to e, `t4`: T to g |
| H4 | City Y, A's token | `y1`: Y to c |
| H5 | Plain track | `p1`: d to e |
| H6 | City Z, B's token, no free slot | `z1`: Z to g, `z2`: Z to h |
| H7 | Plain track | `w1`: h to a side with no track beyond |
| H8 | Town R | `r1`: R to i |

Things to notice:

- **H2 is a switch.** `s1` and `s2` both end at side a, so side a is a
  converging exit on H2.
- **H2, H3 and H5 form a loop.** There are two ways from H2 to T: over b, or
  down d through H5 and up e.
- **Z blocks A.** Z has no free slot and none of A's tokens, so A cannot pass
  through it. A can reach `z1`, but not `z2` or `w1` behind it.

## What Graph answers

All of these are computed per corporation and cached until the game calls
`graph.clear` (usually after a tile lay or token placement).

| Method | Answer |
| --- | --- |
| `connected_hexes(corp)` | Hexes (and which of their edges) where the corporation may lay track |
| `connected_nodes(corp)` | Cities, towns and offboards the corporation can reach |
| `connected_paths(corp)` | Every piece of track the corporation can reach |
| `reachable_hexes(corp)` | Hexes that contain reachable track |
| `tokenable_cities(corp)` | Reachable cities with a free slot for the corporation |
| `can_token?(corp)` | Whether any reachable city can take a token (stops early) |
| `route_info(corp)` | Whether the corporation has a route, and whether it must buy a train |
| `*_by_token(corp, city)` | The same answers, using only one token city as the start |

Each of these calls `compute`, which does a single walk and fills in all of
the caches at once.

## Graph options

Games create graphs with options that change how the walk behaves.

| Option | Effect |
| --- | --- |
| `home_as_token` | Treat the home city as a token before the home token is placed |
| `no_blocking` | Walk through cities even when other corporations fill them |
| `skip_track` | Ignore one track type (for example `:narrow`) |
| `check_tokens` | Let the game drop some tokens as start points (`skip_token?`) |
| `check_regions` | Stop at region borders (`graph_border_paths`, `region_border?`) |
| `backtracking` | Allow reversing at a switch (see [Backtracking](#backtracking)) |

## How `compute` works

`compute(corporation)` runs these steps.

1. **Find the start cities.** Every city with one of the corporation's tokens
   becomes a start node, unless `skip_token?` says to ignore it. Each start
   hex gets every edge that has a neighbor marked as a place the corporation
   can lay track. With
   `home_as_token`, the home hex nodes are added too. Cities from teleport or
   token abilities are added to the reachable nodes, but the walk does not
   start from them.
2. **Walk from each start city.** For each start node, call `node.walk`. All
   the *other* start cities are passed in as already visited, so a walk never
   passes through another token. Those cities get their own walk.
3. **Record each new path.** The block given to `node.walk` runs for every
   path the walk reaches. The first time a path is seen, `compute` records:
   - the path (in `paths`)
   - its nodes (in `nodes`, and passed to the caller's block)
   - its exits, and the matching edge on each neighboring hex (in `hexes`)

   A path seen a second time is ignored (`next if paths[path]`).
4. **Work out routes.** After each start node's walk, count the nodes first
   found during that walk. Two or more mandatory stops means a route exists
   and the corporation must buy a train (`route_train_purchase`). One
   mandatory stop plus an optional one means a route exists
   (`route_available`). With `routes_only: true`, `compute` returns early once
   a train purchase is known to be required.
5. **Save the results** into the caches above.

### Example

`compute(A)` on the example map:

1. **Start cities:** X and Y. Every side of H1 and H4 that has a neighbor is
   marked as a place A can lay track.
2. **Walk from X**, with Y marked as visited:
   - `x1` crosses side a into the switch, then over b to T. From T it reaches
     `t2` and `y1` (and stops at Y, a token), `t3` and the loop through H5,
     and `t4` and `z1` (and stops at Z, which blocks A).
   - `x2` crosses side i to `r1` and town R.
   - It finds 12 paths: everything except `z2` and `w1`.
3. **Walk from Y**, with X marked as visited: everything it reaches is already
   recorded, so it adds nothing.
4. **Routes:** walk 1 found several stops (X, T, Y, Z and R), so A has a route
   and must own a train.
5. **Results:**
   - `connected_paths`: the 12 paths.
   - `connected_nodes`: X, Y, T, R and Z. Z is reachable even though A can't
     pass through it.
   - `connected_hexes`: the hexes those paths touch. This includes side g of
     H6, but not side h, because `z2` was never reached.

## How the walk moves

The walk is two methods that call each other: `Node#walk` and `Path#walk`.

### `Node#walk`

Starting at a node (city, town or offboard):

1. Stop if this node is already visited. Otherwise mark it visited.
2. For each path that touches the node (skipping `skip_track` and `ignore`
   paths), call `path.walk`.
3. For each path that walk reaches, hand it to the caller's block. Then, unless
   the path is `terminal` or the block returned `:abort`, walk into any other
   node on that path. Nodes that `blocks?` the corporation are skipped, which
   is how a city full of other corporations' tokens stops the walk.

### `Path#walk`

Starting on a path:

1. **Check if this path can be used.** Stop if any of these is true:
   - the path is already visited, or in `skip_paths`
   - the current route has already gone through its junction
   - one of its edges is already used by the current route
   - it is `skip_track` track
   - it is a terminal path with a junction
2. **Mark it visited** and hand it to the block.
3. **Go through the junction**, if the path has one, into every other path
   on that junction.
4. **Go through each exit edge**, except the edge it came in on (`skip`):
   - With `backtracking`, first step into other paths on the *same tile* that
     share this edge.
   - Then cross into paths on the *neighboring hex* that end at the matching
     edge, if their lanes line up and their track gauges are compatible.
     While walking past that point, the edge is marked as used (`counter`) so
     the same route cannot cross it twice.
5. **Undo** (only in converging mode): remove this path from `visited`, so
   another route may use it later.

### Example: from X to T

1. `Node#walk` on X marks X visited and walks `x1`.
2. `Path#walk` on `x1` yields it, then looks at its exit, side a. The neighbor
   is H2. (On real tiles, the matching edge number is `hex.invert(edge)`.)
3. Both `s1` and `s2` end at side a on H2, so the walk tries both.
4. `s1` leaves H2 at side b and enters `t1` on H3. `t1` touches town T, so
   `Node#walk` on T walks T's other paths: `t2`, `t3` and `t4`.
5. `s2` leaves H2 at side d, follows `p1` through H5, and reaches T again over
   side e. That is the second way around the loop.

## Converging mode

### Why it is needed

Without switches, every path is walked once. Once a path is visited it stays
visited, and the walk is fast.

A switch makes that unsafe. With a switch, *how you arrived* on a path decides
where you can go next. On H2, a train on `s1` coming from b reaches side a and
can carry on into H1, but it cannot turn back onto `s2`. That would mean
reversing. A train coming from H1 over side a can take either `s1` or `s2`.

So "has the walk been on this path?" is not enough. It matters which way it was
going. If the walk marked a path visited after arriving from a direction that
leads nowhere, a later route arriving from a direction that *does* lead
somewhere would be wrongly blocked.

```
            H2
   a ----+---- s1 ---- b
          \
           s2 ---- d       Side a is shared by s1 and s2.
```

### How it works

When a walk leaves a tile through a converging exit, it switches to converging
mode. The `converging` flag is passed on to everything that walk reaches.
In converging mode, paths and nodes are un-marked when the walk backs out of
them. That way, another route can try them again from a different direction.

The check is made when the walk *leaves* a tile. On the example map:

- `x1` leaves H1 over side a. H1 has only one path on side a, so the walk stays
  in normal mode.
- Going around the loop, the walk reaches `s2` from side d and leaves H2 over
  side a. Two paths on H2 share side a, so from there on the walk is in
  converging mode.

### The cost

Converging mode tries **every** route, not just every path. The loop on the
example map gives two ways from H2 to T, so everything past T is walked once
for each way. Every extra loop multiplies the number of routes again. A real
map with a handful of loops can need over a million walk calls to find a few
hundred paths.

## Backtracking

Some games (1837) let a corporation reach a token spot by reversing at a
switch. With `backtracking: true`, at every exit the walk may also step into
the other paths on the same tile that share that exit. On the example map, a
walk on `s1` that reaches side a may step onto `s2` and carry on to side d.
That is exactly the reversal a train is not allowed to make.

Each of those extra steps passes a converging exit, so with backtracking
almost every walk ends up in converging mode. Graphs with backtracking (such as
1837's token graph) are the ones that most need the pruner.

## Graph::Pruner

### The idea

`compute` only cares about *new* paths. Any path it has already recorded is
ignored. So in converging mode, before walking down a path, the walk asks:
"Is there anything down here I haven't already found?" If the answer is no, it
skips that path and everything behind it.

`Graph::Pruner` answers that question cheaply by grouping the network into
islands of connected track.

### Building the islands

The islands are built once per `compute`, the first time the walk enters
converging mode. Normal walks never pay for it.

Starting from the token cities, two paths are put on the same island if they
touch in any of these ways:

1. **Across a hex border.** `x1` joins `s1` and `s2` across side a. `s1` joins
   `t1` across side b.
2. **Sharing an edge on the same tile** (only with `backtracking`). `s1` and
   `s2` both end at side a on H2.
3. **Through a node.** `t1`, `t2`, `t3` and `t4` all touch town T. Terminal
   paths do not lead into their node, so a node whose paths are all terminal
   does not join them.
4. **Through a junction.** All paths on the same junction.

Only two things stop an island from growing:

- **The corporation's own token cities.** The walk never passes through them.
  Here those are X and Y.
- **Cities that `blocks?` the corporation.** Here that is Z.

Paths the walk can never use (`skip_paths`, `skip_track`, terminal paths with
a junction) are left out.

For A on the example map, this gives two islands:

| Island | Paths | Why it is separate |
| --- | --- | --- |
| 1 | `x1`, `s1`, `s2`, `t1`, `t2`, `t3`, `t4`, `p1`, `y1`, `z1` | The main network |
| 2 | `x2`, `r1` | Only joined to island 1 through X, which is a wall |

`z2` and `w1` are on no island. Building starts from the token cities and
never passes through a wall, so it never gets past Z. The walk can't get there
either, so the pruner is never asked about them.

### Why loose islands are safe

The islands ignore most of the walk's rules: gauge, lanes, crossing an edge
twice, visiting a node twice and reversing at a switch. Ignoring a rule can
only make an island bigger, never smaller. So everything the walk could reach
from a path is always on that path's island.

A bigger island only means the pruner skips less often. It never causes a
wrong skip.

The walls matter. If X were not a wall, islands 1 and 2 would be one island.
The walk from X goes down `x1` first, and `x2` and `r1` are not found until
that whole branch is finished. So the island could not be complete, and
nothing could be skipped, while the walk is inside `x1`'s branch. With X as a
wall, island 1 is complete once its ten paths are found. All of them are
inside `x1`'s branch, so any later converging-mode step in that branch can be
skipped.

### The skip check

In converging mode, `Path#walk` calls `pruner.prune?(path)`. It returns true
when every path on that path's island is already recorded. Each island keeps a
cursor so already-found members are not checked again.

Example: the walk from Y goes `y1`, then T, then `t1`, then `s1`, and leaves H2
over side a, so it is now in converging mode. Next it would walk `x1`. All ten
paths on island 1 were already found by the walk from X, so `prune?(x1)`
returns true and the walk skips `x1` and everything behind it.

### Why the results do not change

1. **Nothing new is missed.** Everything reachable from the skipped path is on
   its island, and the whole island is already recorded.
2. **Nothing else changes.** In converging mode, a walk un-marks everything as
   it backs out, so a skipped section would not have left anything behind.
3. **The order stays the same.** Paths are only skipped when nothing new could
   appear, so new paths are found in the same order as without pruning.

On a real 1837 map with switches and several loops, this cut one token
graph from about 1.5 million walk calls to about 33,000, with the same output.

### Who uses it

Only `Graph#compute` passes a pruner. Other callers of `walk` need every
*route*, not just every path, so they must not be pruned:

- `AutoRouter` and `Route#get_node_chains` build every possible chain of track
  between stops.
- 1870's destination check looks for a route home that is short enough.
- 1828's `route_uses_tile_lay` checks whether a route uses the tile just laid.

These callers leave `pruner` as `nil`, and the walk behaves as it did before.

## Debugging

`Graph#walk_calls(corp)` returns how many walk calls the last `compute` made:

- `all`: every call
- `not_skipped`: calls that passed the checks at the top of the walk
- `skipped`: the difference

`compute` also logs these counts at debug level:

```ruby
Engine::Logger.set_level(Logger::DEBUG)
game.graph.connected_paths(corporation)
# Graph computed with 26089 completed walk calls (skipped 6749)
```
