`ifndef DECODE_EXECUTE_IF_VH
`define DECODE_EXECUTE_IF_VH

`include "cpu_types_pkg.vh"

interface decode_execute_if;
    import cpu_types_pkg::*;

    word_t decode_instr_in, InstrE_in, rdat1_in, rdat2_in, pc4_in, next_pc_in;
    word_t pc4_out, rdat1_out, rdat2_out, InstrE_out, decode_instr_out, next_pc_out;
    aluop_t aluop_in, aluop_out;

    logic flush, ihit, dhit, RegDst_in, bne_in, SignExtend_in, MemtoReg_in, dWEN_in,
    dREN_in, halt_in, AluSrc_in, jump_in, branch_in, jr_in,
    lui_in, jal_in, RegWrite_in;

    logic RegDst_out, bne_out, SignExtend_out, MemtoReg_out, dWEN_out,
    dREN_out, halt_out, AluSrc_out, jump_out, branch_out, jr_out,
    lui_out, jal_out, RegWrite_out;
    
    logic stall, datomic_in, datomic_out;

    modport de(//aluop in?
        input flush, ihit, dhit, decode_instr_in, InstrE_in, rdat1_in, rdat2_in, pc4_in,
        aluop_in, RegDst_in, bne_in, SignExtend_in, MemtoReg_in, dWEN_in,
        dREN_in, halt_in, AluSrc_in, jump_in, branch_in, jr_in,
        lui_in, jal_in, RegWrite_in, next_pc_in, stall, datomic_in,
        output pc4_out, rdat1_out, rdat2_out, InstrE_out, decode_instr_out,
        aluop_out, RegDst_out, bne_out, SignExtend_out, MemtoReg_out, dWEN_out,
        dREN_out, halt_out, AluSrc_out, jump_out, branch_out, jr_out,
        lui_out, jal_out, RegWrite_out, next_pc_out, datomic_out
    );

    modport tb(
        input pc4_out, rdat1_out, rdat2_out, InstrE_out, decode_instr_out,
        aluop_out, RegDst_out, bne_out, SignExtend_out, MemtoReg_out, dWEN_out,
        dREN_out, halt_out, AluSrc_out, jump_out, branch_out, jr_out,
        lui_out, jal_out, RegWrite_out, next_pc_out, datomic_out,
        output flush, ihit, dhit, decode_instr_in, InstrE_in, rdat1_in, rdat2_in, pc4_in,
        aluop_in, RegDst_in, bne_in, SignExtend_in, MemtoReg_in, dWEN_in,
        dREN_in, halt_in, AluSrc_in, jump_in, branch_in, jr_in,
        lui_in, jal_in, RegWrite_in, next_pc_in, stall, datomic_in
    );
endinterface
`endif