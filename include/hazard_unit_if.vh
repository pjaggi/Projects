/*
Michael Fuchs
9/24/23
hazard_unit_interface
Version 1.0
*/

`ifndef HAZARD_UNIT_IF_VH
`define HAZARD_UNIT_IF_VH

`include "cpu_types_pkg.vh"

interface hazard_unit_if;
    import cpu_types_pkg::*;

    logic EMIFRegWrite, DEIFRegWrite, stallFD, flushFD, stallDE, flushDE, stallEM, flushEM, stallMW, flushMW, flushHALT, deif_branch, dhit, dWEN;

    word_t FDIFinst, DEIFinst, EMIFinst, MWIFinst;

    modport ha(
        input EMIFRegWrite, DEIFRegWrite, FDIFinst, DEIFinst, EMIFinst, MWIFinst, deif_branch, dhit, dWEN,
        output stallFD, flushFD, stallDE, flushDE, stallEM, flushEM, stallMW, flushMW, flushHALT
    );

    modport tb(
        input stallFD, flushFD, stallDE, flushDE, stallEM, flushEM, stallMW, flushMW, flushHALT,
        output EMIFRegWrite, DEIFRegWrite, FDIFinst, DEIFinst, EMIFinst, MWIFinst, deif_branch, dhit, dWEN
    );
endinterface
`endif