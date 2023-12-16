/*
  9/8/23
  Michael Fuchs
  437-03
  Version 1.0
  request unit interface
*/
`ifndef REQUEST_UNIT_IF_VH
`define REQUEST_UNIT_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface request_unit_if;
  // import types
  import cpu_types_pkg::*;

  logic     dHit, iHit, halt, memRead, memWrite, dREN, dWEN, iREN;

  word_t    imemload, dmemload, iAddr, dAddr, dIn, iAddrOut, dAddrOut, dmemStore, Instruction, dOut;

  // register file ports
  modport ru (
    input   dHit, iHit, halt, imemload, dmemload, memRead, memWrite, dAddr, iAddr, dIn,
    output  iREN, dREN, dWEN, iAddrOut, dAddrOut, dmemStore, dOut, Instruction
  );
  // register file tb
  modport tb (
    input   iREN, dREN, dWEN, iAddrOut, dAddrOut, dmemStore, dOut, Instruction,
    output  dHit, iHit, halt, imemload, dmemload, memRead, memWrite, dAddr, iAddr, dIn
  );
endinterface

`endif //PROGRAM_COUNTER_IF_VH
