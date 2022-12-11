pub import map

alias set<a> = map<a, ()>

fun insert( set : set<a>, value : a ) : cmp<a> set<a>
  set.insert(value, ()).fst

fun foreach ( set : set<a>, f : a -> e () ) : e ()
  set.foreach fn(value, _) f(value)
