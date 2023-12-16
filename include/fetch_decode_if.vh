`ifndef FETCH_DECODE_IF_VH
`define FETCH_DECODE_IF_VH

`include "cpu_types_pkg.vh"

interface fetch_decode_if;
    import cpu_types_pkg::*;

    logic ihit, flush, dhit, stall;
    word_t fetch_instr_in, pc_in, pc4_in, next_pc_in;
    word_t decode_instr_out, pc_out, pc4_out, next_pc_out;

    modport fd(
        input  fetch_instr_in, ihit, dhit, pc_in, flush, pc4_in, next_pc_in, stall, 
        output decode_instr_out, pc_out, pc4_out, next_pc_out
    );

    modport tb(
        input decode_instr_out, pc_out, pc4_out, next_pc_out,
        output fetch_instr_in, ihit, dhit, pc_in, flush, pc4_in, next_pc_in, stall
    );
endinterface
`endif