/*
  Eric Villasenor
  evillase@gmail.com

  register file test bench
*/

// mapped needs this
`include "alu_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module alu_tb;

  parameter PERIOD = 10;

  logic clk = 0, rst;

  // test vars
  /*int v1 = 1;
  int v2 = 4721;
  int v3 = 25119;*/

  // clock
  always #(PERIOD/2) clk++;

  // interface
  alu_if aluif ();
  // test program
  test PROG (.aluif);
  
  // DUT
`ifndef MAPPED
  alu DUT(aluif);
`else
  alu DUT(
    .\aluif.porta (aluif.porta),
    .\aluif.portb (aluif.portb),
    .\aluif.ALUOP (aluif.ALUOP),
    .\aluif.neg (aluif.neg),
    .\aluif.over (aluif.over),
    .\aluif.zero (aluif.zero),
    .\aluif.outport (aluif.outport),
  ); //does it matter which order
`endif

endmodule

program test
(
  alu_if.tb aluif
);

parameter PERIOD = 10;
logic [31:0] expected_rdata;

  initial begin
  ////////////////////////////////////////////////////////////////
  //TEST CASES
    #(PERIOD);
    aluif.porta = 0;
    aluif.portb = 1;
    aluif.ALUOP = 6;
    #(PERIOD);
    aluif.porta = 10;
    aluif.portb = 10;
    aluif.ALUOP = 3;
    #(PERIOD);
    aluif.porta = 10;
    aluif.portb = 11;
    aluif.ALUOP = 3;
    #(PERIOD);
    aluif.porta = 2147483647;
    aluif.portb = 2147483647;
    aluif.ALUOP = 2;
    #(PERIOD);
    aluif.porta = 4;
    aluif.portb = 5;
    aluif.ALUOP = 0;
    #(PERIOD);
    aluif.porta = 4;
    aluif.portb = 5;
    aluif.ALUOP = 1;
    #(PERIOD);
    aluif.porta = 32'b0010;
    aluif.portb = 32'b0110;
    aluif.ALUOP = 4;
    #(PERIOD);
    aluif.porta = 32'b0010;
    aluif.portb = 32'b0110;
    aluif.ALUOP = 5;
    #(PERIOD);
    aluif.porta = 2;
    aluif.portb = 3;
    aluif.ALUOP = 7;
    #(PERIOD);
    aluif.porta = 2;
    aluif.portb = 3;
    aluif.ALUOP = 8;
    #(PERIOD);
  end
endprogram
