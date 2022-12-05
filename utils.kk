import std/core
import std/os/file
import std/os/path


fun run( day : int, solution : (string) -> (int, int) ) : _ ()
  val input = read-input(day)

  val (part1, part2) = solution(input)
  println("Part 1: " ++ part1.show)
  println("Part 2: " ++ part2.show)

fun run( day : int, solution : (string) -> (string, string) ) : _ ()
  val input = read-input(day)

  val (part1, part2) = solution(input)
  println("Part 1: " ++ part1)
  println("Part 2: " ++ part2)


fun read-input( day : int ) : _ string
  val path = cwd() / ("day" ++ day.show) / "input"
  path.read-text-file()

fun count( list : list<a>, pred : a -> bool ) : int
  list.filter(pred).length

fun and-then( maybe : maybe<a>, f : (a) -> e maybe<b> ) : e maybe<b>
  match maybe
    Nothing -> Nothing
    Just(value) -> f(value)

fun contains( list : list<char>, char : char ) : bool
  list.any(fn(c) c == char)

fun transpose( list : list<list<a>> ) : list<list<a>>
  fun transpose-rec( acc : list<list<a>>, ls : list<list<a>> ) : div list<list<a>>
    match ls
      Nil -> acc.reverse
      Cons(Nil, _) -> acc.reverse
      _ -> transpose-rec(Cons(ls.filter-map(head), acc), ls.map(tail))

  unsafe-no-div
    transpose-rec([], list)

fun debug( string : string ) : ()
  unsafe-total { println(string) }

fun also( a : a, f : (a) -> e () ) : e a
  f(a)
  a

fun tap( list : list<a>, f : (a) -> e () ) : e list<a>
  list.map fn(a) a.also(f)

fun minmax( a : int, b : int ) : (int, int)
  if a > b then (a, b) else (b, a)

fun split2( list : list<a>, a-idx : int, b-idx : int ) : maybe<(list<a>, a, list<a>, a, list<a>)>
  match list.split(a-idx)
    (before, Cons(a, rest1)) -> match rest1.split(b-idx - a-idx - 1)
      (middle, Cons(b, end)) -> Just((before, a, middle, b, end))
      _ -> Nothing
    _ -> Nothing

fun show-tuple5(
  (a, b, c, d, e) : (a, b, c, d, e),
  show-a : (a) -> string,
  show-b : (b) -> string,
  show-c : (c) -> string,
  show-d : (d) -> string,
  show-e : (e) -> string
) : string
  a.show-a ++ "," ++ b.show-b ++ "," ++ c.show-c ++ "," ++ d.show-d ++ "," ++ e.show-e
