import utils
import state
import generator
import std/text/parse

struct file { name : string; size : int }
struct dir { name : string; files : list<file>; subdirs : list<dir>; size : int }

fun fold( dir : dir, value : a, f : (a, dir) -> e a ) : e a
  dir.subdirs.foldl(f(value, dir)) fn(acc, subdir) subdir.fold(unsafe-decreasing(acc), f)


fun lit(value : string) : parser<total, string>
  fn()
    pstring(value)

fun ident() : parse string
  alpha.many1.string ++ optional("", fn() pstring(".") ++ alpha.many1.string)

fun ls-entry() : parse maybe<file>
  fun dir() : parse maybe<file>
    pstring("dir ")
    val name = ident()
    whitespace()

    Nothing
  
  fun file() : parse maybe<file>
    with brk throw-exn(exn)
      fail(exn.message)

    val size = digits().parse-int.unjust
    whitespace()
    val name = ident()
    whitespace0()

    Just(File(name, size))
  
  dir || file

// Not actually divergent since text cannot make a directory loop.
// Unfortunately Koka does know this, but unsafe workarounds do not work.
// unsafe-no-div removes the parsing context, causing a crash.
// Since the decreasing value is within the parsing context,
// unsafe-decreasing also cannot be used.
fun dir() : <div,parse> dir
  pstring("$ cd ")
  val dname = "/".lit || ident
  whitespace()

  pstring("$ ls")
  whitespace()

  val files = many(ls-entry).filter-map(id)
  val subdirs = many(unsafe-decreasing(dir))

  val size = files.map(size).sum + subdirs.map(size).sum

  optional(())
    pstring("$ cd ..")
    whitespace()
    ()

  Dir(dname, files, subdirs, size)


fun parse-dir( input : string ) : exn dir
  unsafe-no-div
    match input.slice.parse(dir)
      ParseOk(dir, _) -> dir
      ParseError(message, rest) ->
        val error = "Expected " ++ message ++ " at " ++ (input.count - rest.count).show ++ "\nRemaining:\n`" ++ rest.show ++ "`"
        throw(error)


fun part1( root : dir ) : int
  root.fold(0) fn(total, dir)
    total + (if dir.size > 100000 then 0 else dir.size)


fun part2( root : dir ) : exn int
  val total-size = 70000000
  val update-size = 30000000
  val unused-space = total-size - root.size
  val needed-size = update-size - unused-space

  root
    .fold(Nothing) fn(acc : maybe<int>, dir : dir)
      if dir.size < needed-size then
        acc
      else
        acc.map(fn(best-size) min(best-size, dir.size)) || Just(dir.size)
    .unjust


fun solution( input : string ) : exn (string, string)
  val dir = input.parse-dir()

  (part1(dir).show, part2(dir).show)


fun main() { run(7, solution ) }