import utils


fun parse-pair ( s : string, separator : string, parser : (string) -> e maybe<a> ) : e maybe<(a, a)>
  match s.split(separator).map(parser)
    [Just(a), Just(b)] -> Just((a, b))
    _ -> Nothing


struct range( start : int, end : int )

fun to-range( (start, end) : (int, int) ) : total range
  Range(start, end)

fun parse-range( s : string ) : total maybe<range>
  s.parse-pair("-", fn(part) part.parse-int()).map(to-range)

fun fully-contains( self : range, other : range ) : total bool
  other.start >= self.start && other.end <= self.end

fun overlaps( self : range, other : range) : total bool
  self.start <= other.start && other.start <= self.end || // other starts inside self
    self.start <= other.end && other.end <= self.end || // other ends inside self
    other.fully-contains(self)


fun solution( input : string ) : total (int, int)
  val pairs : list<(range, range)> = input.lines.filter-map fn(line)
    line.parse-pair(",", parse-range)
  
  val part1 = pairs.count(fn((a, b)) a.fully-contains(b) || b.fully-contains(a))
  val part2 = pairs.count(fn((a, b)) a.overlaps(b))

  (part1, part2)

fun main() { run(4, solution) }