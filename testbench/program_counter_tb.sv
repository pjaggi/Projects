/*
program_counter_tb.sv
9/10/23
Michael Fuchs
437-03
Version 1.0
PC
*/

// mapped needs this
`include "program_counter_if.vh"
import cpu_types_pkg::*;

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module program_counter_tb;
  parameter CLK_PERIOD = 10;
  logic CLK = 0, nRST = 1;
  // clock
  always #(CLK_PERIOD/2) CLK++;
  // interface
  program_counter_if pcif();
  // test program
  test PROG (.CLK, .nRST, .pcif);
  // DUT
`ifndef MAPPED
  program_counter DUT(CLK, nRST, pcif);
`else
  program_counter DUT(
    .\pcif.next_PC (pcif.next_PC),
    .\pcif.PC (pcif.PC),
    .\pcif.PC4 (pcif.PC4),
    .\pcif.ihit (pcif.ihit)
  );
`endif

endmodule

program test (
input logic CLK,
output logic nRST,
program_counter_if.tb pcif
);

//define localparams
localparam PROPAGATION_DELAY = 0.8; // Allow for 800 ps for FF propagation delay
localparam CLK_PERIOD = 10;
//define test signals
logic [31:0] expected_PC;
logic [31:0] expected_PC4;

// Declare Test Case Signals
integer tb_test_num;
string  tb_test_case;
string  tb_stream_check_tag;
logic   tb_mismatch;
logic   tb_check;

int   tb_total_tests;
int   tb_num_right;
int   tb_num_wrong;
  
  task reset(); begin
    nRST = 0;
    #CLK_PERIOD;
    check_output("after Reset: ");
    nRST = 1;
    #CLK_PERIOD;
  end
  endtask
  

  task check_output;
    input string check_tag;
  begin
    tb_mismatch = 1'b0;
    tb_check    = 1'b1;
    
    //Add delay to show signals
    #(1);

    //check Out
    if(expected_PC == pcif.PC) begin // Check passed
      //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect PC %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_PC, pcif.PC);
      tb_num_wrong = tb_num_wrong + 1;
      tb_total_tests = tb_total_tests + 1;
    end

    //check Neg
    if(expected_PC4 == pcif.PC4) begin // Check passed
      //$display("Correct rdat2 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat2, rfif.rdat2);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect PC4 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_PC4, pcif.PC4);
      tb_num_wrong = tb_num_wrong + 1;
      tb_total_tests = tb_total_tests + 1;
    end

    // Wait some small amount of time so check pulse timing is visible on waves
    #(0.1);
    tb_check =1'b0;
    #(0.5);
  end
  endtask

//run tasks
initial begin
tb_test_num = 0;
#(0.1);

// ************************************************************************
// Test Case 1: Normal Operation
// ************************************************************************
tb_test_num  = tb_test_num + 1;
tb_test_case = "Normal Operation: Increment PC";

// Define the test data stream for this test case
expected_PC = 0;
expected_PC4 = expected_PC + 4;

nRST = 1;

// Set opcode and inputs
for(int i = 0; i < 100; i++) begin
    expected_PC = i;
    expected_PC4 = expected_PC + 4;
    pcif.next_PC = i;
    pcif.ihit = 1;
    #(CLK_PERIOD / 2);
    pcif.ihit = 0;
    @(posedge CLK);
    check_output("after next_PC changes: ");
end

expected_PC = 0;
expected_PC4 = expected_PC + 4;
reset();
pcif.next_PC = 0;
expected_PC = 0;
expected_PC4 = expected_PC + 4;

for(int i = 0; i < 1000; i = i + 10) begin
    expected_PC = i;
    expected_PC4 = expected_PC + 4;
    pcif.next_PC = i;
    pcif.ihit = 1;
    #(CLK_PERIOD / 2);
    pcif.ihit = 0;
    @(posedge CLK);
    check_output("after next_PC changes: ");
end



//Summary
$display("\nTotal tests: %d \nTotal correct: %d \nTotal wrong: %d \n", tb_total_tests, tb_num_right, tb_num_wrong);
$stop();
end
endprogram
