/*
Michael Fuchs
9/24/23
hazard_unit
Version 1.0
*/

`include "hazard_unit_if.vh"
`include "cpu_types_pkg.vh"
module hazard_unit(hazard_unit_if.ha haif);
  import cpu_types_pkg::*;
  always_comb begin : hazardDetect
    //default low
    haif.stallFD = 0; 
    haif.flushFD = 0;
    haif.stallDE = 0;
    haif.flushDE = 0;
    haif.stallEM = 0;
    haif.flushEM = 0;
    haif.stallMW = 0;
    haif.flushMW = 0;
    haif.flushHALT = 0;

    if((haif.DEIFinst[31:26] == SW || haif.DEIFinst[31:26] == SC) && haif.EMIFinst[31:26] == HALT) begin
        haif.flushHALT = 1;
    end
    if(((haif.FDIFinst[20:16] == haif.DEIFinst[20:16]) || (haif.FDIFinst[25:21] == haif.DEIFinst[20:16])) && (haif.DEIFinst[31:26] == LW || haif.DEIFinst[31:26] == LL || haif.DEIFinst[31:26] == SC) && haif.DEIFRegWrite) begin
        haif.stallFD = 1;
        haif.flushDE = 1;
    end
    if(((haif.FDIFinst[20:16] == haif.EMIFinst[20:16]) || (haif.FDIFinst[25:21] == haif.EMIFinst[20:16])) && (haif.EMIFinst[31:26] == LW || haif.EMIFinst[31:26] == LL || haif.EMIFinst[31:26] == SC) && haif.EMIFRegWrite) begin
        haif.stallFD = 1;
        haif.flushDE = 1;
    end
  end

  logic stall;
  assign stall = (haif.stallFD | haif.stallDE);

  r_t instroutFD;
  assign instroutFD = r_t'(haif.FDIFinst);
  r_t instroutDE;
  assign instroutDE = r_t'(haif.DEIFinst);
  r_t instroutEM;
  assign instroutEM = r_t'(haif.EMIFinst);

endmodule

