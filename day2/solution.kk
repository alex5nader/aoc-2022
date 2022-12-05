import utils


type outcome
  Win
  Lose
  Draw

fun score ( outcome : outcome ) : int
  match outcome
    Win -> 6
    Lose -> 0
    Draw -> 3

fun to-outcome ( text : string ) : maybe<outcome>
  match text
    "X" -> Just(Lose)
    "Y" -> Just(Draw)
    "Z" -> Just(Win)
    _ -> Nothing


type play
  Rock
  Paper
  Scissors

fun score ( play : play ) : int
  match play
    Rock -> 1
    Paper -> 2
    Scissors -> 3

fun to-play ( text : string ) : maybe<play>
  match text
    "A" -> Just(Rock)
    "X" -> Just(Rock)
    "B" -> Just(Paper)
    "Y" -> Just(Paper)
    "C" -> Just(Scissors)
    "Z" -> Just(Scissors)
    _ -> Nothing


fun outcome-against ( your-play : play, opponent-play : play ) : outcome
  match (your-play, opponent-play)
    (Rock, Paper)        -> Lose
    (Paper, Scissors)    -> Lose
    (Scissors, Rock)     -> Lose
    (Rock, Rock)         -> Draw
    (Paper, Paper)       -> Draw
    (Scissors, Scissors) -> Draw
    (Paper, Rock)        -> Win
    (Scissors, Paper)    -> Win
    (Rock, Scissors)     -> Win
    _ -> Win // unreachable

fun cause-outcome ( opponent-play : play, outcome : outcome ) : play
  match (opponent-play, outcome)
    (Paper, Lose)    -> Rock
    (Scissors, Lose) -> Paper
    (Rock, Lose)     -> Scissors
    (Rock, Draw)     -> Rock
    (Paper, Draw)    -> Paper
    (Scissors, Draw) -> Scissors
    (Rock, Win)      -> Paper
    (Paper, Win)     -> Scissors
    (Scissors, Win)  -> Rock
    _ -> Rock // unreachable


fun to-tuple2( list : list<a> ) : maybe<(a, a)>
  match list
    Cons(a, Cons(b, _)) -> Just((a, b))
    _ -> Nothing


fun solution( input : string ) : (int, int)
  val rounds = input.lines.filter-map fn(s)
    s.split(" ").to-tuple2.and-then fn ((abc, xyz))
      abc.to-play.map(fn(abc-play) (abc-play, xyz))

  val xyz-play-rounds = rounds.filter-map fn((abc, xyz))
    xyz.to-play.map(fn(xyz-play) (abc, xyz-play))
  val xyz-play-score = xyz-play-rounds.map(fn((opponent, you)) you.total-score-against(opponent)).sum

  val xyz-outcome-rounds = rounds.filter-map fn((abc, xyz))
    xyz.to-outcome.map(fn(xyz-outcome) (abc, xyz-outcome))
  val xyz-outcome-score = xyz-outcome-rounds.map(fn((opponent, outcome)) opponent.cause-outcome(outcome).score + outcome.score).sum

  (xyz-play-score, xyz-outcome-score)


fun main()
  val input = read-input(2)

  val (part1, part2) = solution(input)
  println("Part 1: " ++ part1.show)
  println("Part 2: " ++ part2.show)
