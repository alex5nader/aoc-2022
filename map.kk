type map<k, v>
  Leaf
  Node { key : k; value : v; left : map<k, v>; right : map<k, v> }

effect<k> fun cmp( a : k, b : k ) : order

fun insert( map : map<k, v>, key : k, value : v ) : cmp<k> (map<k, v>, maybe<v>)
  match map
    Leaf -> (Node(key, value, Leaf, Leaf), Nothing)
    Node(cur-key, cur-value, left, right) -> match key.cmp(cur-key)
      Eq -> (Node(key, value, left, right), Just(cur-value))
      Lt ->
        val (new-left, old-value) = left.insert(key, value)
        (Node(cur-key, cur-value, new-left, right), old-value)
      Gt ->
        val (new-right, old-value) = right.insert(key, value)
        (Node(cur-key, cur-value, left, new-right), old-value)

fun get( map : map<k, v>, key : k ) : cmp<k> maybe<v>
  match map 
    Leaf -> Nothing
    Node(cur-key, value, left, right) -> match key.cmp(cur-key)
      Eq -> Just(value)
      Lt -> left.get(key)
      Gt -> right.get(key)

fun has( map : map<k, v>, key : k ) : cmp<k> bool
  map.get(key).is-just

fun size( map : map<_, _> ) : int
  match map
    Leaf -> 0
    Node(_, _, left, right) -> 1 + left.size + right.size

fun foreach( map : map<k, v>, f : (k, v) -> e ()) : e ()
  match map
    Leaf -> ()
    Node(key, value, left, right) ->
      left.foreach(f)
      f(key, value)
      right.foreach(f)
