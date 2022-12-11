import std/core

type tree<a>
  Leaf
  Node { value : a; left : tree<a>; right : tree<a> }

fun fold2( tree : tree<a>, init : b, f : (b, a) -> e b ) : e b
  match tree
    Leaf -> init
    Node(value, left, right) ->
      val rightInit = left.fold2(f(init, value), f)
      right.fold2(rightInit, f)


type tree3<a>
  Leaf3
  Node3 { value : a; left : tree3<a>; middle : tree3<a>; right : tree3<a> }

fun fold3( tree : tree3<a>, init : b, f : (b, a) -> e b ) : e b
  match tree
    Leaf3 -> init
    Node3(value, left, middle, right) ->
      val middleInit = left.fold3(f(init, value), f)
      val rightInit = middle.fold3(middleInit, f)
      right.fold3(rightInit, f)


struct treeN<a> { value : a; children : list<treeN<a>> }

fun foldN( tree : treeN<a>, init : b, f : (b, treeN<a>) -> e b ) : e b
  tree.children.foldl(f(init, tree)) fn(acc, child) child.foldN(unsafe-decreasing(acc), f)


fun main() : console ()
  val a = TreeN(1, [])
  val b = TreeN(2, [])
  val c = TreeN(3, [])
  val d = TreeN(4, [])
  val e = TreeN(5, [a, b, a])
  val f = TreeN(6, [c, d, c])
  val g = TreeN(7, [e, f])

  val result = g.foldN(0) fn(acc, node) acc + node.value

  println(result)
