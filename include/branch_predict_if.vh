/*
Michael Fuchs
9/24/23
hazard_unit_interface
Version 1.0
*/

`ifndef BRANCH_PREDICT_IF_VH
`define BRANCH_PREDICT_IF_VH

`include "cpu_types_pkg.vh"

interface branch_predict_if;
    import cpu_types_pkg::*;

    logic zero, BNE, Branch, flushFD, flushDE, flushEM;

    modport bp(
        input zero, BNE, Branch,
        output flushFD, flushDE, flushEM
    );
    modport tb(
        input flushFD, flushDE, flushEM,
        output zero, BNE, Branch
    );
endinterface
`endif