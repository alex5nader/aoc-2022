import utils
import std/core

alias generator<a> = () -> yield<a> ()

effect<a> ctl yield( item : a ) : ()

fun foreach( generator : () -> <yield<a>|e> (), f : a -> e () ) : e ()
  with ctl yield(item)
    f(item)
    resume(())
  
  generator()

fun map ( generator : generator<a>, f : a -> b ) : generator<b>
  val ret = fn()
    val loop = fn(item)
      yield(f(item))

    generator.foreach(loop)
  
  ret

fun index-of ( generator : generator<a>, f : a -> bool ) : int
  var idx := 0

  with ctl yield(item)
    if f(item) then
      idx
    else
      idx := idx + 1
      resume(())
  
  generator()
  -1

fun drop( generator : generator<a>, count : int ) : generator<a>
  fn()
    var dropped := 0

    with ctl yield(item)
      if dropped == count then
        yield(item)
      else
        dropped := dropped + 1
      resume(())

    generator()

fun take( generator : generator<a>, count : int ) : generator<a>
  fn()
    var taken := 0

    with ctl yield(item)
      yield(item)
      taken := taken + 1

      if taken < count then resume(())

    generator()


fun next( generator : generator<a> ) : maybe<a>
  with ctl yield(item)
    Just(item)
  
  generator()
  Nothing

fun generate( generator : generator<a> ) : list<a>
  with ctl yield(item)
    Cons(item, resume(()))
  
  generator()
  []

fun make-list() : yield<int> ()
  yield(1)
  yield(2)
  yield(3)
