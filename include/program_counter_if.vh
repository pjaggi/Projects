/*
  9/8/23
  Michael Fuchs
  437-03
  Version 1.0
  program counter interface
*/
`ifndef PROGRAM_COUNTER_IF_VH
`define PROGRAM_COUNTER_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface program_counter_if;
  // import types
  import cpu_types_pkg::*;

  logic ihit, stall;

  word_t    PC, next_PC, PC4;

  // program counter ports
  modport pc (
    input   next_PC, ihit, stall,
    output  PC, PC4
  );
  // program counter tb
  modport tb (
    input   PC, PC4,
    output  next_PC, ihit, stall
  );
endinterface

`endif //PROGRAM_COUNTER_IF_VH
