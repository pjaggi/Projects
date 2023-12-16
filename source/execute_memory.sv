/*
execute_memory.sv
9/18/23
Pranay Jaggi
437-03
Version 1.0
execute_memory
*/
`include "cpu_types_pkg.vh"
`include "execute_memory_if.vh"
//execute_memory_if emif();
module execute_memory (
    input logic CLK, nRST,
    execute_memory_if.em emif
);
// type import
import cpu_types_pkg::*;

always_ff @(posedge CLK, negedge nRST) begin
    if(!nRST) begin
        emif.rdat1_out <= '0;
        emif.rdat2_out <= '0;
        emif.aluop_out <= ALU_ADD;//what should default value be?
        emif.RegDst_out <= 0;
        emif.bne_out <= 0;
        emif.SignExtend_out <= 0; //enable signal whenever andi, ori, xori are selected
        emif.MemtoReg_out <= 0;
        emif.dWEN_out <= 0; //only for store
        emif.dREN_out <= 0; //only for load
        emif.halt_out <= 0;
        emif.AluSrc_out <= 0;
        emif.jump_out <= 0;
        emif.branch_out <= 0;
        emif.jr_out <= 0;
        emif.lui_out <= 0;
        emif.jal_out <= 0;
        emif.RegWrite_out <= '0; //reg write enable signal
        emif.branchaddr_out <= '0;
        emif.jumpaddr_out <= '0;
        emif.pc4_out <= '0;
        emif.outport_out <= '0; //alu result port output
        emif.instruction_out <= '0;
        emif.InstrE_out <= '0;
        emif.zero_out <= '0;
        emif.overflow_out <= '0;
        emif.neg_out <= '0;
        emif.datomic_out <= '0;
    end
    else if(emif.flush) begin//maybe take out ihit
        emif.rdat1_out <= '0;
        emif.rdat2_out <= '0;
        emif.aluop_out <= ALU_ADD;//what should default value be?
        emif.RegDst_out <= 0;
        emif.bne_out <= 0;
        emif.SignExtend_out <= 0; //enable signal whenever andi, ori, xori are selected
        emif.MemtoReg_out <= 0;
        emif.dWEN_out <= 0; //only for store
        emif.dREN_out <= 0; //only for load
        emif.halt_out <= 0;
        emif.AluSrc_out <= 0;
        emif.jump_out <= 0;
        emif.branch_out <= 0;
        emif.jr_out <= 0;
        emif.lui_out <= 0;
        emif.jal_out <= 0;
        emif.RegWrite_out <= '0; //reg write enable signal
        emif.branchaddr_out <= '0;
        emif.jumpaddr_out <= '0;
        emif.pc4_out <= '0;
        emif.outport_out <= '0; //alu result port output
        emif.instruction_out <= '0;
        emif.InstrE_out <= '0;
        emif.zero_out <= '0;
        emif.overflow_out <= '0;
        emif.neg_out <= '0;
        emif.datomic_out <= '0;
    end
    else if((emif.ihit || emif.dhit) && !emif.stall) begin//fill this out
        emif.rdat1_out <= emif.rdat1_in;
        emif.rdat2_out <= emif.rdat2_in;
        emif.aluop_out <= emif.aluop_in;//what should default value be?
        emif.RegDst_out <= emif.RegDst_in;
        emif.bne_out <= emif.bne_in;
        emif.SignExtend_out <= emif.SignExtend_in; //enable signal whenever andi, ori, xori are selected
        emif.MemtoReg_out <= emif.MemtoReg_in;
        emif.dWEN_out <= emif.dWEN_in; //only for store
        emif.dREN_out <= emif.dREN_in; //only for load
        emif.halt_out <= emif.halt_in;
        emif.AluSrc_out <= emif.AluSrc_in;
        emif.jump_out <= emif.jump_in;
        emif.branch_out <= emif.branch_in;
        emif.jr_out <= emif.jr_in;
        emif.lui_out <= emif.lui_in;
        emif.jal_out <= emif.jal_in;
        emif.RegWrite_out <= emif.RegWrite_in; //reg write enable signal
        emif.branchaddr_out <= emif.branchaddr_in;
        emif.jumpaddr_out <= emif.jumpaddr_in;
        emif.pc4_out <= emif.pc4_in;
        emif.outport_out <= emif.outport_in; //alu result port output
        emif.instruction_out <= emif.instruction_in;
        emif.InstrE_out <= emif.InstrE_in;
        emif.zero_out <= emif.zero_in;
        emif.overflow_out <= emif.overflow_in;
        emif.neg_out <= emif.neg_in;
        emif.datomic_out <= emif.datomic_in;
    end
end
//DO NOT DELETE THIS
    r_t instrout;
    assign instrout = r_t'(emif.instruction_out);
endmodule