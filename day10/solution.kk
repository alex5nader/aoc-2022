import utils


effect fun tick( clock : int, reg : int ) : ()

effect cpu
  fun noop() : ()
  fun addx( x : int ) : ()

fun cpu( f : () -> <cpu,tick|e> b ) : <tick|e> b
  var clock := 0
  var reg := 1

  with override fun tick(_, _)
    clock := clock.inc
    tick(clock, reg)

  with handler<cpu>
    fun noop()
      tick(clock, reg)
    fun addx( x : int )
      tick(clock, reg)
      tick(clock, reg)
      reg := reg + x
  
  f()


fun crt( f : () -> <tick|e> a ) : <tick|e> (a, string)
  var result := ""

  with override fun tick(clock, reg)
    val draw-pos = (clock - 1) % 40

    if reg - 1 <= draw-pos && draw-pos <= reg + 1 then
      result := result ++ "#"
    else
      result := result ++ "."

    if draw-pos == 39 then
      result := result ++ "\n"
    debug(result)

    tick(clock, reg)

  (mask<local>(f), result)


type instruction
  Noop
  Addx { x : int }

fun run( inst : instruction ) : cpu ()
  match inst
    Noop -> noop()
    Addx(x) -> addx(x)


fun run( program : list<instruction> ) : (int, string)
  var total-strength := 0
  with fun tick(clock, reg)
    if (clock - 20) % 40 == 0 then
      total-strength := total-strength + clock * reg

  with crt
  with cpu
    
  program.foreach(run)
  total-strength


fun parse-program( input : string ) : list<instruction>
  with line = input.lines.filter-map

  match line.split(" ")
    ["noop"] -> Just(Noop)
    ["addx", x] -> x.parse-int().map fn(xx) Addx(xx)
    _ -> Nothing


fun solution( input : string ) : (string, string)
  val program = input.parse-program()

  val (signal-strength, image) = program.run()

  (signal-strength.show, "\n" ++ image)


fun main() { run(10, solution) }