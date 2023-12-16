`ifndef EXECUTE_MEMORY_IF_VH
`define EXECUTE_MEMORY_IF_VH

`include "cpu_types_pkg.vh"

interface execute_memory_if;
    import cpu_types_pkg::*;

    word_t instruction_in, InstrE_in,  pc4_in, rdat1_in, rdat2_in, branchaddr_in, jumpaddr_in, outport_in, next_pc_in;
    word_t instruction_out, InstrE_out, pc4_out, rdat1_out, rdat2_out, branchaddr_out, jumpaddr_out, outport_out, next_pc_out;
    aluop_t aluop_in, aluop_out;

    logic flush, ihit, dhit, RegDst_in, bne_in, SignExtend_in, MemtoReg_in, dWEN_in,
    dREN_in, halt_in, AluSrc_in, jump_in, branch_in, jr_in,
    lui_in, jal_in, RegWrite_in, zero_in, overflow_in, neg_in;

    logic RegDst_out, bne_out, SignExtend_out, MemtoReg_out, dWEN_out,
    dREN_out, halt_out, AluSrc_out, jump_out, branch_out, jr_out,
    lui_out, jal_out, RegWrite_out, zero_out, overflow_out, neg_out;

    logic stall, datomic_in, datomic_out;

    modport em(
        input flush, ihit, dhit, pc4_in, rdat1_in, rdat2_in, branchaddr_in, jumpaddr_in, outport_in,
        RegDst_in, bne_in, aluop_in, SignExtend_in, MemtoReg_in, dWEN_in, dREN_in,
        halt_in, AluSrc_in, jump_in, branch_in, jr_in, lui_in, jal_in, RegWrite_in,
        instruction_in, InstrE_in, zero_in, overflow_in, neg_in, next_pc_in, stall, datomic_in,
        output pc4_out, rdat1_out, rdat2_out, branchaddr_out, jumpaddr_out, outport_out, 
        RegDst_out, bne_out, aluop_out, SignExtend_out, MemtoReg_out, dWEN_out, dREN_out,
        halt_out, AluSrc_out, jump_out, branch_out, jr_out, lui_out, jal_out, RegWrite_out,
        instruction_out, InstrE_out, zero_out, overflow_out, neg_out, next_pc_out, datomic_out
    );

    modport tb(
        input pc4_out, rdat1_out, rdat2_out, branchaddr_out, jumpaddr_out, outport_out, 
        RegDst_out, bne_out, aluop_out, SignExtend_out, MemtoReg_out, dWEN_out, dREN_out,
        halt_out, AluSrc_out, jump_out, branch_out, jr_out, lui_out, jal_out, RegWrite_out,
        instruction_out, InstrE_out, zero_out, overflow_out, neg_out, next_pc_out, datomic_out,
        output flush, ihit, dhit, pc4_in, rdat1_in, rdat2_in, branchaddr_in, jumpaddr_in, outport_in,
        RegDst_in, bne_in, aluop_in, SignExtend_in, MemtoReg_in, dWEN_in, dREN_in,
        halt_in, AluSrc_in, jump_in, branch_in, jr_in, lui_in, jal_in, RegWrite_in,
        instruction_in, InstrE_in, zero_in, overflow_in, neg_in, next_pc_in, stall, datomic_in
    );
endinterface
`endif