`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"
`include "caches_if.vh"
`include "cache_control_if.vh"
`include "cpu_ram_if.vh"

import cpu_types_pkg::*;

`timescale 1 ns / 1 ns

module dcache_tb;
  parameter CLK_PERIOD = 10;
  logic CLK = 0, nRST = 1;
  // clock
  always #(CLK_PERIOD/2) CLK++;
  // interface
  datapath_cache_if dcif1();
  datapath_cache_if dcif2();
  caches_if cif1();
  caches_if cif2();
  // test program
  test PROG (.CLK, .nRST, .dcif1, .dcif2, .cif1, .cif2);
  // DUT
`ifndef MAPPED
  dcache DUT(CLK, nRST, dcif1.dcache, cif1.dcache);
  dcache DUT2(CLK, nRST, dcif2.dcache, cif2.dcache);
`else
  dcache DUT(
    .\dcif1.halt(dcif1.halt),
    .\dcif1.dmemREN (dcif1.dmemREN),
    .\dcif1.dmemWEN (dcif1.dmemWEN),
    .\dcif1.dmemstore (dcif1.dmemstore),
    .\dcif1.dmemaddr (dcif1.dmemaddr),
    .\dcif1.dhit (dcif1.dhit),
    .\dcif1.dmemload (dcif1.dmemload),
    .\cif1.dwait (cif1.dwait),
    .\cif1.dload (cif1.dload),
    .\cif1.ccwait(cif1.ccwait),
    .\cif1.ccinv(cif1.ccinv),
    .\cif1.ccsnoopaddr(cif1.ccsnoopaddr),
    .\cif1.dREN (cif1.dREN),
    .\cif1.dWEN (cif1.dWEN),
    .\cif1.daddr (cif1.daddr),
    .\cif1.dstore (cif1.dstore),
    .\cif1.ccwrite(cif1.ccwrite),
    .\cif1.cctrans(cif1.cctrans)
  );
  dcache DUT2(
    .\dcif2.halt(dcif2.halt),
    .\dcif2.dmemREN (dcif2.dmemREN),
    .\dcif2.dmemWEN (dcif2.dmemWEN),
    .\dcif2.dmemstore (dcif2.dmemstore),
    .\dcif2.dmemaddr (dcif2.dmemaddr),
    .\dcif2.dhit (dcif2.dhit),
    .\dcif2.dmemload (dcif2.dmemload),
    .\cif2.dwait (cif2.dwait),
    .\cif2.dload (cif2.dload),
    .\cif2.ccwait(cif2.ccwait),
    .\cif2.ccinv(cif2.ccinv),
    .\cif2.ccsnoopaddr(cif2.ccsnoopaddr),
    .\cif2.dREN (cif2.dREN),
    .\cif2.dWEN (cif2.dWEN),
    .\cif2.daddr (cif2.daddr),
    .\cif2.dstore (cif2.dstore),
    .\cif2.ccwrite(cif2.ccwrite),
    .\cif2.cctrans(cif2.cctrans)
  );
`endif
endmodule

program test(
    input logic CLK,
    output logic nRST,
    datapath_cache_if dcif1,
    datapath_cache_if dcif2,
    caches_if cif1,
    caches_if cif2
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

logic [31:0] output_value;

task reset;
    output_value = 0;
    nRST = 0;
    #CLK_PERIOD;
    nRST = 1;
    #CLK_PERIOD;
endtask

task fake_bus;
    input logic cctrans1, cctrans2, ccwrite1, ccwrite2;
    input logic dREN1, dWEN1, dREN2, dWEN2;
    input logic [31:0] dstore1, daddr1, dstore2, daddr2;
    output logic dwait1, dwait2;
    output logic [31:0] dload1, dload2;
    output logic ccwait1, ccinv1, ccwait2, ccinv2;
    output logic [31:0] ccsnoopaddr1, ccsnoopaddr2;

    begin
      dwait1 = 0;
      dwait2 = 0;
      dload1 = 0;
      dload2 = 0;
      ccwait1 = 0;
      ccinv1 = 0;
      ccsnoopaddr1 = 0;
      ccwait2 = 0;
      ccinv2 = 0;
      ccsnoopaddr2 = 0;

      if(dREN1) begin
        ccsnoopaddr2 = 4;
        cif1.dwait = 1;
        cif2.dwait = 0;
        cif2.ccwait = 1;
        cif1.ccwait = 0;
        if(cctrans2) begin
          dload1 = 32'hBEEF;
        end
        else begin
          dload1 = 32'h9999;
        end
        #(10);
      end
      else if(dREN2) begin
        ccsnoopaddr1 = daddr2;
        cif2.dwait = 1;
        cif1.dwait = 0;
        cif1.ccwait = 1;
        cif2.ccwait = 0;
        if(cctrans1) begin
          dload2 = 32'hBEEF;
        end
        else begin
          dload2 = 32'h9999;
        end
        #(10);
      end
      else if(dWEN1) begin
        ccwrite1 = 1;
        ccinv1 = 1;
      end
      else if(dWEN2) begin
        ccwrite2 = 1;
        ccinv2 = 1;
      end
      #(50);
      dwait1 = 0;
      dwait2 = 0;
      ccwait1 = 0;
      ccwait2 = 0;
    end
endtask

initial begin
  nRST = 0;
  dcif1.dmemREN = 0;
  dcif1.dmemWEN = 0;
  dcif1.dmemstore = 0;
  dcif1.dmemaddr = 0;
  dcif2.dmemREN = 0;
  dcif2.dmemWEN = 0;
  dcif2.dmemstore = 0;
  dcif2.dmemaddr = 0;
  dcif1.halt = 0;
  dcif2.halt = 0;

  cif1.dwait = 0;
  cif2.dwait = 0;
  cif1.ccwait = 0;
  cif2.ccwait = 0;

  cif1.dload = 0;
  cif2.dload = 0;
  cif1.ccinv = 0;
  cif2.ccinv = 0;
  cif1.ccsnoopaddr = 0;
  cif2.ccsnoopaddr = 0;
    
nRST = 1;
reset();
// ************************************************************************
// Test Case 1: Cache Hit
// ************************************************************************
tb_test_num  = tb_test_num + 1;
tb_test_case = "Cache Hit";
//Read in DEAD to processor 1
  dcif1.dmemREN = 1;
  dcif1.dmemaddr = 0;
  fake_bus(0, 0, 0, 0, 
  1, 0, 0, 0, 
  0, 4, 0, 0, 
  cif1.dwait, cif2.dwait,
  cif1.dload, cif2.dload, 
  cif1.ccwait, cif1.ccinv, cif1.ccsnoopaddr, cif2.ccwait, cif2.ccinv, cif2.ccsnoopaddr);
  //Verify there is a miss and it went to the right cache
  tb_check = 1;
  #(0.1);
  tb_check = 0;
  while(!dcif1.dhit) begin
    #(1);
  end
  #(2);
//Read in DEAD to processor 1
  dcif1.dmemREN = 1;
  dcif1.dmemaddr = 0;
  fake_bus(0, 0, 0, 0, 
  1, 0, 0, 0, 
  0, 4, 0, 0, 
  cif1.dwait, cif2.dwait,
  cif1.dload, cif2.dload, 
  cif1.ccwait, cif1.ccinv, cif1.ccsnoopaddr, cif2.ccwait, cif2.ccinv, cif2.ccsnoopaddr);
  //Verify there is a hit in the same cache
  tb_check = 1;
  #(0.1);
  tb_check = 0;
  while(!dcif1.dhit) begin
    #(1);
  end
  #(2);
//Read in DEAD to processor 2
  dcif2.dmemREN = 1;
  dcif2.dmemaddr = 4;
  fake_bus(0, 0, 0, 0, 
  0, 0, 1, 0, 
  0, 0, 0, 8, 
  cif1.dwait, cif2.dwait,
  cif1.dload, cif2.dload, 
  cif1.ccwait, cif1.ccinv, cif1.ccsnoopaddr, cif2.ccwait, cif2.ccinv, cif2.ccsnoopaddr);
  //Verify there is a miss in the other cache
  tb_check = 1;
  #(0.1);
  tb_check = 0;
  while(!dcif2.dhit) begin
    #(1);
  end
  #(2);
  //Verify that a snoop happened
//Read in BEEF to processor 2
  dcif2.dmemREN = 1;
  dcif2.dmemaddr = 4;
  fake_bus(0, 0, 0, 0, 
  0, 0, 1, 0, 
  0, 0, 0, 8, 
  cif1.dwait, cif2.dwait,
  cif1.dload, cif2.dload, 
  cif1.ccwait, cif1.ccinv, cif1.ccsnoopaddr, cif2.ccwait, cif2.ccinv, cif2.ccsnoopaddr);
  //Verify there is a miss and it went to the right cache
  tb_check = 1;
  #(0.1);
  tb_check = 0;
  while(!dcif2.dhit) begin
    #(1);
  end
  #(2);
  //Verify there is a miss and it went to the right cache

#(CLK_PERIOD);
@(posedge CLK);
//check dhit set to 1
//verify dmemload has correct data

  //DO NOT DELETE
  dcif1.halt = 1;
  dcif2.halt = 1;
  //Summary
  $display("\nTotal tests:   %d \nTotal correct: %d \nTotal wrong:   %d \n", tb_total_tests, tb_num_right, tb_num_wrong);
  $stop();
end
endprogram
