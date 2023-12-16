/*
branch_addr.vh
9/17/23
Michael Fuchs
437-03
Version 1.0
abstracted sign_extend interface
*/
`ifndef SIGN_EXTEND_IF_VH
`define SIGN_EXTEND_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface sign_extend_if;
  // import types
  import cpu_types_pkg::*;

  logic     LUI, SignExtend;

  word_t    InstrE, Instruction;

  // register file ports
  modport se (
    input   LUI, SignExtend, Instruction,
    output  InstrE
  );
  // register file tb
  modport tb (
    input   InstrE,
    output  LUI, SignExtend, Instruction
  );
endinterface

`endif //SIGN_EXTEND_IF_VH
