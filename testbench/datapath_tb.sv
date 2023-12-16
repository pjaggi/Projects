/*
datapath_tb.sv
9/11/23
Michael Fuchs
437-03
Version 1.0
DP
*/

// mapped needs this
`include "datapath_cache_if.vh"
import cpu_types_pkg::*;

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module datapath_tb;
  parameter CLK_PERIOD = 10;
  logic CLK = 0, nRST = 1;
  // clock
  always #(CLK_PERIOD/2) CLK++;
  // interface
  datapath_cache_if dpif();
  // test program
  test PROG (.CLK, .nRST, .dpif);
  // DUT
`ifndef MAPPED
  datapath DUT(CLK, nRST, dpif);
`else
  datapath DUT(
    .\dpif.dhit (dpif.dhit), //high if (dmemREN || dmemWEN) & !dwait
    .\dpif.ihit (dpif.ihit), //high if imemREN & !iwait
    .\dpif.imemload (dpif.imemload),
    .\dpif.dmemload (dpif.dmemload),
    .\dpif.halt (dpif.halt), 
    .\dpif.imemREN (dpif.imemREN), 
    .\dpif.imemaddr (dpif.imemaddr), //iaddr to send to mem, passed to imemaddr
    .\dpif.dmemREN (dpif.dmemREN),
    .\dpif.dmemWEN (dpif.dmemWEN),
    .\dpif.dmemstore (dpif.dmemstore),
    .\dpif.dmemaddr (dpif.dmemaddr)
  );
`endif

endmodule

program test (
input logic CLK,
output logic nRST,
datapath_cache_if.dp dpif
);

//define localparams
localparam PROPAGATION_DELAY = 0.8; // Allow for 800 ps for FF propagation delay
localparam CLK_PERIOD = 10;

//define test signals
logic expected_dmemREN;
logic expected_dmemWEN;
logic expected_imemREN;
logic expected_halt;
logic [31:0] expected_imemaddr;
logic [31:0] expected_dmemaddr;
logic [31:0] expected_dmemstore;

//define arrays
logic [31:0] instr1;
logic [31:0] instr2;
logic [31:0] instr3;
logic [31:0] instr4;
logic [31:0] instr5;
logic [31:0] instr6;
logic [31:0] instr7;
logic [31:0] instr8;
logic [31:0] instr9;
logic [31:0] instr10;
logic [31:0] [9:0] instrArray;

logic [31:0] [9:0] dataArray;

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

  task fakemem(
    input int delay,
    input logic [31:0] [9:0] instructions,
    input logic [31:0] [9:0] data
  
  ); begin
    //fake dmemREN and response
    if(!(dpif.dmemREN || dpif.dmemWEN)) dpif.dhit = 0;
    if(!dpif.imemREN) dpif.ihit = 0;

    if(dpif.dmemREN == 1) begin
        dpif.dmemload = data[dpif.dmemaddr / 4];  
        #(delay * (CLK_PERIOD)); //fake delay
        dpif.dhit = 1;
        check_output("Data Read: ");
        #CLK_PERIOD;
    end

    //fake imemREN and response
    if(dpif.imemREN == 1) begin
        //fake responses
        dpif.imemload = instructions[dpif.imemaddr / 4];
        #(delay * (CLK_PERIOD)); //fake delay
        dpif.ihit = 1;
        check_output("imemload: ");
        #CLK_PERIOD;
    end

    if(dpif.dmemWEN == 1) begin
        data[dpif.dmemaddr / 4] = dpif.dmemstore;
        #(delay * (CLK_PERIOD)); //fake delay
        dpif.dhit = 1;
        check_output("Data Write: ");
        #CLK_PERIOD;
    end
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
    if(expected_imemREN == dpif.imemREN) begin // Check passed
      //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect imemREN %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_imemREN, dpif.imemREN);
      tb_num_wrong = tb_num_wrong + 1;
      tb_total_tests = tb_total_tests + 1;
    end

    if(expected_dmemREN == dpif.dmemREN) begin // Check passed
      //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect dmemREN %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_dmemREN, dpif.dmemREN);
      tb_num_wrong = tb_num_wrong + 1;
      tb_total_tests = tb_total_tests + 1;
    end

    if(expected_dmemWEN == dpif.dmemWEN) begin // Check passed
      //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect dmemWEN %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_dmemWEN, dpif.dmemWEN);
      tb_num_wrong = tb_num_wrong + 1;
      tb_total_tests = tb_total_tests + 1;
    end

    if(expected_imemaddr == dpif.imemaddr) begin // Check passed
      //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect imemaddr %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_imemaddr, dpif.imemaddr);
      tb_num_wrong = tb_num_wrong + 1;
      tb_total_tests = tb_total_tests + 1;
    end

    if(expected_dmemaddr == dpif.dmemaddr) begin // Check passed
      //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect dmemaddr %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_dmemaddr, dpif.dmemaddr);
      tb_num_wrong = tb_num_wrong + 1;
      tb_total_tests = tb_total_tests + 1;
    end

    if(expected_dmemstore == dpif.dmemstore) begin // Check passed
      //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect dmemstore %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_dmemstore, dpif.dmemstore);
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
tb_test_case = "Normal Operation";

// Define the test data stream for this test case

nRST = 1;

for(int delay = 1; delay < 2; delay++) begin
    // Set opcode and inputs
    dpif.dhit = 0;
    dpif.ihit = 0;
    dpif.imemload = 0;
    dpif.dmemload = 0;

    //set expected signals
    expected_dmemREN = 0;
    expected_dmemWEN = 0;
    expected_imemREN = 1;
    expected_imemaddr = 0;
    expected_dmemaddr = 0;
    expected_dmemstore = 0;

    //make fake instructions 1-10
    instrArray [0] = {ADDI, 6'd0, 6'd2, 16'd10};
    instrArray [1] = {LW, 6'd0, 6'd3, 16'd1};
    instrArray [2] = {BEQ, 6'd2, 6'd3, 16'd10};
    instrArray [3] = {SW, 6'd0, 6'd2, 16'd10};
    instrArray [4] = {JAL, 6'd0, 6'd0, 16'd6};
    instrArray [5] = {RTYPE, 6'd2, 6'd3, 6'd4, 4'd0, SUB};
    instrArray [6] = {RTYPE, 6'd3, 6'd2, 6'd5, 4'd0, SUB};
    instrArray [7] = {RTYPE, 6'd1, 6'd3, 6'd3, 4'd0, SLLV};
    instrArray [8] = {BNE, 6'd2, 6'd3, 16'd10};
    instrArray [9] = {HALT, 6'd0, 6'd0, 16'd0};

    //Data array (fake ram)
    dataArray [0] = 1;
    dataArray [1] = 2;
    dataArray [2] = 3;
    dataArray [3] = 4;
    dataArray [4] = 5;
    dataArray [5] = 6;
    dataArray [6] = 7;
    dataArray [7] = 8;
    dataArray [8] = 9;
    dataArray [9] = 0;

    reset(); //reset to init imemREN/dmemREN/dmemWEN

    for(int i = 1; i < 10; i++) begin
        $display("Loop: %d:%d", delay, i);
        expected_imemaddr = 4 * i;
        fakemem(delay, instrArray, dataArray);
        expected_dmemaddr = 4 * i;
        fakemem(delay, instrArray, dataArray);
    end
end


//Summary
$display("\nTotal tests: %d \nTotal correct: %d \nTotal wrong: %d \n", tb_total_tests, tb_num_right, tb_num_wrong);
$stop();
end
endprogram
