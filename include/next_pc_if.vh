/*
next_pc_if.vh
9/17/23
Michael Fuchs
437-03
Version 1.0
abstracted next_pc interface
*/
`ifndef NEXT_PC_IF_VH
`define NEXT_PC_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface next_pc_if;
  // import types
  import cpu_types_pkg::*;

  logic     Zero, BNE, Jump, JumpReg, JAL, Branch, stall;

  word_t    BranchAddr, JumpAddr, PC4, rdat1, next_PC;

  // register file ports
  modport npc (
    input   BranchAddr, JumpAddr, PC4, rdat1, Zero, BNE, JumpReg, JAL, Branch, Jump, stall,
    output  next_PC
  );
  // register file tb
  modport tb (
    input   next_PC,
    output  BranchAddr, JumpAddr, PC4, rdat1, Zero, BNE, JumpReg, JAL, Branch, Jump, stall
  );
endinterface

`endif //NEXT_PC_IF_VH
