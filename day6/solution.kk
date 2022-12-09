import utils
import generator


fun sliding-windows( list : list<a>, size : int ) : (() -> yield<list<a>> ())
  fun slide( remaining : list<a> ) : yield<list<a>> ()
    if remaining.length >= size then
      yield(remaining.take(size))
      slide(unsafe-decreasing(remaining.drop(1)))

  fn()
    if size > 0 then slide(list)


fun has-duplicate( list : list<char>, eq : (char, char) -> bool ) : bool
  fun has-duplicate-of( remaining : list<char>, item : char, (==) : (char, char) -> bool ) : bool
    match remaining
      Nil -> False
      Cons(next, _) | item == next -> True
      Cons(_, tail) -> tail.has-duplicate-of(item, (==))

  match list
    Nil -> False
    Cons(head, tail) -> tail.has-duplicate-of(head, eq) || tail.has-duplicate(eq)


fun all-unique( list : list<char> ) : bool
  !list.has-duplicate((==))


fun solve-size( input : string, size : int ) : string
  val windows = input.list.sliding-windows(size)

  (windows.index-of(all-unique) + size).show

fun solution( input : string ) : (string, string)
  (input.solve-size(4), input.solve-size(14))


fun main() { run(6, solution) }