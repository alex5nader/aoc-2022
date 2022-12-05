import utils


struct instruction( count : int, src : int, dest : int )

fun show( instruction : instruction ) : string
  "move " ++ instruction.count.show ++ " from " ++ instruction.src.show ++ " to " ++ instruction.dest.show


fun take-two( list : list<a> ) : maybe<(a, a)>
  match list
    [a, b] -> Just((a, b))
    _ -> Nothing


fun parse-crates( line : string ) : list<char>
  fun parse-crate( text : sslice ) : maybe<(char, sslice)>
    match text.next
      Nothing -> Nothing
      Just(('\x00', _)) -> Nothing
      Just((_, after-bracket)) -> match after-bracket.next
        Nothing -> Nothing
        Just((crate, after-crate)) -> Just((crate, after-crate.advance(2)))
 
  fun parse-rec( slice : sslice ) : div list<char>
    match slice.parse-crate
      Nothing -> Nil
      Just((crate, rest)) -> Cons(crate, rest.parse-rec)
  
  unsafe-no-div
    line.slice.parse-rec()

fun parse-stacks( stacks-drawing : string ) : list<list<char>>
  val lines = stacks-drawing.lines
  lines.take(lines.length - 1)
    .map(parse-crates)
    .transpose
    .map(fn(l) l.drop-while(fn(c) c == ' '))


fun parse-instructions( instructions-text : string ) : list<instruction>
  fun parse-instruction( line : string ) : maybe<instruction>
    match line.split(" ")
      [_, count-text, _, src-text, _, dest-text] -> 
        with count = count-text.parse-int.and-then
        with src = src-text.parse-int.and-then
        with dest = dest-text.parse-int.map

        Instruction(count, src - 1, dest - 1)
      _ -> Nothing

  instructions-text.lines.filter-map(parse-instruction)


fun parse( input : string ) : maybe<(list<list<char>>, list<instruction>)>
  with result = input.split("\n\n").take-two.map
  val (stacks-drawing, instructions-text) = result

  (stacks-drawing.parse-stacks(), instructions-text.parse-instructions())

fun run-instruction( stacks : list<list<char>>, instruction : instruction, reverse-when-moving : bool ) : maybe<list<list<char>>>
  val src-idx = instruction.src
  val dest-idx = instruction.dest
  with parts = (if src-idx < dest-idx then
    stacks.split2(instruction.src, instruction.dest)
  else
    stacks.split2(instruction.dest, instruction.src).map (
      fn ((before, dest, between, src, after))
        (before, src, between, dest, after)
    )
  ).map
  val (before, src, between, dest, after) = parts

  val (to-move, new-src) = src.split(instruction.count)
  val new-dest = if reverse-when-moving
    then to-move.reverse ++ dest
    else to-move ++ dest

  if src-idx < dest-idx then
    [before, [new-src], between, [new-dest], after].concat
  else
    [before, [new-dest], between, [new-src], after].concat

fun run-instructions( stacks : list<list<char>>, instructions : list<instruction>, reverse-when-moving : bool ) : maybe<list<list<char>>>
  match instructions
    Nil -> Just(stacks)
    Cons(current-instruction, remaining-instructions) ->
      with stacks-after-instruction = run-instruction(stacks, current-instruction, reverse-when-moving).and-then

      run-instructions(stacks-after-instruction, remaining-instructions, reverse-when-moving)


fun top-crates( stacks : list<list<char>> ) : string
  stacks.map(fn(s) s.head.default(' ')).string


fun solution( input : string ) : (string, string)
  val (stacks, instructions) = input.parse().default(([], []))

  val part1-stacks = run-instructions(stacks, instructions, True).default(["fuck".list])
  val part2-stacks = run-instructions(stacks, instructions, False).default(["fuck".list])

  (part1-stacks.top-crates, part2-stacks.top-crates)

fun main() { run(5, solution) }
