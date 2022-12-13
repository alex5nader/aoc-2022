pub import map
import generator

alias set<a> = map<a, ()>

fun insert( set : set<a>, value : a ) : cmp<a> set<a>
  set.insert(value, ()).fst

fun foreach ( set : set<a>, f : a -> e () ) : e ()
  set.foreach fn(value, _) f(value)

fun sorted( generator : generator<a> ) : cmp<a> generator<a>
  val set = generator.generate.foldl(Leaf) fn(set : set<_>, item) set.insert(item)

  fn()
    set.foreach(yield)
