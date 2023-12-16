/*
bus_controller_tb.sv
10/30/23
Pranay Jaggi
437-03
Version 1.0
BUS_CONTROLLER_TB
*/

// mapped needs this
`include "cache_control_if.vh"
`include "cpu_ram_if.vh"
// `include "system_if.vh"
`include "caches_if.vh"

import cpu_types_pkg::*;

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module memory_control_tb;
  
  parameter CLK_PERIOD = 10;

  logic CLK = 0, nRST = 1;

  // interface
  caches_if cif0();
  caches_if cif1();
  cache_control_if #(.CPUS(2)) ccif(cif0, cif1);
  cpu_ram_if ramif();
  // system_if syif();
  
  // clock
  always #(CLK_PERIOD/2) CLK++;

  // test program
  //test PROG (.CLK, .nRST, .cif0);
  test PROG (.CLK, .nRST, .cif0, .cif1, .ccif);

  //assign memory_control to ram
  // assign ramif.ramaddr = ccif.ramaddr;
  // assign ramif.ramstore = ccif.ramstore;
  // assign ramif.ramWEN = ccif.ramWEN; 
  // assign ramif.ramREN = ccif.ramREN;
  // assign ccif.ramload = ramif.ramload; 
  // assign ccif.ramstate = ramif.ramstate;

  // DUT
`ifndef MAPPED
  memory_control DUT(CLK, nRST, ccif);
  // ram DUT2(CLK, nRST, ramif);
`else
  memory_control DUT(
    //cache inputs
    .\ccif.daddr (ccif.daddr), //32 bit value
    .\ccif.iaddr (ccif.iaddr), //32 bit value
    .\ccif.dREN (ccif.dREN),
    .\ccif.dWEN (ccif.dWEN),
    .\ccif.iREN (ccif.iREN),
    .\ccif.dstore (ccif.dstore), //32 bit value
    //coherence inputs
    .\ccif.ccwrite (ccif.ccwrite),
    .\ccif.cctrans (ccif.cctrans),
    //cache outputs
    .\ccif.dwait (ccif.dwait),
    .\ccif.iwait (ccif.iwait),
    .\ccif.dload (ccif.dload), //32 bit value
    .\ccif.iload (ccif.iload) //32 bit value
    //coherence outputs
    .\ccif.ccwait (ccif.ccwait),
    .\ccif.ccinv (ccif.ccinv), 
    .\ccif.ccsnoopaddr (ccif.ccsnoopaddr) //32 bit value
  );
  ram DUT2(
    //RAM inputs
    .\ramif.ramstate (ramif.ramstate),
    .\ramif.ramload (ramif.ramload),
    //RAM outputs
    .\ramif.ramaddr (ramif.ramaddr),
    .\ramif.ramstore (ramif.ramstore),
    .\ramif.ramREN (ramif.ramREN),
    .\ramif.ramWEN (ramif.ramWEN) 
  )
`endif

endmodule

program test (
input logic CLK,
output logic nRST,
caches_if.caches cif0,
caches_if.caches cif1,
cache_control_if.cc ccif
// cpu_ram_if ramif
);

//define localparams
localparam PROPAGATION_DELAY = 0.8; // Allow for 800 ps for FF propagation delay
localparam CLK_PERIOD = 10;

// Declare Test Case Signals
integer tb_test_num;
string  tb_test_case;
string  tb_stream_check_tag;
logic   tb_mismatch;
logic   tb_check;

int   tb_total_tests;
int   tb_num_right;
int   tb_num_wrong;

  //given dump_memory task
task automatic dump_memory();
  string filename = "memcpu.hex";
  int memfd;

  //syif.tbCTRL = 1;
  cif0.daddr = 0;
  cif0.dWEN = 0;
  cif0.dREN = 0;

  memfd = $fopen(filename,"w");
  if (memfd)
    $display("Starting memory dump.");
  else
    begin $display("Failed to open %s.",filename); $finish; end

  for (int unsigned i = 0; memfd && i < 16384; i++)
  begin
    int chksum = 0;
    bit [7:0][7:0] values;
    string ihex;

    cif0.daddr = i << 2;
    cif0.dREN = 1;
    repeat (4) @(posedge CLK);
    if (cif0.dload === 0)
      continue;
    values = {8'h04,16'(i),8'h00,cif0.dload};
    foreach (values[j])
      chksum += values[j];
    chksum = 16'h100 - chksum;
    ihex = $sformatf(":04%h00%h%h",16'(i),cif0.dload,8'(chksum));
    $fdisplay(memfd,"%s",ihex.toupper());
  end //for
  if (memfd)
  begin
    //syif.tbCTRL = 0;
    cif0.dREN = 0;
    $fdisplay(memfd,":00000001FF");
    $fclose(memfd);
    $display("Finished memory dump.");
  end
endtask

task reset(); begin
  #CLK_PERIOD;
  #CLK_PERIOD;
  #CLK_PERIOD;
  #CLK_PERIOD;
  #CLK_PERIOD;
  
  nRST = 0;
  #CLK_PERIOD;
  cif0.daddr = 0;
  cif0.iaddr = 0;
  cif0.dREN = 0;
  cif0.dWEN = 0;
  cif0.iREN = 0;
  cif0.dstore = 0;
  cif0.ccwrite = 0; //actively writing the address 
  cif0.cctrans = 0; //in middle of transition MSI

  cif1.daddr = 0;
  cif1.iaddr = 0;
  cif1.dREN = 0;
  cif1.dWEN = 0;
  cif1.iREN = 0;
  cif1.dstore = 0;
  cif1.ccwrite = 0; //actively writing the address
  cif1.cctrans = 0;
  //#1;
  nRST = 1;
  #CLK_PERIOD;
end
endtask

//run tasks
initial begin
tb_test_num = 0;
#(0.1);

cif0.daddr = 0;
cif0.iaddr = 0;
cif0.dREN = 0;
cif0.dWEN = 0;
cif0.iREN = 0;
cif0.dstore = 0;
cif0.ccwrite = 0; //actively writing the address 
cif0.cctrans = 0; //in middle of transition MSI

cif1.daddr = 0;
cif1.iaddr = 0;
cif1.dREN = 0;
cif1.dWEN = 0;
cif1.iREN = 0;
cif1.dstore = 0;
cif1.ccwrite = 0; //actively writing the address
cif1.cctrans = 0; //in middle of transition MSI

nRST = 1;
// ************************************************************************
// Test Case 1
// ************************************************************************
reset();
tb_test_num  = tb_test_num + 1;
tb_test_case = "Instruction Read to Cache 0: RAM";
cif0.iREN = 1;
cif0.iaddr = 10;

// ************************************************************************
// Test Case 2
// ************************************************************************
reset();
tb_test_num  = tb_test_num + 1;
tb_test_case = "Instruction Read to Cache 1: RAM";
cif1.iREN = 1;
cif1.iaddr = 11;

// ************************************************************************
// Test Case 3
// ************************************************************************
reset();
tb_test_num  = tb_test_num + 1;
tb_test_case = "Data Read to Cache 0: RAM";
cif0.dREN = 1;
cif0.cctrans = 1;
cif0.daddr = 15;

// ************************************************************************
// Test Case 4
// ************************************************************************
reset();
tb_test_num  = tb_test_num + 1;
tb_test_case = "Data Read to Cache 1: RAM";
cif1.dREN = 1;
cif1.cctrans = 1;
cif1.daddr = 16;

// ************************************************************************
// Test Case 5
// ************************************************************************
reset();
tb_test_num  = tb_test_num + 1;
tb_test_case = "Data Write to Cache 0: RAM";
cif0.dWEN = 1;
cif0.cctrans = 1;
cif0.daddr = 17;

// ************************************************************************
// Test Case 6
// ************************************************************************
reset();
tb_test_num  = tb_test_num + 1;
tb_test_case = "Data Write to Cache 1: RAM";
cif1.dWEN = 1;
cif1.cctrans = 1;
cif1.daddr = 18;


// ************************************************************************
// Test Case 7
// ************************************************************************
reset();
tb_test_num  = tb_test_num + 1;
tb_test_case = "Data Read to Cache 0: Cache 1";
cif0.dREN = 1;
cif0.cctrans = 0;
cif0.daddr = 19;


// ************************************************************************
// Test Case 8
// ************************************************************************
reset();
tb_test_num  = tb_test_num + 1;
tb_test_case = "Data Read to Cache 1: Cache 0";
cif1.dREN = 1;
cif1.cctrans = 0;
cif1.daddr = 20;


// ************************************************************************
// Test Case 9
// ************************************************************************
reset();
tb_test_num  = tb_test_num + 1;
tb_test_case = "Data Write to Cache 0: Cache 1";
cif0.dWEN = 1;
cif0.cctrans = 0;
cif0.ccwrite = 1;
cif0.daddr = 21;


// ************************************************************************
// Test Case 10
// ************************************************************************
reset();
tb_test_num  = tb_test_num + 1;
tb_test_case = "Data Write to Cache 1: Cache 0";
cif1.dWEN = 1;
cif1.cctrans = 0;
cif1.ccwrite = 1;
cif1.daddr = 22;

#CLK_PERIOD;
#CLK_PERIOD;
#CLK_PERIOD;
#CLK_PERIOD;
#CLK_PERIOD;


tb_test_case = "Dumping Memory";
dump_memory();

//Summary
/*$display("\nTotal tests:   %d \nTotal correct: %d \nTotal wrong:   %d \n", tb_total_tests, tb_num_right, tb_num_wrong);*/
$stop();
end
endprogram
