`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"
`include "caches_if.vh"
`include "cache_control_if.vh"

import cpu_types_pkg::*;

`timescale 1 ns / 1 ns

module dcache_tb;
  parameter CLK_PERIOD = 10;
  logic CLK = 0, nRST = 1;
  // clock
  always #(CLK_PERIOD/2) CLK++;
  // interface
  datapath_cache_if dcif();
  caches_if cif();
  cache_control_if ccif();
  // test program
  test PROG (.CLK, .nRST, .dcif, .cif);
  // DUT
`ifndef MAPPED
  dcache DUT(CLK, nRST, dcif, cif);
  dcache DUT2(CLK, nRST, dcif, cif);
  memory_control MEMC(CLK, nRST, ccif);
`else
  dcache DUT(
    .\dcif.halt(dcif.halt),
    .\dcif.dmemREN (dcif.dmemREN),
    .\dcif.dmemWEN (dcif.dmemWEN),
    .\dcif.dmemstore (dcif.dmemstore),
    .\dcif.dmemaddr (dcif.dmemaddr),
    .\dcif.dhit (dcif.dhit),
    .\dcif.dmemload (dcif.dmemload),
    .\cif.dwait (cif.dwait),
    .\cif.dload (cif.dload),
    .\cif.ccwait(cif.ccwait),
    .\cif.ccinv(cif.ccinv),
    .\cif.ccsnoopaddr(cif.ccsnoopaddr),
    .\cif.dREN (cif.dREN),
    .\cif.dWEN (cif.dWEN),
    .\cif.daddr (cif.daddr),
    .\cif.dstore (cif.dstore),
    .\cif.ccwrite(cif.ccwrite),
    .\cif.cctrans(cif.cctrans)
  );
  dcache DUT2(
    .\dcif.halt(dcif.halt),
    .\dcif.dmemREN (dcif.dmemREN),
    .\dcif.dmemWEN (dcif.dmemWEN),
    .\dcif.dmemstore (dcif.dmemstore),
    .\dcif.dmemaddr (dcif.dmemaddr),
    .\dcif.dhit (dcif.dhit),
    .\dcif.dmemload (dcif.dmemload),
    .\cif.dwait (cif.dwait),
    .\cif.dload (cif.dload),
    .\cif.ccwait(cif.ccwait),
    .\cif.ccinv(cif.ccinv),
    .\cif.ccsnoopaddr(cif.ccsnoopaddr),
    .\cif.dREN (cif.dREN),
    .\cif.dWEN (cif.dWEN),
    .\cif.daddr (cif.daddr),
    .\cif.dstore (cif.dstore),
    .\cif.ccwrite(cif.ccwrite),
    .\cif.cctrans(cif.cctrans)
  );
  memory_control MEMC(
    .\ccif.iREN (ccif.iREN),
    .\ccif.dREN (ccif.dREN),
    .\ccif.dWEN (ccif.dWEN), 
    .\ccif.dstore (ccif.dstore),
    .\ccif.iaddr (ccif.iaddr),
    .\ccif.daddr (ccif.daddr),
    .\ccif.ramload (ccif.ramload),
    .\ccif.ramstate (ccif.ramstate),
    .\ccif.ccwrite (ccif.ccwrite),
    .\ccif.cctrans (ccif.cctrans), 
    .\ccif.ramstore (ccif.ramstore), 
    .\ccif.ramaddr (ccif.ramadd), 
    .\ccif.ramWEN (ccif.ramWEN), 
    .\ccif.ramREN (ccif.ramREN),  
    .\ccif.ccwait (ccif.ccwait),
    .\ccif.ccinv (ccif.ccinv),
    .\ccif.ccsnoopaddr (ccif.ccsnoopaddr)
  );
`endif
endmodule

program test(
    input logic CLK,
    output logic nRST,
    datapath_cache_if.dcache dcif,
    caches_if.dcache cif
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

task reset;
    nRST = 0;
    #CLK_PERIOD;
    nRST = 1;
    #CLK_PERIOD;
endtask

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

initial begin
    dcif.dmemREN = 0;
    dcif.dmemWEN = 0;
    dcif.dmemaddr = 0;
    dcif.dmemstore = 0;
    dcif.dmemload = 0;
    dcif.halt = 0;
    cif.dwait = 0;
    cif.dload = 0;
    cif.dREN = 0;
    cif.daddr = 0;
    cif.ccwait = 0;
    cif.ccinv = 0;
    cif.ccsnoopaddr = 0;
    cif.ccwrite = 0;
    cif.cctrans = 0;
    

// ************************************************************************
// Test Case 1: Cache Hit
// ************************************************************************
tb_test_num  = tb_test_num + 1;
tb_test_case = "Cache Hit";

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
//check dhit set to 1
//verify dmemload has correct data

// ************************************************************************
// Test Case 2: Cache Miss
// ************************************************************************
tb_test_num  = tb_test_num + 1;
tb_test_case = "Cache Hit";

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
//check dhit set to 1
//verify dmemload has correct data

// ************************************************************************
// Test Case 3: Snoop Request
// ************************************************************************
tb_test_num  = tb_test_num + 1;
tb_test_case = "Cache Hit";

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
//check dhit set to 1
//verify dmemload has correct data

    //CACHE MISS
    dcif.dmemaddr = //make sure addr not in cache
    dcif.dmemREN = 1;
    //check dhit set to 0

    //WRITE OPERATION
    dcif.dmemaddr = //addr of preloaded data
    dcif.dmemstore = //new data
    dcif.dmemWEN = 1;
    //state line should transition to modified
    //simulate eviction or snoop request
    //check and make sure cif.dWEN is set and cif.dstore has correct data

    //SNOOP REQUEST
    cif.ccsnoopaddr = 

    //COHERENCE PROTOCOL
    

    dcif.halt = 1;
    //Summary
    $display("\nTotal tests:   %d \nTotal correct: %d \nTotal wrong:   %d \n", tb_total_tests, tb_num_right, tb_num_wrong);
    $stop();
end
endprogram