import utils
import set


struct xy { x : int; y : int }

val zero : xy = Xy(0, 0)

fun (+)( a : xy, b : xy ) : xy
  Xy(a.x + b.x, a.y + b.y)
fun (-)( a : xy, b : xy ) : xy
  Xy(a.x - b.x, a.y - b.y)

fun show( Xy(x, y) : xy ) : string
  "(" ++ x.show ++ ", " ++ y.show ++ ")"

type direction
  North
  West
  South
  East

fun delta( dir : direction ) : xy
  match dir
    North -> Xy(0, -1)
    West -> Xy(-1, 0)
    South -> Xy(0, 1)
    East -> Xy(1, 0)

fun parse-dir( input : string ) : maybe<direction>
  match input.head
    "U" -> Just(North)
    "L" -> Just(West)
    "D" -> Just(South)
    "R" -> Just(East)
    _ -> Nothing

fun show( dir : direction ) : string
  match dir
    North -> "U"
    West -> "L"
    South -> "D"
    East -> "R"


fun parse-step( line : string ) : maybe<(direction, int)>
  match line.split(" ")
    [dir-text, dist-text] ->
      with dir <- parse-dir(dir-text).and-then
      with dist <- dist-text.parse-int.map

      (dir, dist)
    _ -> Nothing

fun parse-steps( input : string ) : list<direction>
  input.lines.filter-map(parse-step).flatmap fn((dir, dist)) dir.repeat(dist)


fun chase( tail : xy, head : xy ) : xy
  match head - tail
    Xy(0, -2) -> tail + North.delta
    Xy(-2, 0) -> tail + West.delta
    Xy(0, 2) -> tail + South.delta
    Xy(2, 0) -> tail + East.delta
    Xy(x, y) | (x <= -2 && y < 0) || (x < 0 && y <= -2) -> tail + North.delta + West.delta
    Xy(x, y) | (x <= -2 && y > 0) || (x < 0 && y >= 2) -> tail + South.delta + West.delta
    Xy(x, y) | (x >= 2 && y < 0) || (x > 0 && y <= -2) -> tail + North.delta + East.delta
    Xy(x, y) | (x >= 2 && y > 0) || (x > 0 && y >= 2) -> tail + South.delta + East.delta
    _ -> tail


struct state { visited : set<xy>; rope : list<xy> }

fun solve-rope-length( steps : list<direction>, rope-size : int ) : int
  with fun cmp( a : xy, b : xy )
    match a.x.compare(b.x)
      Lt -> Lt
      Gt -> Gt
      Eq -> a.y.compare(b.y)

  val initial-rope = zero.repeat(rope-size)
  val final-state = steps.foldl(State(Leaf, initial-rope)) fn(State(visited, rope), step)
    val new-rope = rope.scanl1(
      fn(head) head + step.delta,
      fn(first, second) second.chase(first)
    )

    val new-visited = match new-rope.last
      Nothing -> visited
      Just(last) -> visited.insert(last)

    State(new-visited, new-rope)

  final-state.visited.size


fun solution( input : string ) : (string, string)
  val steps = input.parse-steps

  (steps.solve-rope-length(2).show, steps.solve-rope-length(10).show)


fun main() { run(9, solution) }