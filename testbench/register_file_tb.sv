/*
  Eric Villasenor
  evillase@gmail.com

  register file test bench
*/

// mapped needs this
`include "register_file_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module register_file_tb;

  parameter CLK_PERIOD = 10;

  logic CLK = 0, nRST = 1;

  // test vars
  int v1 = 1;
  int v2 = 4721;
  int v3 = 25119;

  // clock
  always #(CLK_PERIOD/2) CLK++;

  // interface
  register_file_if rfif ();
  // test program
  test PROG (.CLK, .nRST, .rfif);
  // DUT
`ifndef MAPPED
  register_file DUT(CLK, nRST, rfif);
`else
  register_file DUT(
    .\rfif.rdat2 (rfif.rdat2),
    .\rfif.rdat1 (rfif.rdat1),
    .\rfif.wdat (rfif.wdat),
    .\rfif.rsel2 (rfif.rsel2),
    .\rfif.rsel1 (rfif.rsel1),
    .\rfif.wsel (rfif.wsel),
    .\rfif.WEN (rfif.WEN),
    .\nRST (nRST),
    .\CLK (CLK)
  );
`endif

endmodule

program test (
input logic CLK,
output logic nRST,
register_file_if.tb rfif
);

//define localparams
localparam PROPAGATION_DELAY = 0.8; // Allow for 800 ps for FF propagation delay

//define test signals
logic [31:0] expected_rdat1;
logic [31:0] expected_rdat2;

// test vars
int v1 = 1;
int v2 = 4721;
int v3 = 25119;

parameter CLK_PERIOD = 10;

// Declare Test Case Signals
integer tb_test_num;
string  tb_test_case;
string  tb_stream_check_tag;
logic   tb_mismatch;
logic   tb_check;

int   tb_total_tests;
int   tb_num_right;
int   tb_num_wrong;

//define tasks
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

  task check_output;
    input string check_tag;
  begin
    tb_mismatch = 1'b0;
    tb_check    = 1'b1;
    
    //check rsel1
    if(expected_rdat1 == rfif.rdat1) begin // Check passed
      //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
      tb_num_wrong = tb_num_wrong + 1;
      tb_total_tests = tb_total_tests + 1;
    end

    //check rsel2
    if(expected_rdat2 == rfif.rdat2) begin // Check passed
      //$display("Correct rdat2 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat2, rfif.rdat2);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect rdat2 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat2, rfif.rdat2);
      tb_num_wrong = tb_num_wrong + 1;
      tb_total_tests = tb_total_tests + 1;
    end

    // Wait some small amount of time so check pulse timing is visible on waves
    #(0.1);
    tb_check =1'b0;
  end
  endtask

  task writeData(
    input int data,
    input int address
  );
  begin
    rfif.wdat = data;
    rfif.wsel = address;
    #(PROPAGATION_DELAY);
    @(negedge CLK);
    @(negedge CLK);
    rfif.WEN = 1;
    //check_output("check output on write: ");
  end
  endtask

  task readData;
    input int address1;
    input int address2;
  begin
    #(PROPAGATION_DELAY);
    rfif.rsel1 = address1;
    rfif.rsel2 = address2;
    @(negedge CLK);
    @(negedge CLK);
    check_output("check output on read: ");
  end
  endtask

//run tasks
initial begin
tb_test_num = 0;
#(0.1);

// ************************************************************************
// Test Case 1: Power-on Reset of the DUT
// ************************************************************************
tb_test_num  = tb_test_num + 1;
tb_test_case = "Power on Reset";
// Note: Do not use reset task during reset test case since we need to specifically check behavior during reset
// Wait some time before applying test case stimulus
#(0.1);
// Apply test case initial stimulus (non-reset value parralel input)
nRST = 1'b0;
rfif.rsel1 = 0;
rfif.rsel2 = 0;

// Wait for a bit before checking for correct functionality
#(CLK_PERIOD * 0.5);

// Check that internal state was correctly reset
expected_rdat1 = 0;
expected_rdat2 = 0;
check_output("after reset applied");

// Check that the reset value is maintained during a clock cycle
#(CLK_PERIOD);
check_output("after clock cycle while in reset");

// Release the reset away from a clock edge
@(negedge CLK);
nRST  = 1'b1;   // Deactivate the chip reset
// Check that internal state was correctly keep after reset release
#(PROPAGATION_DELAY);
check_output("after reset was released");

// ************************************************************************
// Test Case 2: Normal Operation: Reset Assert
// ************************************************************************
tb_test_num  = tb_test_num + 1;
tb_test_case = "Normal Operation: Reset Assert";
$sformat(tb_stream_check_tag, "during reset");
// Start out with inactive value and reset the DUT to isolate from prior tests
reset_dut();

// Define the test data stream for this test case
expected_rdat1 = 0;
expected_rdat2 = 0;

//Write 10 to address 1
rfif.wdat = 10;
rfif.wsel = 1;
#(PROPAGATION_DELAY);
rfif.WEN = 1;
#(PROPAGATION_DELAY);
rfif.WEN = 0;

//Write 11 to address 2
rfif.wdat = 11;
rfif.wsel = 2;
#(PROPAGATION_DELAY);
rfif.WEN = 1;
#(PROPAGATION_DELAY);
rfif.WEN = 0;

//assert reset
nRST = 1'b0;
@(posedge CLK);
@(negedge CLK);
nRST = 1'b1;
#(PROPAGATION_DELAY);
readData(1, 2);

// ************************************************************************
// Test Case 3: Normal Operation: Write to Zero Reg
// ************************************************************************
tb_test_num  = tb_test_num + 1;
tb_test_case = "Normal Operation: Write to Zero Reg";
$sformat(tb_stream_check_tag, "during reset");
// Start out with inactive value and reset the DUT to isolate from prior tests
reset_dut();

// Define the test data stream for this test case
expected_rdat1 = 0;
expected_rdat2 = 0;

//Read + Write multiple to address 0
writeData(v1, 0);
readData(0,0);
writeData(v2, 0);
readData(0,0);
writeData(v3, 0);
readData(0,0);

// ************************************************************************
// Test Case 4: Normal Operation: Write to all Reg
// ************************************************************************
tb_test_num  = tb_test_num + 1;
tb_test_case = "Normal Operation: Write to all Reg";
$sformat(tb_stream_check_tag, "during reset");
// Start out with inactive value and reset the DUT to isolate from prior tests
reset_dut();

//Read + Write multiple to address 0
expected_rdat1 = v1;
expected_rdat2 = 0;
for (int address = 1; address < 32; address = address + 1) begin
    writeData(v1, address);
    readData(address, 0);  
end

//Summary
$display("\nTotal tests:   %d \nTotal correct: %d \nTotal wrong:   %d \n", tb_total_tests, tb_num_right, tb_num_wrong);
#(10*CLK_PERIOD);
$stop();
end
endprogram
