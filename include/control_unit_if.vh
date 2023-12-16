 /*
  9//23
  Michael Fuchs
  437-03
  Version 1.0
  control unit interface
*/
`ifndef CONTROL_UNIT_IF_VH
`define CONTROL_UNIT_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface control_unit_if;
  // import types
  import cpu_types_pkg::*;

  logic RegDst, Jump, JumpReg, JAL, Branch, BNE, MemRead, MemToReg, MemWrite, ALUSrc, RegWrite, Halt, SignExtend, LUI, dhit, ihit, datomic;
  
  word_t Instruction;

  aluop_t ALUOp;

  // program counter ports
 
 modport cm (
    input   Instruction, dhit, ihit,
    output  RegDst, Jump, JumpReg, JAL, Branch, BNE, MemRead, MemToReg, MemWrite, ALUSrc, RegWrite, Halt, SignExtend, LUI, ALUOp, datomic
  );
  // register file tb
  modport tb (
    input   RegDst, Jump, JumpReg, JAL, Branch, BNE, MemRead, MemToReg, MemWrite, ALUSrc, RegWrite, Halt, SignExtend, LUI, ALUOp, datomic,
    output  Instruction, dhit, ihit
  );

endinterface

`endif //CONTROL_UNIT_IF_VH
