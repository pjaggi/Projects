/*
branch_addr.sv
9/17/23
Michael Fuchs
437-03
Version 1.1
abstracted branch address calculation for datapath
*/
`include "branch_addr_if.vh"
module branch_addr (branch_addr_if.b ba);
    assign ba.BranchAddr = ba.PC4 + (ba.InstrE << 2);
endmodule
