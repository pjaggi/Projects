/*
Pranay Jaggi
9/27/23
forwarding_unit_interface
Version 1.0
*/

`ifndef FORWARDING_UNIT_IF_VH
`define FORWARDING_UNIT_IF_VH

`include "cpu_types_pkg.vh"

interface forwarding_unit_if;
    import cpu_types_pkg::*;

    logic EMIFRegWrite, DEIFRegWrite, MWIFRegWrite, MemtoReg, RegDst_EMIF, RegDst_MWIF;
    word_t rdat1, rdat2, EMIFInst, MWIFInst, DEIFInst, FDIFInst, ALU_A, ALU_B, alu_result_emif, alu_result_mwif, dload_emif, dload_mwif;

    modport fu(
        input rdat1, rdat2, EMIFInst, MWIFInst, DEIFInst, FDIFInst, RegDst_EMIF, RegDst_MWIF,
        EMIFRegWrite, DEIFRegWrite, MWIFRegWrite, alu_result_emif, alu_result_mwif, dload_emif, dload_mwif,
        output ALU_A, ALU_B
    );

    modport tb(
        input ALU_A, ALU_B,
        output rdat1, rdat2, EMIFInst, MWIFInst, DEIFInst, FDIFInst,
        EMIFRegWrite, DEIFRegWrite, MWIFRegWrite, alu_result_emif, alu_result_mwif, dload_emif, dload_mwif, RegDst_EMIF, RegDst_MWIF
    );
endinterface
`endif