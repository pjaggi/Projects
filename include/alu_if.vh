/*
  Eric Villasenor
  evillase@gmail.com

  register file interface
*/
`ifndef ALU_IF_VH
`define ALU_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface alu_if;
  // import types
  import cpu_types_pkg::*;

  logic neg, over, zero;
  aluop_t ALUOP;
  word_t    porta, portb, outport;

  // alu ports
  modport alu (
    input   porta, portb, ALUOP,
    output  outport, neg, over, zero
  );
  // alu tb
  modport tb (
    input   outport, neg, over, zero,
    output  porta, portb, ALUOP
  );
endinterface

`endif //REGISTER_FILE_IF_VH
