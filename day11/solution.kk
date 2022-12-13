import utils
import map
import set
import parse
import generator
import std/core


alias item = int;
alias items = map<id, list<item>>;
alias id = int;
alias operation = item -> item;

struct monkey { operation : operation; condition : int; if-true : id; if-false : id }
alias monkeys = map<id, monkey>;


effect fun inspect( monkey : id ) : ()


type term
  Old
  Operand { value : int }

fun term() : parse term
  fun old() : parse term
    pstring("old")
    Old

  fun operand() : parse term
    Operand(int())

  old || operand

fun operation() : parse operation
  pstring("Operation: new = ")

  val a = term()
  whitespace()
  val operator : (item, item) -> item = match one-of("+*")
    '*' -> (*)
    '+' -> (+)
    op -> fail("Matched operand other than + or * :: " ++ op.show)
  whitespace()
  val b = term()

  match (a, b)
    (Old, Old) -> fn(x) operator(x, x)
    (Old, Operand(y)) -> fn(x) operator(x, y)
    (Operand(y), Old) -> fn(x) operator(y, x)
    (Operand(x), Operand(y)) -> fn(_) operator(x, y)
    _ -> fail("Invalid operand combination")

fun monkey() : parse (id, monkey, list<item>)
  pstring("Monkey ")
  val id : id = int()
  pstring(":")
  whitespace()

  pstring("Starting items: ")
  val items : list<item> = int.separated(", ".lit)
  whitespace()

  val operation = operation()
  whitespace()

  pstring("Test: divisible by ")
  val condition = int()
  whitespace()

  pstring("If true: throw to monkey ")
  val if-true = int()
  whitespace()

  pstring("If false: throw to monkey ")
  val if-false = int()
  whitespace()

  (id, Monkey(operation, condition, if-true, if-false), items)

fun monkeys() : <parse,cmp<id>> (monkeys, items)
  many(monkey).foldl((Leaf, Leaf)) fn((monkeys, held-items), (id, monkey, items))
    (monkeys.insert'(id, monkey), held-items.insert'(id, items))


fun destination( monkey : monkey, item : item )
  if monkey.condition.divides(item) then monkey.if-true else monkey.if-false

fun step( monkeys : monkeys, all-items: items, decrease : item -> item ) : <exn,cmp<int>,inspect> items
  all-items.fold-keys(all-items) fn(items-acc, id)
    val monkey = monkeys.get(id).unjust
    val cur-items : list<item> = items-acc.get(id).unjust

    cur-items.foldl(items-acc.insert'(id, [])) fn(items-acc', item)
      inspect(id)

      val new-item = monkey.operation()(item).decrease
      val dest = monkey.destination(new-item)

      items-acc'.insert'(dest, items-acc'.get(dest).unjust ++ [new-item])


fun run-part( items : items, monkeys : monkeys, iterations : int, decrease : item -> item ) : <exn,cmp<id>> int
  var tracker : map<id, int> := Leaf
  with fun inspect( monkey : id )
    tracker := tracker.insert-with(monkey) fn(x) x.default(0) + 1
  
  list(1, iterations).foldl(items) fn(acc : items, i)
    val res = step(monkeys, acc, decrease)

    if i == iterations then
      tracker.foreach fn(id, count)
        debug(id.show ++ ": " ++ count.show)
    
    res
  
  with reverse
  tracker.values.sorted.take(2).generate.foldl(1, (*))

fun solution( input : string ) : exn (string, string)
  with cmp-int

  val (monkeys, items) = input.parse-exn(monkeys)
  val monkey-conditions-lcm = monkeys.values.map(condition).generate.lcm

  val part1 = run-part(items, monkeys, 20) fn(x) x / 3
  debug("\n\n")
  val part2 = run-part(items, monkeys, 10000) fn(x) x % monkey-conditions-lcm

  (part1.show, part2.show)

fun main() { run(11, solution) }