/*
dcache_tb.sv
10/17/2023
Michael Fuchs
437-03
Version 1.0
dcache_tb
*/

// mapped needs this
`include "datapath_cache_if.vh"
`include "caches_if.vh"
import cpu_types_pkg::*;

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module dcache_tb;
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
  dcache DUT(CLK, nRST, dcif, cif);
`else
  dcache DUT(
    .\dcif.halt (dcif.halt),
    .\dcif.dmemREN (dcif.dmemREN),
    .\dcif.dmemWEN (dcif.dmemWEN),
    .\dcif.datomic (dcif.datomic),
    .\dcif.dmemstore (dcif.dmemstore),
    .\dcif.dmemaddr (dcif.dmemaddr),
    .\dcif.dhit (dcif.dhit),
    .\dcif.dmemload (dcif.dmemload),
    .\dcif.flushed (dcif.flushed),
    .\cif.dwait (cif.dwait),
    .\cif.dload (cif.dload),
    .\cif.dREN (cif.dREN),
    .\cif.dWEN (cif.dWEN),
    .\cif.daddr (cif.daddr),
    .\cif.dstore (cif.dstore)
    );
`endif

endmodule

program test (
input logic CLK,
output logic nRST,
datapath_cache_if dcif,
caches_if cif
);

import cpu_types_pkg::*;
//define localparams
localparam PROPAGATION_DELAY = 0.8; // Allow for 800 ps for FF propagation delay
localparam CLK_PERIOD = 10;


//define test signals
logic [31:0] check;
logic dFormat;
logic daddr;
logic dFrame;
logic invalid_signal = 0;
logic nxt_invalid_signal = 0;
logic [4:0] counter = 0;
logic [4:0] next_counter = 0;
logic [7:0] lru = 0;


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
    nRST = 1;
    #CLK_PERIOD;
  end
  endtask

task fake_mem;
    input logic [31:0] addr;
    input logic REN;
    input logic WEN;
    output logic [31:0] value;
    input logic [31:0] input_value;

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
      else if(WEN) begin
          value = input_value;
      end
      else begin
          value = 9999;
      end
    end
endtask

//run tasks
initial begin

tb_test_num = 0;
#(0.1);

// ************************************************************************
// Test Case 1: Normal Operation, read multiple data
// ************************************************************************
tb_test_num  = tb_test_num + 1;
tb_test_case = "Normal Operation: Read Multiple Data";

reset();
for(int i = 0; i < 3; i++) begin
    dcif.dmemREN = 0;
    dcif.dmemaddr = 4 * i;
    #(CLK_PERIOD);
    dcif.dmemREN = 1;
    fake_mem(dcif.dmemaddr, dcif.dmemREN, 0, check, 0);
end
#(CLK_PERIOD);
@(posedge CLK);

// ************************************************************************
// Test Case 1: Normal Operation, read multiple data
// ************************************************************************
tb_test_num  = tb_test_num + 1;
tb_test_case = "Normal Operation: Read Multiple Data";

reset();
for(int i = 0; i < 20; i++) begin
    dcif.dmemREN = 0;
    dcif.dmemaddr = 4 * i;
    #(CLK_PERIOD);
    dcif.dmemREN = 1;
    fake_mem(dcif.dmemaddr, dcif.dmemREN, 0, check, 0);
end
#(CLK_PERIOD);
@(posedge CLK);

// ************************************************************************
// Test Case 2: Normal Operation, read same data multiple times
// ************************************************************************
tb_test_num  = tb_test_num + 1;
tb_test_case = "Normal Operation: Read Same Data Mutiple Times";

reset();
for(int i = 0; i < 20; i++) begin
    dcif.dmemREN = 0;
    dcif.dmemaddr = 4;
    #(CLK_PERIOD);
    dcif.dmemREN = 1;
    fake_mem(dcif.dmemaddr, dcif.dmemREN, 0, check, 0);
end
#(CLK_PERIOD);
@(posedge CLK);

// ************************************************************************
// Test Case 3: Normal Operation, write some data
// ************************************************************************
tb_test_num  = tb_test_num + 1;
tb_test_case = "Normal Operation: write some data";

reset();
for(int i = 0; i < 3; i++) begin
    dcif.dmemWEN = 0;
    dcif.dmemaddr = 4 * i;
    #(CLK_PERIOD);
    dcif.dmemWEN = 1;
    fake_mem(dcif.dmemaddr, 0, dcif.dmemWEN, check, i);
end
#(CLK_PERIOD);
@(posedge CLK);

// ************************************************************************
// Test Case 4: Normal Operation, halt
// ************************************************************************
tb_test_num  = tb_test_num + 1;
tb_test_case = "Normal Operation: halt";

reset();
dcif.halt = 1;
#(CLK_PERIOD);
@(posedge CLK);



//Summary
$display("\nTotal tests: %d \nTotal correct: %d \nTotal wrong: %d \n", tb_total_tests, tb_num_right, tb_num_wrong);
$stop();
end
endprogram
