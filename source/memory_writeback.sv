/*
memory_writeback.sv
9/18/23
Pranay Jaggi
437-03
Version 1.0
memory_writeback
*/
`include "cpu_types_pkg.vh"
`include "memory_writeback_if.vh"
//memory_writeback_if mwif();
module memory_writeback (
    input logic CLK, nRST,
    memory_writeback_if.mw mwif
);
// type import
import cpu_types_pkg::*;

always_ff @(posedge CLK, negedge nRST) begin
    if(!nRST) begin
        mwif.pc4_out <= '0;
        mwif.outport_out <= '0;
        mwif.instruction_out <= '0;
        //mwif.next_pc_out <= '0;
        mwif.dload_out <= '0;
        mwif.halt_out <= '0;
        mwif.RegWrite_out <= '0;
        mwif.MemtoReg_out <= '0;
        mwif.rdat2_out <= '0;
        mwif.RegDst_out <= '0;
        mwif.jal_out <= '0;
        mwif.dload_out2 <= '0;//just added
        mwif.RegWrite_out2 <= '0;//just added
    end
    /*else if(mwif.dhit && !mwif.stall) begin
        mwif.dload_out <= mwif.dload_in;
        mwif.RegWrite_out <= '0;
    end*/
    else if((mwif.ihit || mwif.dhit) && !mwif.stall) begin //think about ihit
        mwif.pc4_out <= mwif.pc4_in;
        mwif.outport_out <= mwif.outport_in;
        mwif.instruction_out <= mwif.instruction_in;
        //mwif.next_pc_out <= mwif.next_pc_in;
        mwif.dload_out <= mwif.dload_in;
        mwif.halt_out <= mwif.halt_in;
        mwif.RegWrite_out <= mwif.RegWrite_in;
        mwif.MemtoReg_out <= mwif.MemtoReg_in;
        mwif.rdat2_out <= mwif.rdat2_in;
        mwif.RegDst_out <= mwif.RegDst_in;
        mwif.jal_out <= mwif.jal_in;
        //mwif.dload_out2 <= mwif.dload_out;//push this one clock cycle ahead so forwarding gets on time
        //mwif.RegWrite_out2 <= mwif.RegWrite_in;//signal was going low in the middle, added this to make last entire cycle since ALU_A and ALU_B depend on it
    end 
end
//DO NOT DELETE THIS
    r_t instrout;
    assign instrout = r_t'(mwif.instruction_out);
endmodule