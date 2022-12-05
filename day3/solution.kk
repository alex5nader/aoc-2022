import utils


fun dupes ( a : list<char>, b : list<char> ) : list<char>
  a.filter fn(value-a)
    b.any fn(value-b) value-a == value-b

fun halve ( list : list<char> ) : (list<char>, list<char>)
  list.split(list.length / 2)

fun chunk3( list : list<a> ) : list<(a, a, a)>
  match list
    Cons(a, Cons(b, Cons(c, rest))) -> Cons((a, b, c), chunk3(rest))
    _ -> Nil

fun priority ( char : char ) : int
  val value = char.int
  if 'a'.int <= value && value <= 'z'.int then
    value - 'a'.int + 1
  elif 'A'.int <= value && value <= 'Z'.int then
    value - 'A'.int + 27
  else
    -999999999 // unreachable

fun solution( input : string ) : (int, int)
  val half-dupes =
    with line <- input.lines.filter-map
    val (left, right) = line.list.halve
    left.dupes(right).head
  val part1 = half-dupes.map(priority).sum

  val badges =
    with group <- input.lines.map(list).chunk3.filter-map
    val (a, b, c) = group
    a.dupes(b).dupes(c).head
  val part2 = badges.map(priority).sum

  (part1, part2)

fun main() { run(3, solution) }
