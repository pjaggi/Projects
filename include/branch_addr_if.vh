/*
branch_addr.vh
9/17/23
Michael Fuchs
437-03
Version 1.0
abstracted branch_addr interface
*/
`ifndef BRANCH_ADDR_IF_VH
`define BRANCH_ADDR_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface branch_addr_if;
  // import types
  import cpu_types_pkg::*;

  word_t    InstrE, PC4, BranchAddr;

  // register file ports
  modport b (
    input   InstrE, PC4,
    output  BranchAddr
  );
  // register file tb
  modport tb (
    input   BranchAddr,
    output  InstrE, PC4
  );
endinterface

`endif //BRANCH_ADDR_IF_VH
