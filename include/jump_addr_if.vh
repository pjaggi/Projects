/*
jump_addr.vh
9/17/23
Michael Fuchs
437-03
Version 1.0
abstracted jump_addr interface
*/
`ifndef JUMP_ADDR_IF_VH
`define JUMP_ADDR_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface jump_addr_if;
  // import types
  import cpu_types_pkg::*;

  word_t    Instruction, PC4, JumpAddr;

  // register file ports
  modport j (
    input   Instruction, PC4,
    output  JumpAddr
  );
  // register file tb
  modport tb (
    input   JumpAddr,
    output  Instruction, PC4
  );
endinterface

`endif //JUMP_ADDR_IF_VH
