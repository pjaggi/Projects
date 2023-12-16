`ifndef HALT_IF_VH
`define HALT_IF_VH

`include "cpu_types_pkg.vh"

interface halt_if;
    import cpu_types_pkg::*;

    logic halt_in, halt_out;

    modport hu(
        input halt_in,
        output halt_out
    );

    modport tb(
        input halt_out,
        output halt_in
    );
endinterface
`endif