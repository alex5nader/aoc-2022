import utils

effect state<a>
  fun get() : a
  fun set( value : a ) : ()

fun state(init : a, f : () -> <state<a>,div|e> b ) : <div|e> b
  var value := init

  with handler
    fun get() value
    fun set(new-value) value := new-value

  f()
