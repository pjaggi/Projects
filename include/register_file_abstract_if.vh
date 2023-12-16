/*
register_file_abstract.vh
9/17/23
Michael Fuchs
437-03
Version 1.1
abstracted register_file interface
*/
`ifndef REGISTER_FILE_ABSTRACT_IF_VH
`define REGISTER_FILE_ABSTRACT_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface register_file_abstract_if;
  // import types
  import cpu_types_pkg::*;

  logic     RegWrite, RegDst, JAL, dREN, MemToReg, ihit, dhit;
  word_t    wdat, rdat1, rdat2, Instruction, lastInstruction, ALUResult, PC4, dload;

  // register file ports
  modport rf (
    input   Instruction, lastInstruction, wdat, ALUResult, PC4, dload, RegWrite, RegDst, JAL, dREN, MemToReg, ihit, dhit,
    output  rdat1, rdat2
  );
  // register file tb
  modport tb (
    input   rdat1, rdat2,
    output  Instruction, lastInstruction, wdat, ALUResult, PC4, dload, RegWrite, RegDst, JAL, dREN, MemToReg, ihit, dhit
  );
endinterface

`endif //REGISTER_FILE_ABSTRACT_IF_VH
