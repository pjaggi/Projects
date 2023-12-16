/*
  8/24/23
  Michael Fuchs
  437-03
  Version 1.0
  alu file interface
*/
`ifndef ALU_FILE_IF_VH
`define ALU_FILE_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface alu_file_if;
  // import types
  import cpu_types_pkg::*;

  logic     neg, zero, over;
  aluop_t   ALUOP;
  word_t    porta, portb, outport;

  // register file ports
  modport alu (
    input   porta, portb, ALUOP,
    output  neg, zero, over, outport
  );
  // register file tb
  modport tb (
    input   neg, zero, over, outport,
    output  porta, portb, ALUOP
  );
endinterface

`endif //ALU_FILE_IF_VH
