`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"
`include "caches_if.vh"

import cpu_types_pkg::*;

`timescale 1 ns / 1 ns

module icache_tb;
  parameter CLK_PERIOD = 10;
  logic CLK = 0, nRST = 1;
  // clock
  always #(CLK_PERIOD/2) CLK++;
  // interface
  datapath_cache_if dcif();
  caches_if cif();
  // test program
  test PROG (.CLK, .nRST, .dcif, .cif);
  // DUT
`ifndef MAPPED
  icache DUT(CLK, nRST, dcif, cif);
`else
  icache DUT(
    .\dcif.imemREN (dcif.imemREN),
    .\dcif.imemaddr (cdcif.imemaddr),
    .\dcif.ihit (dcif.ihit),
    .\dcif.imemload (dcif.imemload),
    .\cif.iwait (cif.iwait),
    .\cif.iload (cif.iload),
    .\cif.iREN (cif.iREN),
    .\cif.iaddr (cif.iaddr)
  );
`endif
endmodule

program test(
    input logic CLK,
    output logic nRST,
    datapath_cache_if.icache dcif,
    caches_if.icache cif
);
parameter CLK_PERIOD = 10;
import cpu_types_pkg::*;
logic tb_mismatch;
logic tb_check;
int tb_num_right;
int tb_num_wrong;
int tb_total_tests;
int tb_test_num = 0;
string  tb_test_case;
logic expected_ihit = 0;
logic expected_iREN = 0;
logic expected_iaddr = 0;
logic expected_imemload = 0;

task check_output;
    input string check_tag;
  begin
    tb_mismatch = 1'b0;
    tb_check    = 1'b1;
    
    //Add delay to show signals
    #(1);
    //check Out
    if(expected_ihit == dcif.ihit) begin // Check passed
      //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect ihit %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_ihit, dcif.ihit);
      tb_num_wrong = tb_num_wrong + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    //check Neg
    if(expected_iREN == cif.iREN) begin // Check passed
      //$display("Correct rdat2 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat2, rfif.rdat2);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect iREN %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_iREN, cif.iREN);
      tb_num_wrong = tb_num_wrong + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    if(expected_iaddr == cif.iaddr) begin // Check passed
      //$display("Correct rdat2 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat2, rfif.rdat2);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect iaddr %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_iaddr, cif.iaddr);
      tb_num_wrong = tb_num_wrong + 1;
      tb_total_tests = tb_total_tests + 1;
    end

    if(expected_imemload == dcif.imemload) begin // Check passed
      //$display("Correct rdat2 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat2, rfif.rdat2);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect imemload %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_imemload, dcif.imemload);
      tb_num_wrong = tb_num_wrong + 1;
      tb_total_tests = tb_total_tests + 1;
    end

    // Wait some small amount of time so check pulse timing is visible on waves
    #(0.1);
    tb_check =1'b0;
    #(0.5);
  end
endtask

task fake_mem;
    input logic [31:0] addr;
    input logic REN;
    output logic [31:0] value;

    begin
        if(REN) begin
            if(addr == 0) begin
                value = 0;    
            end
            else if(addr == 4) begin
                value = 4;
            end
            else if(addr == 8) begin
                value = 8;
            end
            else if(addr == 12) begin
                value = 12;
            end
            else begin
                value = 1111;
            end
        end
        else begin
            value = 9999;
        end
    end
endtask

task miss;
    input logic [31:0] addr;

    begin
        dcif.imemaddr = addr;
        dcif.imemREN = 1;
        expected_ihit = 0;
        expected_iREN = 1;
        expected_iaddr = addr;
        fake_mem(addr, 1, cif.iload);
        @(posedge CLK);
        check_output("during miss: ");
    end
endtask

task hit;
    input logic [31:0] addr;

    begin
        expected_ihit = 1;
        expected_iaddr = 0;
        expected_iREN = 0;
        @(posedge CLK);
        check_output("during hit: ");
    end
endtask

task reset;
    nRST = 0;
    #CLK_PERIOD;
    nRST = 1;
    #CLK_PERIOD;
endtask

initial begin
    cif.iwait = 0;
    dcif.imemREN = 0;
    
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Normal Operation: MISS, HIT: ";
    reset();
    miss(0);
    hit(0);

    
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Normal Operation: MISS, HIT MULTIPLE: ";
    reset();
    miss(0);
    miss(4);
    miss(8);
    hit(0);
    hit(4);
    hit(8);

    //Summary
    $display("\nTotal tests:   %d \nTotal correct: %d \nTotal wrong:   %d \n", tb_total_tests, tb_num_right, tb_num_wrong);
    $stop();
end
endprogram