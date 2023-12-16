/*
program_counter.sv
9/8/23
Michael Fuchs
437-03
Version 1.0
progam counter
*/

`include "program_counter_if.vh"
import cpu_types_pkg::*;

module program_counter
(
    input logic CLK,
    input logic nRST,
    program_counter_if.pc pcif
);
logic [31:0] nextPC;
parameter PC_INIT = 0;

always_comb begin : nextPCLogic
    nextPC = pcif.PC;
    // if(nRST == 0) begin
    //     nextPC = PC_INIT;//SET TO PARAMETER INIT_PC
    if(!pcif.stall) begin
        nextPC = pcif.next_PC;
    end
end

//Registerize PC
always_ff @( posedge CLK, negedge nRST ) begin : pc_register 
    if(nRST == 0) begin
        pcif.PC <= PC_INIT;
        pcif.PC4 <= PC_INIT + 4;
    end else if(!pcif.stall) begin
        pcif.PC <= nextPC;
        pcif.PC4 <= nextPC + 4;
    end
end

endmodule