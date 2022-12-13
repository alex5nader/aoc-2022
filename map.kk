import generator

type map<k, v>
  Leaf
  Node { key : k; value : v; left : map<k, v>; right : map<k, v> }

effect<k> fun cmp( a : k, b : k ) : order

fun cmp-int( f : () -> <cmp<int>|e> a ) : e a
  with fun cmp( a : int, b : int )
    a.compare(b)
  
  f()

fun reverse( f : () -> <cmp<a>|e> b ) : <cmp<a>|e> b
  with override fun cmp(a, b)
    b.cmp(a)
  
  f()


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

fun insert'( map : map<k, v>, key : k, value : v) : cmp<k> map<k, v>
  val (new-map, _) = map.insert(key, value)
  new-map

fun insert-with( map : map<k, v>, key : k, value : maybe<v> -> v ) : cmp<k> map<k, v>
  match map
    Leaf -> Node(key, value(Nothing), Leaf, Leaf)
    Node(cur-key, cur-value, left, right) -> match key.cmp(cur-key)
      Eq -> Node(key, value(Just(cur-value)), left, right)
      Lt -> Node(cur-key, cur-value, left.insert-with(key, value), right)
      Gt -> Node(cur-key, cur-value, left, right.insert-with(key, value))

fun get-or-insert( map : map<k, v>, key : k, default : () -> v ) : cmp<k> (map<k, v>, v)
  match map
    Leaf ->
      val value = default()
      (Node(key, value, Leaf, Leaf), value)
    Node(cur-key, cur-value, left, right) -> match key.cmp(cur-key)
      Eq -> (map, cur-value)
      Lt ->
        val (new-left, value) = left.get-or-insert(key, default)
        (Node(cur-key, cur-value, new-left, right), value)
      Gt ->
        val (new-right, value) = right.get-or-insert(key, default)
        (Node(cur-key, cur-value, left, new-right), value)

fun get( map : map<k, v>, key : k ) : cmp<k> maybe<v>
  match map 
    Leaf -> Nothing
    Node(cur-key, value, left, right) -> match key.cmp(cur-key)
      Eq -> Just(value)
      Lt -> left.get(key)
      Gt -> right.get(key)

fun get-or( map : map<k, v>, key : k, value : v ) : cmp<k> v
  map.get(key).default(value)

fun has( map : map<k, v>, key : k ) : cmp<k> bool
  map.get(key).is-just

fun entries( map : map<k, v> ) : generator<(k, v)>
  fun generator(m)
    match m
      Leaf -> ()
      Node(key, value, left, right) ->
        generator(left)
        yield((key, value))
        generator(right)

  fn() generator(map)

fun keys( m : map<k, _> ) : generator<k>
  m.entries.map fn((key, _)) key

fun values( m : map<_, v> ) : generator<v>
  m.entries.map fn((_, value)) value


fun size( map : map<_, _> ) : int
  match map
    Leaf -> 0
    Node(_, _, left, right) -> 1 + left.size + right.size

fun min'( map : map<k, v> ) : map<k, v>
  match map
    Leaf -> Leaf
    Node(_, _, Leaf, _) -> map
    Node(_, _, left, _) -> left.min'

fun remove( map : map<k, v>, key : k ) : cmp<k> (map<k, v>, maybe<v>)
  match map
    Leaf -> (Leaf, Nothing)
    Node(cur-key, value, left, right) -> match key.cmp(cur-key)
      Eq ->
        val new-tree = match (left, right)
          (Leaf, Leaf) -> Leaf
          (child as Node(_, _, _, _), Leaf) -> child
          (Leaf, child as Node(_, _, _, _)) -> child
          _ -> match right.min'
            Leaf -> Leaf
            Node(succ-key, succ-value, _, _) ->
              Node(succ-key, succ-value, left, right.remove(succ-key).fst)

        (new-tree, Just(value))
      Lt ->
        val (new-left, removed) = left.remove(key)
        (Node(cur-key, value, new-left, right), removed)
      Gt ->
        val (new-right, removed) = right.remove(key)
        (Node(cur-key, value, left, new-right), removed)

fun remove'( map : map<k, v>, key : k ) : cmp<k> map<k, v>
  map.remove(key).fst

fun foreach( map : map<k, v>, f : (k, v) -> e () ) : e ()
  map.entries.foreach fn((k, v)) f(k, v)

fun fold( map : map<k, v>, acc : a, f : (a, k, v) -> e a ) : e a
  match map
    Leaf -> acc
    Node(key, value, left, right) ->
      val acc' = left.fold(acc, f)
      val acc'' = f(acc', key, value)
      right.fold(acc'', f)

fun fold-keys( map : map<k, v>, acc : a, f : (a, k) -> e a ) : e a
  map.fold(acc) fn(a, k, _) f(a, k)

fun map( list : list<(a, b)> ) : cmp<a> map<a, b>
  list.foldl(Leaf) fn(map, (key, value)) map.insert'(key, value)
