`include "request_unit_if.vh"
`timescale 1 ns / 1 ns

module request_unit_tb;

  parameter PERIOD = 10;
    logic CLK = 0, nRST;
  // clock
  always #(PERIOD/2) CLK++;

  // interface
  request_unit_if ruif();
  // test program
  test PROG (.CLK, .nRST, .ruif);
  
  // DUT
`ifndef MAPPED
  request_unit request_unit(CLK, nRST, ruif);
`endif


endmodule

program test(
    input logic CLK, 
    output logic nRST,
    request_unit_if.tb ruif
);
parameter PERIOD = 10;

task reset_dut;
begin
  // Activate the reset
  nRST = 1'b0;

  // Maintain the reset for more than one cycle
  @(posedge CLK);
  @(posedge CLK);

  // Wait until safely away from rising edge of the clock before releasing
  @(negedge CLK);
  nRST = 1'b1;

  // Leave out of reset for a couple cycles before allowing other stimulus
  // Wait for negative clock edges, 
  // since inputs to DUT should normally be applied away from rising clock edges
  @(negedge CLK);
  @(negedge CLK);
end
endtask

initial begin
    $monitor("@%00g CLK = %b nRST = %b",
    $time, CLK, nRST);
    nRST = 0;
    //rfif.rdat1 = '0;
    //rfif
    #(PERIOD);
    nRST = 1;
    ruif.ihit = 0;
    ruif.dhit = 0;
    ruif.memread = 0;
    ruif.memwrite = 0;
    
    //RESET DUT
    #(PERIOD);
    reset_dut();
    $display("Reached reset DUT");
    #(PERIOD);

    #(PERIOD);
    ruif.dhit = 1;
    #(PERIOD);

    #(PERIOD);
    ruif.dhit = 0;
    ruif.ihit = 1;
    #(PERIOD);






    $finish;
end
endprogram