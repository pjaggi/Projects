/*
jump_addr.sv
9/17/23
Michael Fuchs
437-03
Version 1.1
abstracted jump address calculation for datapath
*/
`include "jump_addr_if.vh"
module jump_addr (jump_addr_if.j jump_addr);
    assign jump_addr.JumpAddr = {jump_addr.PC4[31:28], (jump_addr.Instruction[25:0] << 2)};
endmodule