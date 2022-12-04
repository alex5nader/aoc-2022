import std/os/file
import std/os/path


fun run( day : int, solution : (string) -> total (int, int) ) : _ ()
  val input = read-input(day)

  val (part1, part2) = solution(input)
  println("Part 1: " ++ part1.show)
  println("Part 2: " ++ part2.show)


fun read-input( day : int ) : _ string
  val path = cwd() / ("day" ++ day.show) / "input"
  path.read-text-file()

fun count( list : list<a>, pred : a -> bool ) : total int
  list.filter(pred).length

fun and-then( maybe : maybe<a>, f : (a) -> e maybe<b> ) : e maybe<b>
  match maybe
    Nothing -> Nothing
    Just(value) -> f(value)

fun contains( list : list<char>, char : char ) : total bool
  list.any(fn(c) c == char)
