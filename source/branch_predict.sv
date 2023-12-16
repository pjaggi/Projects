/*
Michael Fuchs
9/24/23
hazard_unit
Version 1.0
*/

`include "branch_predict_if.vh"
`include "cpu_types_pkg.vh"
module branch_predict(branch_predict_if.bp bpif);
  import cpu_types_pkg::*;
  logic Zero;
  logic BranchZero;
  logic pc_equal;
  always_comb begin : branchWrong
    //default low 
    bpif.flushFD = 0;
    bpif.flushDE = 0;
    bpif.flushEM = 0;
    //supporting BranchZero logic
        //BEQ vs BNE
     
    Zero = bpif.zero;
    if(bpif.BNE == 1) Zero = !bpif.zero;
    BranchZero = (bpif.Branch & Zero);

    //if wrong prediction flush
        //currently predicting always not taken
    bpif.flushFD = BranchZero;
    bpif.flushDE = BranchZero;
    bpif.flushEM = BranchZero;
  end
endmodule

