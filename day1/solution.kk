import utils


fun max-n ( list : list<int>, n : int ) : list<int>
  fun recurse ( depth : int, acc : list<int>, new : int ) : list<int>
    if depth == n then Nil
    else match acc
      Nil -> single(new)
      Cons(current, rest) ->
        if new > current then
          Cons(new, acc)
        else
          Cons(current, recurse(depth + 1, rest, new))

  list.foldl(Nil, fn(acc, x) recurse(0, acc, x))


fun max ( list : list<int> ) : int
  list.max-n(1).sum


fun main ()
  val input = read-input(1)
  val calorie-groups = input.split("\n\n").map(lines)

  val totals = calorie-groups.map fn(group)
    group.map(fn(s) parse-int(s).default(0)).sum

  println("Part 1: " ++ totals.max.show)
  println("Part 2: " ++ totals.max-n(3).sum.show)
