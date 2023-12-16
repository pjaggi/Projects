/*
alu_abstract.sv
9/17/23
Michael Fuchs
437-03
Version 1.0
abstracted alu for datapath
*/

`ifndef ALU_ABSTRACT_IF_VH
`define ALU_ABSTRACT_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface alu_abs_if;
  // import types
  import cpu_types_pkg::*;

  logic neg, over, zero, ALUSrc;
  aluop_t ALUOP;
  word_t    rdat1, rdat2, InstrE, outport;

  // alu ports
  modport aluabs (
    input   rdat1, rdat2, InstrE, ALUOP, ALUSrc,
    output  outport, neg, over, zero
  );
  // alu tb
  modport tb (
    input   outport, neg, over, zero,
    output  rdat1, rdat2, InstrE, ALUOP, ALUSrc
  );
endinterface

`endif //REGISTER_FILE_IF_VH
