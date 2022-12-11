import utils

struct xy { x : int; y : int }

fun get( Xy(x, y) : xy, direction : direction ) : int
  match direction
    North -> y
    South -> y
    West -> x
    East -> x

fun show( Xy(x, y) : xy ) : string
  "(" ++ x.show ++ ", " ++ y.show ++ ")"

effect val bounds : xy
effect val trees : list<list<int>>

fun positions() : bounds list<xy>
  list(0, bounds.x).cartesian-product-with(list(0, bounds.y), Xy)

fun tree( pos : xy ) : trees maybe<int>
  trees[pos.y].and-then fn(row) row[pos.x]


type direction
  North
  West
  South
  East

fun show( direction : direction ) : string
  match direction
    North -> "North"
    West -> "West"
    South -> "South"
    East -> "East"

val all-directions = [North, West, South, East]

fun walk( start : xy, direction : direction ) : bounds list<xy>
  match direction
    North -> list(0, start.y - 1).reverse.map fn(y) Xy(start.x, y)
    West -> list(0, start.x - 1).reverse.map fn(x) Xy(x, start.y)
    South -> list(start.y + 1, bounds.y).map fn(y) Xy(start.x, y)
    East -> list(start.x + 1, bounds.x).map fn(x) Xy(x, start.y)


fun is-visible( pos : xy ) : <trees,bounds> bool
  if pos.x == 0 || pos.y == 0 || pos.x == bounds.x || pos.y == bounds.y then True
  else match tree(pos)
    Nothing -> False
    Just(height) ->
      all-directions.any fn(dir)
        pos.walk(dir).filter-map(tree).all fn(tree) tree < height

fun scenic-score( pos : xy ) : <trees,bounds> maybe<int>
  with height <- tree(pos).map

  val scores = all-directions.map fn(dir)
    val path = pos.walk(dir)
    
    val dist = path.filter-map(tree).index-of fn(tree) tree >= height
    if dist == -1 then
      path.length
    else
      // index-of starts at 0, but first position when walking is distance of 1
      dist + 1

  scores.foldl(1, (*))



fun parse-trees( input : string ) : list<list<int>>
  with line <- input.lines.map
  with char <- line.list.map

  char.int - '0'.int


fun solution( input : string ) : exn (string, string)
  with val trees = input.parse-trees
  with val bounds = Xy(trees[0].unjust.length - 1, trees.length - 1)

  val part2 = positions()
    .filter-map(fn(p) p.scenic-score.map(fn(s) (p, s)))
    .max-by(snd) 
    .default((Xy(-1, -1), -1)).show-tuple(show, show)

  (positions().count(is-visible).show, part2)

fun main() { run(8, solution) }