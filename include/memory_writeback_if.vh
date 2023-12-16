`ifndef MEMORY_WRITEBACK_IF_VH
`define MEMORY_WRITEBACK_IF_VH

`include "cpu_types_pkg.vh"

interface memory_writeback_if;
    import cpu_types_pkg::*;

    word_t outport_in, pc4_in, instruction_in, dload_in, rdat2_in;
    word_t outport_out, pc4_out, instruction_out, dload_out, rdat2_out, dload_out2;
    logic ihit, dhit, RegDst_in, RegDst_out, MemtoReg_in, MemtoReg_out, RegWrite_out2;
    logic jal_in, jal_out, RegWrite_in, RegWrite_out, halt_in, halt_out, flush, stall;

    modport mw(
        input ihit, dhit, outport_in, pc4_in, instruction_in, dload_in, rdat2_in, RegDst_in, MemtoReg_in, jal_in, RegWrite_in, halt_in, flush, stall,
        output outport_out, pc4_out, instruction_out, dload_out, rdat2_out, RegDst_out, MemtoReg_out, jal_out, RegWrite_out, halt_out, dload_out2, RegWrite_out2
    );

    modport tb(
        input outport_out, pc4_out, instruction_out, dload_out, rdat2_out, RegDst_out, MemtoReg_out, jal_out, RegWrite_out, halt_out,  dload_out2, RegWrite_out2,
        output ihit, dhit, outport_in, pc4_in, instruction_in, dload_in, rdat2_in, RegDst_in, MemtoReg_in, jal_in, RegWrite_in, halt_in, flush, stall
    );
endinterface
`endif