  .text
  .align  2
  .global main
  .type   main, @function
main:
  push.s  { $fp $lp }
  addi    $fp, $sp, 8
  addi    $sp, $sp, -16
  movi  $r0, 1
  swi   $r0, [$fp + (-16)]
  movi  $r0, 2
  swi   $r0, [$fp + (-20)]
  movi  $r0, 3
  swi   $r0, [$fp + (-24)]
  movi  $r0, 5
  swi   $r0, [$fp + (-12)]
  lwi   $r0, [$fp + (-16)]
  addi  $r1, $r0, 3
  movi  $r0, 4
  mul   $r0, $r1, $r0
  addi  $r0, $r0, -5
  swi   $r0, [$fp + (-20)]
  movi  $r0, 0
  addi    $sp, $fp, -8
  pop.s   { $fp $lp }
  ret
  .size   main, .-main
  .ident  "GCC: (GNU) 4.9.0"
