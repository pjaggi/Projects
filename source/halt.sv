/*
halt.sv
9/18/23
Pranay Jaggi
437-03
Version 1.0
halt
*/
`include "halt_if.vh"
`include "cpu_types_pkg.vh"
module halt(input logic CLK, nRST,
halt_if.hu huif);
  import cpu_types_pkg::*;
  always_ff @(posedge CLK, negedge nRST) begin
    if(1'b0 == nRST) begin
      huif.halt_out <= '0;
    end
    else begin
      huif.halt_out <= huif.halt_in | huif.halt_out;
    end
  end
endmodule