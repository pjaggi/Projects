/*
decode_execute.sv
9/18/23
Pranay Jaggi
437-03
Version 1.0
decode_execute
*/
`include "cpu_types_pkg.vh"
`include "decode_execute_if.vh"
//decode_execute_if deif();
module decode_execute (
    input logic CLK, nRST,
    decode_execute_if.de deif
);
// type import
import cpu_types_pkg::*;

always_ff @(posedge CLK, negedge nRST) begin
    if(!nRST) begin
        deif.rdat1_out <= '0;
        deif.rdat2_out <= '0;
        deif.aluop_out <= ALU_ADD;//what should default value be?
        deif.RegDst_out <= 0;
        deif.bne_out <= 0;
        deif.SignExtend_out <= 0; //enable signal whenever andi, ori, xori are selected
        deif.MemtoReg_out <= 0;
        deif.dWEN_out <= 0; //only for store
        deif.dREN_out <= 0; //only for load
        deif.halt_out <= 0;
        deif.AluSrc_out <= 0;
        deif.jump_out <= 0;
        deif.branch_out <= 0;
        deif.jr_out <= 0;
        deif.lui_out <= 0;
        deif.jal_out <= 0;
        deif.RegWrite_out <= '0; //reg write enable signal
        deif.pc4_out <= '0;
        deif.next_pc_out <= '0;
        deif.InstrE_out <= '0;
        deif.decode_instr_out <= '0;
        deif.datomic_out <= '0;
        //deif.execute_instr <= '0;//instruction input on execute side
    end
    else if(deif.flush) begin
        deif.rdat1_out <= '0;
        deif.rdat2_out <= '0;
        deif.aluop_out <= ALU_ADD;//what should default value be?
        deif.RegDst_out <= 0;
        deif.bne_out <= 0;
        deif.SignExtend_out <= 0; //enable signal whenever andi, ori, xori are selected
        deif.MemtoReg_out <= 0;
        deif.dWEN_out <= 0; //only for store
        deif.dREN_out <= 0; //only for load
        deif.halt_out <= 0;
        deif.AluSrc_out <= 0;
        deif.jump_out <= 0;
        deif.branch_out <= 0;
        deif.jr_out <= 0;
        deif.lui_out <= 0;
        deif.jal_out <= 0;
        deif.RegWrite_out <= '0; //reg write enable signal
        deif.pc4_out <= '0;
        deif.next_pc_out <= '0;
        deif.InstrE_out <= '0;
        deif.decode_instr_out <= '0;
        deif.datomic_out <= '0;
        //deif.execute_instr <= '0;//instruction input on execute side
    end
    else if((deif.ihit || deif.dhit) && !deif.stall) begin//can get rid of !deif.flush
        deif.rdat1_out <= deif.rdat1_in;
        deif.rdat2_out <= deif.rdat2_in;
        deif.aluop_out <= deif.aluop_in;//what should default value be?
        deif.RegDst_out <= deif.RegDst_in;
        deif.bne_out <= deif.bne_in;
        deif.SignExtend_out <= deif.SignExtend_in; //enable signal whenever andi, ori, xori are selected
        deif.MemtoReg_out <= deif.MemtoReg_in;
        deif.dWEN_out <= deif.dWEN_in; //only for store
        deif.dREN_out <= deif.dREN_in; //only for load
        deif.halt_out <= deif.halt_in;
        deif.AluSrc_out <= deif.AluSrc_in;
        deif.jump_out <= deif.jump_in;
        deif.branch_out <= deif.branch_in;
        deif.jr_out <= deif.jr_in;
        deif.lui_out <= deif.lui_in;
        deif.jal_out <= deif.jal_in;
        deif.RegWrite_out <= deif.RegWrite_in; //reg write enable signal
        deif.pc4_out <= deif.pc4_in;
        deif.next_pc_out <= deif.next_pc_in;
        deif.InstrE_out <= deif.InstrE_in;//output of sign extender block
        deif.decode_instr_out <= deif.decode_instr_in;
        deif.datomic_out <= deif.datomic_in;
        //deif.execute_instr <= ;//instruction input on execute side
    end
end
//DO NOT DELETE THIS
    r_t instrout;
    assign instrout = r_t'(deif.decode_instr_out);
endmodule