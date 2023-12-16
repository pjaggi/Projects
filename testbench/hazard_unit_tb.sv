/*
hazard_tb.sv
9/23/23
Pranay Jaggi
437-03
Version 1.0
*/

// mapped needs this
`include "hazard_unit_if.vh"
import cpu_types_pkg::*;

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module hazard_unit_tb;
  parameter CLK_PERIOD = 10;
  //logic CLK = 0, nRST = 1;
  // clock
  //always #(CLK_PERIOD/2) CLK++;
  // interface
  hazard_unit_if haif();
  // test program
  test PROG (.haif);
  // DUT
`ifndef MAPPED
  hazard_unit HA(haif);
`else
  hazard_unit HA(
    .\haif.FDIFinst (haif.FDIFinst),
    .\haif.DEIFinst (haif.DEIFinst),
    .\haif.EMIFinst (haif.EMIFinst),
    .\haif.stallFD (haif.stallFD),
    .\haif.flushFD (haif.flushFD),
    .\haif.stallDE (haif.stallDE),
    .\haif.flushDE (haif.flushDE),
    .\haif.stallEM (haif.stallEM),
    .\haif.flushEM (haif.flushEM),
    .\haif.stallMW (haif.stallMW),
    .\haif.flushMW (haif.flushMW)
    //what else
  );
`endif

endmodule

program test (
hazard_unit_if.tb haif
);

//define localparams
localparam PROPAGATION_DELAY = 0.8; // Allow for 800 ps for FF propagation delay
//localparam CLK_PERIOD = 10;
//define test signals
logic expected_flush_FD;
logic expected_stall_FD;
logic expected_flush_DE;
logic expected_stall_DE;
logic expected_flush_EM;
logic expected_stall_EM;
logic expected_flush_MW;
logic expected_stall_MW;

// Declare Test Case Signals
integer tb_test_num;
string  tb_test_case;
string  tb_stream_check_tag;
logic   tb_mismatch;
logic   tb_check;

int   tb_total_tests;
int   tb_num_right;
int   tb_num_wrong;

  /*task reset(); begin
    nRST = 0;
    #CLK_PERIOD;
    check_output("after Reset: ");
    nRST = 1;
    #CLK_PERIOD;
  end
  endtask*/

  task check_output;
    input string check_tag;
    input int i;
    input int j;
    input int k;
  begin
    tb_mismatch = 1'b0;
    tb_check    = 1'b1;
    
    //Add delay to show signals
    #(1);

    //check Out
    //FD//
      //FLUSH - FD//
      if((expected_flush_FD) == haif.flushFD) begin // Check passed
        //$display("Correct");
        //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
        tb_num_right = tb_num_right + 1;
        tb_total_tests = tb_total_tests + 1;
      end
      else begin // Check failed
        tb_mismatch = 1'b1;
        //$display("Incorrect");
        $display("Incorrect flush_FD %s %d %d %d during %s test case expected val %d real val %d", check_tag, i, j, k, tb_test_case, expected_flush_FD, haif.flushFD);
        tb_num_wrong = tb_num_wrong + 1;
        tb_total_tests = tb_total_tests + 1;
      end
      //STALL - FD
      if((expected_stall_FD) == haif.stallFD) begin // Check passed
        //$display("Correct");
        //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
        tb_num_right = tb_num_right + 1;
        tb_total_tests = tb_total_tests + 1;
      end
      else begin // Check failed
        tb_mismatch = 1'b1;
        //$display("Incorrect");
        $display("Incorrect stall_FD %s %d %d %d during %s test case expected val %d real val %d", check_tag, i, j, k, tb_test_case, expected_stall_FD, haif.stallFD);
        tb_num_wrong = tb_num_wrong + 1;
        tb_total_tests = tb_total_tests + 1;
      end
    
    //DE
      //FLUSH - DE
      if((expected_flush_DE) == haif.flushDE) begin // Check passed
        //$display("Correct");
        //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
        tb_num_right = tb_num_right + 1;
        tb_total_tests = tb_total_tests + 1;
      end
      else begin // Check failed
        tb_mismatch = 1'b1;
        //$display("Incorrect");
        $display("Incorrect flush_DE %s %d %d %d during %s test case expected val %d real val %d", check_tag, i, j, k, tb_test_case, expected_flush_DE, haif.flushDE);
        tb_num_wrong = tb_num_wrong + 1;
        tb_total_tests = tb_total_tests + 1;
      end
      //STALL - FD
      if((expected_stall_DE) == haif.stallDE) begin // Check passed
        //$display("Correct");
        //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
        tb_num_right = tb_num_right + 1;
        tb_total_tests = tb_total_tests + 1;
      end
      else begin // Check failed
        tb_mismatch = 1'b1;
        //$display("Incorrect");
        $display("Incorrect stall_DE %s %d %d %d during %s test case expected val %d real val %d", check_tag, i, j, k, tb_test_case, expected_stall_DE, haif.stallDE);
        tb_num_wrong = tb_num_wrong + 1;
        tb_total_tests = tb_total_tests + 1;
      end
    
    //EM
      //FLUSH - EM
      if((expected_flush_EM) == haif.flushEM) begin // Check passed
        //$display("Correct");
        //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
        tb_num_right = tb_num_right + 1;
        tb_total_tests = tb_total_tests + 1;
      end
      else begin // Check failed
        tb_mismatch = 1'b1;
        //$display("Incorrect");
        $display("Incorrect flush_EM %s %d %d %d during %s test case expected val %d real val %d", check_tag, i, j, k, tb_test_case, expected_flush_EM, haif.flushEM);
        tb_num_wrong = tb_num_wrong + 1;
        tb_total_tests = tb_total_tests + 1;
      end
      //STALL - EM
      if((expected_stall_EM) == haif.stallEM) begin // Check passed
        //$display("Correct");
        //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
        tb_num_right = tb_num_right + 1;
        tb_total_tests = tb_total_tests + 1;
      end
      else begin // Check failed
        tb_mismatch = 1'b1;
        //$display("Incorrect");
        $display("Incorrect stall_EM %s %d %d %d during %s test case expected val %d real val %d", check_tag, i, j, k, tb_test_case, expected_stall_EM, haif.stallEM);
        tb_num_wrong = tb_num_wrong + 1;
        tb_total_tests = tb_total_tests + 1;
      end

    //MW
      //FLUSH - MW
      if((expected_flush_MW) == haif.flushMW) begin // Check passed
        //$display("Correct");
        //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
        tb_num_right = tb_num_right + 1;
        tb_total_tests = tb_total_tests + 1;
      end
      else begin // Check failed
        tb_mismatch = 1'b1;
        //$display("Incorrect");
        $display("Incorrect flush_MW %s %d %d %d during %s test case expected val %d real val %d", check_tag, i, j, k, tb_test_case, expected_flush_MW, haif.flushMW);
        tb_num_wrong = tb_num_wrong + 1;
        tb_total_tests = tb_total_tests + 1;
      end
      //STALL - MW
      if((expected_stall_MW) == haif.stallMW) begin // Check passed
        //$display("Correct");
        //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
        tb_num_right = tb_num_right + 1;
        tb_total_tests = tb_total_tests + 1;
      end
      else begin // Check failed
        tb_mismatch = 1'b1;
        //$display("Incorrect");
        $display("Incorrect stall_MW %s %d %d %d during %s test case expected val %d real val %d", check_tag, i, j, k, tb_test_case, expected_stall_MW, haif.stallMW);
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

// Define the test data stream for this test case
//#define word_max = 4294967296;
//SET INITIAL VALUES
  expected_flush_FD = 0;
  expected_stall_FD = 0;
  expected_flush_DE = 0;
  expected_stall_DE = 0;
  expected_flush_EM = 0;
  expected_stall_EM = 0;
  expected_flush_MW = 0;
  expected_stall_MW = 0;

  haif.FDIFinst = 0;
  haif.DEIFinst = 0;
  haif.EMIFinst = 0;
  haif.EMIFRegWrite = 1;
  haif.DEIFRegWrite = 1;

//TEST CASES

    for(int i = 0; i < 32; i++)
    begin
      haif.DEIFinst = i << 16;
      for(int j = 0; j < 32; j++)
      begin 
        haif.FDIFinst = j << 16;
        for(int k = 0; k < 32; k++)
        begin
          expected_stall_FD = 0;
          expected_stall_DE = 0;
          haif.EMIFinst = k << 16;
          if(((haif.DEIFinst[20:16] == haif.FDIFinst[20:16]) || (haif.DEIFinst[20:16] == haif.FDIFinst[25:21])) && haif.DEIFRegWrite && ((haif.FDIFinst[20:16] != '0) || (haif.DEIFinst[20:16] != '0)))begin
            expected_stall_FD = 1;
            //haif.stallDE = 1;
          end
          //detect hazard between DE and EM, useless after forwarding
          if(((haif.EMIFinst[20:16] == haif.FDIFinst[20:16]) || (haif.EMIFinst[20:16] == haif.FDIFinst[25:21])) && haif.EMIFRegWrite && ((haif.FDIFinst[20:16] != '0) || (haif.EMIFinst[20:16] != '0))) begin
              expected_stall_FD = 1;
              expected_stall_DE = 1;
          end
          if(haif.DEIFinst[31:26] == JAL && haif.DEIFRegWrite == 1) begin
              expected_stall_FD = 1;
              expected_stall_DE = 1;
          end
          if(haif.DEIFinst[31:26] == LUI && haif.EMIFRegWrite == 1) begin
              expected_stall_FD = 1;
              expected_stall_DE = 1;
          end
          check_output("1. After outer loop inner loop", i, j, k);
        end
      end
    end

    for(int i = 0; i < 32; i++)
    begin
      haif.DEIFinst = i << 21;
      for(int j = 0; j < 32; j++)
      begin 
        haif.FDIFinst = j << 21;
        for(int k = 0; k < 32; k++)
        begin
          expected_stall_FD = 0;
          expected_stall_DE = 0;
          haif.EMIFinst = k << 16;
          if(((haif.DEIFinst[20:16] == haif.FDIFinst[20:16]) || (haif.DEIFinst[20:16] == haif.FDIFinst[25:21])) && haif.DEIFRegWrite && ((haif.FDIFinst[20:16] != '0) || (haif.DEIFinst[20:16] != '0)))begin
              expected_stall_FD = 1;
          end
          //detect hazard between DE and EM, useless after forwarding
          if(((haif.EMIFinst[20:16] == haif.FDIFinst[20:16]) || (haif.EMIFinst[20:16] == haif.FDIFinst[25:21])) && haif.EMIFRegWrite && ((haif.FDIFinst[20:16] != '0) || (haif.EMIFinst[20:16] != '0))) begin
              expected_stall_FD = 1;
              expected_stall_DE = 1;
          end
          if(haif.DEIFinst[31:26] == JAL && haif.DEIFRegWrite == 1) begin
              expected_stall_FD = 1;
              expected_stall_DE = 1;
          end
          if(haif.DEIFinst[31:26] == LUI && haif.EMIFRegWrite == 1) begin
              expected_stall_FD = 1;
              expected_stall_DE = 1;
          end
          check_output("1. After outer loop inner loop", i, j, k);
        end
      end
    end
//Summary
$display("\nTotal tests: %d \nTotal correct: %d \nTotal wrong: %d \n", tb_total_tests, tb_num_right, tb_num_wrong);
$stop();
end
endprogram
