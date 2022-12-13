pub import std/text/parse
import utils

fun parse-exn( input : string, parser : () -> <parse,exn|e> a ) : <exn|e> a
  match input.slice.parse(parser)
    ParseOk(result, rest) ->
      debug(rest.string)
      result
    ParseError(message, rest) ->
      val msg = "Expected `" ++ message ++ "` at " ++ (input.count - rest.count).show ++ "\nRemaining:\n`" ++ rest.show ++ "`"
      throw(msg)


fun (<~)( a : parser<e, a>, b : parser<e, _> ) : parser<e, a>
  fn()
    val res = a()
    b()
    res
fun (~>)( a : parser<e, _>, b : parser<e, b> ) : parser<e, b>
  fn()
    a()
    b()


fun separated( item : parser<e, a>, sep : parser<e, _> ) : <parse|e> list<a>
  val head = item()
  val tail = many(sep ~> item)

  Cons(head, tail)


fun int() : parse int
  match digits().parse-int
    Just(x) -> x
    Nothing -> fail("integer")

fun lit( string : string ) : parser<total, string>
  fn() pstring(string)
