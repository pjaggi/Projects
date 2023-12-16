/*
hazard_tb.sv
9/23/23
Pranay Jaggi
437-03
Version 1.0
*/

// mapped needs this
`include "forwarding_unit_if.vh"
import cpu_types_pkg::*;

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module forwarding_unit_tb;
  parameter CLK_PERIOD = 10;
  //logic CLK = 0, nRST = 1;
  // clock
  //always #(CLK_PERIOD/2) CLK++;
  // interface
  forwarding_unit_if fuif();
  // test program
  test PROG (.fuif);
  // DUT
`ifndef MAPPED
  forwarding_unit FU(fuif);
`else
  forwarding_unit FU(
    .\fuif.DEIFinst (fuif.DEIFinst),
    .\fuif.EMIFinst (fuif.EMIFinst),
    .\fuif.MWIFinst (fuif.MWIFinst),
    .\fuif.rdat1 (fuif.rdat1),
    .\fuif.rdat2 (fuif.rdat2),
    .\fuif.ALU_A (fuif.ALU_B),
    .\fuif.alu_result_emif (fuif.alu_result_emif),
    .\fuif.alu_result_mwif (fuif.alu_result_mwif),
    .\fuif.dload_emif (fuif.dload_emif),
    .\fuif.dload_mwif (fuif.dload_mwif),
    .\fuif.DEIFRegWrite (fuif.DEIFRegWrite),
    .\fuif.EMIFRegWrite (fuif.EMIFRegWrite),
    .\fuif.MWIFRegWrite (fuif.MWIFRegWrite),
  );
`endif

endmodule

program test (
forwarding_unit_if.tb fuif
);

//define localparams
localparam PROPAGATION_DELAY = 0.8; // Allow for 800 ps for FF propagation delay
//localparam CLK_PERIOD = 10;
//define test signals
logic [31:0] expected_ALU_A;
logic [31:0] expected_ALU_B;

// Declare Test Case Signals
integer tb_test_num;
string  tb_test_case;
string  tb_stream_check_tag;
logic   tb_mismatch;
logic   tb_check;

logic EMIFA;
logic MWIFA;
logic EMIFB;
logic MWIFB;

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
      if((expected_ALU_A) == fuif.ALU_A) begin // Check passed
        //$display("Correct");
        //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
        tb_num_right = tb_num_right + 1;
        tb_total_tests = tb_total_tests + 1;
      end
      else begin // Check failed
        tb_mismatch = 1'b1;
        //$display("Incorrect");
        $display("Incorrect ALU_A %s %d %d %d during %s test case expected val %d real val %d", check_tag, i, j, k, tb_test_case, expected_ALU_A, fuif.ALU_A);
        tb_num_wrong = tb_num_wrong + 1;
        tb_total_tests = tb_total_tests + 1;
      end
      if((expected_ALU_B) == fuif.ALU_B) begin // Check passed
        //$display("Correct");
        //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
        tb_num_right = tb_num_right + 1;
        tb_total_tests = tb_total_tests + 1;
      end
      else begin // Check failed
        tb_mismatch = 1'b1;
        //$display("Incorrect");
        $display("Incorrect ALU_B %s %d %d %d during %s test case expected val %d real val %d", check_tag, i, j, k, tb_test_case, expected_ALU_B, fuif.ALU_B);
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
  EMIFA = 0;
  MWIFA = 0;
  EMIFB = 0;
  MWIFB = 0;

  expected_ALU_A = 0;
  expected_ALU_B = 0;

  fuif.DEIFInst = 0;
  fuif.EMIFInst = 0;
  fuif.MWIFInst = 0;
  fuif.rdat1 = 32'haaaa;
  fuif.rdat2 = 32'hbbbb;
  fuif.alu_result_emif = 32'habcd;
  fuif.alu_result_mwif = 32'hdcba;
  fuif.dload_emif = 32'hdead;
  fuif.dload_mwif = 32'hbeef;
  fuif.DEIFRegWrite = 0;
  fuif.EMIFRegWrite = 0;
  fuif.MWIFRegWrite = 0;



//TEST CASES

    //testing rdat default
    fuif.DEIFRegWrite = 1;
    fuif.EMIFRegWrite = 1;
    fuif.MWIFRegWrite = 1;
    for(int i = 0; i < 16; i++) begin
        //rt
        fuif.DEIFInst = 1 << i;
        for(int j = 0; j < 25; j++) begin
            //rd
            fuif.EMIFInst = 1 << j;
            for(int k = 0; k < 25; k++) begin
                //rd
                fuif.MWIFInst = 1 << k;
                //init expected
                    expected_ALU_A = fuif.rdat1;
                    expected_ALU_B = fuif.rdat2;

                //output logic
                    //Rtype
                    if((fuif.EMIFRegWrite && (fuif.EMIFInst[15:11] != 0 && fuif.EMIFInst[31:26] == 0)) && 
                    fuif.EMIFInst[15:11] == fuif.DEIFInst[25:21] && 
                    fuif.EMIFInst[31:26] != LW && fuif.EMIFInst[31:26] != SW /*&& 
                    fuif.MWIFInst[31:26] != BEQ && fuif.MWIFInst[31:26] != BNE*/) begin// && fuif.EMIFInst[31:26] != LW)
                        EMIFA = 1;
                    end
                    //if write from prev. instr to valid address      and destination register matches B of current instruction then forward B
                    else if((fuif.EMIFRegWrite && (fuif.EMIFInst[15:11] != 0 && fuif.EMIFInst[31:26] == 0)) && 
                    fuif.EMIFInst[15:11] == fuif.DEIFInst[20:16] && 
                    fuif.EMIFInst[31:26] != LW && fuif.EMIFInst[31:26] != SW /*&& 
                    fuif.MWIFInst[31:26] != BEQ && fuif.MWIFInst[31:26] != BNE*/) begin// && fuif.EMIFInst[31:26] != LW)
                        EMIFB = 1;
                    end
                    //if write from prev. instr to valid address      and destination register matches A of current instruction then forward A
                    else if((fuif.MWIFRegWrite && (fuif.MWIFInst[15:11] != 0 && fuif.MWIFInst[31:26] == 0)) && 
                    fuif.MWIFInst[15:11] == fuif.DEIFInst[25:21] && 
                    fuif.MWIFInst[31:26] != LW && fuif.MWIFInst[31:26] != SW) begin// && fuif.MWIFInst[31:26] != LW)
                        MWIFA = 1;
                    end
                    //if write from prev. instr to valid address      and destination register matches B of current instruction then forward B
                    else if((fuif.MWIFRegWrite && (fuif.MWIFInst[15:11] != 0 && fuif.MWIFInst[31:26] == 0)) && 
                    fuif.MWIFInst[15:11] == fuif.DEIFInst[20:16] && 
                    fuif.MWIFInst[31:26] != LW && fuif.MWIFInst[31:26] != SW) begin// && fuif.MWIFInst[31:26] != LW)
                        MWIFB = 1;
                    end

                    //I-TYPE//
                    else if((fuif.EMIFRegWrite && (fuif.EMIFInst[20:16] != 0 && fuif.EMIFInst[31:26] != 0)) && 
                    fuif.EMIFInst[20:16] == fuif.DEIFInst[25:21] && 
                    fuif.EMIFInst[31:26] != LW && fuif.EMIFInst[31:26] != SW /*&& 
                    fuif.MWIFInst[31:26] != BEQ && fuif.MWIFInst[31:26] != BNE*/) begin
                        EMIFA = 1;
                    end
                    //if write from prev. instr to valid address      and destination register matches B of current instruction then forward B
                    else if((fuif.EMIFRegWrite && (fuif.EMIFInst[20:16] != 0 && fuif.EMIFInst[31:26] != 0)) && 
                    fuif.EMIFInst[20:16] == fuif.DEIFInst[20:16] && 
                    fuif.EMIFInst[31:26] != LW && fuif.EMIFInst[31:26] != SW /*&& 
                    fuif.MWIFInst[31:26] != BEQ && fuif.MWIFInst[31:26] != BNE*/) begin
                        EMIFB = 1;
                    end
                    //if write from prev. instr to valid address      and destination register matches A of current instruction then forward A
                    else if((fuif.MWIFRegWrite && (fuif.MWIFInst[20:16] != 0 && fuif.MWIFInst[31:26] != 0)) && 
                    fuif.MWIFInst[20:16] == fuif.DEIFInst[25:21] && 
                    fuif.MWIFInst[31:26] != LW && fuif.MWIFInst[31:26] != SW) begin
                        MWIFA = 1;
                    end
                    //if write from prev. instr to valid address      and destination register matches B of current instruction then forward B
                    else if((fuif.MWIFRegWrite && (fuif.MWIFInst[20:16] != 0 && fuif.MWIFInst[31:26] != 0)) && 
                    fuif.MWIFInst[20:16] == fuif.DEIFInst[20:16] && 
                    fuif.MWIFInst[31:26] != LW && fuif.MWIFInst[31:26] != SW) begin
                        MWIFB = 1;
                    end
                    else if(fuif.DEIFInst[31:26] == LUI && fuif.EMIFRegWrite == 1) begin
                        EMIFB = 1;
                    end
                    expected_ALU_A = fuif.rdat1;
                    if(EMIFA) begin
                        expected_ALU_A = fuif.alu_result_emif;
                    end
                    else if(MWIFA) begin
                        expected_ALU_A = fuif.alu_result_mwif;
                    end

                    else if(fuif.DEIFInst[25:21] == fuif.MWIFInst[20:16] && fuif.MWIFInst[31:26] == LW) begin
                        expected_ALU_A = fuif.dload_mwif;
                    end
                    expected_ALU_B = fuif.rdat2;
                    if(EMIFB) begin
                        expected_ALU_B = fuif.alu_result_emif;
                    end
                    else if(MWIFB) begin
                        expected_ALU_B = fuif.alu_result_mwif;
                    end

                    else if(fuif.DEIFInst[20:16] == fuif.MWIFInst[20:16] && fuif.MWIFInst[31:26] == LW) begin
                        expected_ALU_B = fuif.dload_mwif;
                    end
                #(1);
                check_output("After outer loop, inner loop", i, j, k);
            end 
        end
    end

    //reset
        fuif.DEIFRegWrite = 0;
        fuif.EMIFRegWrite = 0;
        fuif.MWIFRegWrite = 0;
        fuif.EMIFInst[31:26] = 0;
        fuif.EMIFInst[15:11] = 0;
        fuif.DEIFInst[31:26] = 0;
        fuif.DEIFInst[20:16] = 0;

    //test r-type emif a
    fuif.DEIFRegWrite = 1;
    fuif.EMIFRegWrite = 1;
    fuif.MWIFRegWrite = 0;
    fuif.EMIFInst[31:26] = 0;
    fuif.EMIFInst[15:11] = 1;
    fuif.DEIFInst[31:26] = 0;
    fuif.DEIFInst[25:21] = 1;

    expected_ALU_A = fuif.alu_result_emif;
    check_output("emifa test", 0, 0, 0);

    //reset
        fuif.DEIFRegWrite = 0;
        fuif.EMIFRegWrite = 0;
        fuif.MWIFRegWrite = 0;
        fuif.EMIFInst[31:26] = 0;
        fuif.EMIFInst[15:11] = 0;
        fuif.DEIFInst[31:26] = 0;
        fuif.DEIFInst[20:16] = 0;

    //test r-type emif b
    fuif.DEIFRegWrite = 1;
    fuif.EMIFRegWrite = 1;
    fuif.MWIFRegWrite = 0;
    fuif.EMIFInst[31:26] = 0;
    fuif.EMIFInst[15:11] = 1;
    fuif.DEIFInst[31:26] = 0;
    fuif.DEIFInst[20:16] = 1;

    expected_ALU_A = fuif.alu_result_emif;
    check_output("emifb test", 0, 0, 0);

    //reset
        fuif.DEIFRegWrite = 0;
        fuif.EMIFRegWrite = 0;
        fuif.MWIFRegWrite = 0;
        fuif.EMIFInst[31:26] = 0;
        fuif.EMIFInst[15:11] = 0;
        fuif.DEIFInst[31:26] = 0;
        fuif.DEIFInst[20:16] = 0;

    //test r-type mwif a
    fuif.DEIFRegWrite = 0;
    fuif.EMIFRegWrite = 1;
    fuif.MWIFRegWrite = 1;
    fuif.EMIFInst[31:26] = 0;
    fuif.EMIFInst[15:11] = 1;
    fuif.MWIFInst[31:26] = 0;
    fuif.MWIFInst[25:21] = 1;

    expected_ALU_A = fuif.alu_result_emif;
    check_output("emifa test", 0, 0, 0);

    //reset
        fuif.DEIFRegWrite = 0;
        fuif.EMIFRegWrite = 0;
        fuif.MWIFRegWrite = 0;
        fuif.EMIFInst[31:26] = 0;
        fuif.EMIFInst[15:11] = 0;
        fuif.DEIFInst[31:26] = 0;
        fuif.DEIFInst[20:16] = 0;

    //test r-type mwif b
    fuif.DEIFRegWrite = 0;
    fuif.EMIFRegWrite = 1;
    fuif.MWIFRegWrite = 1;
    fuif.EMIFInst[31:26] = 0;
    fuif.EMIFInst[15:11] = 1;
    fuif.MWIFInst[31:26] = 0;
    fuif.MWIFInst[20:16] = 1;

    expected_ALU_A = fuif.alu_result_emif;
    check_output("emifb test", 0, 0, 0);

    //reset
        fuif.DEIFRegWrite = 0;
        fuif.EMIFRegWrite = 0;
        fuif.MWIFRegWrite = 0;
        fuif.EMIFInst[31:26] = 0;
        fuif.EMIFInst[15:11] = 0;
        fuif.DEIFInst[31:26] = 0;
        fuif.DEIFInst[20:16] = 0;

    //test i-type emif a
    fuif.DEIFRegWrite = 1;
    fuif.EMIFRegWrite = 1;
    fuif.MWIFRegWrite = 0;
    fuif.EMIFInst[31:26] = 1;
    fuif.EMIFInst[20:16] = 1;
    fuif.DEIFInst[31:26] = 0;
    fuif.DEIFInst[25:21] = 1;

    expected_ALU_A = fuif.alu_result_emif;
    check_output("emifa test", 0, 0, 0);

    //reset
        fuif.DEIFRegWrite = 0;
        fuif.EMIFRegWrite = 0;
        fuif.MWIFRegWrite = 0;
        fuif.EMIFInst[31:26] = 0;
        fuif.EMIFInst[15:11] = 0;
        fuif.DEIFInst[31:26] = 0;
        fuif.DEIFInst[20:16] = 0;

    //test i-type emif b
    fuif.DEIFRegWrite = 1;
    fuif.EMIFRegWrite = 1;
    fuif.MWIFRegWrite = 0;
    fuif.EMIFInst[31:26] = 1;
    fuif.EMIFInst[20:16] = 1;
    fuif.DEIFInst[31:26] = 0;
    fuif.DEIFInst[20:16] = 1;

    expected_ALU_A = fuif.alu_result_emif;
    check_output("emifb test", 0, 0, 0);

    //reset
        fuif.DEIFRegWrite = 0;
        fuif.EMIFRegWrite = 0;
        fuif.MWIFRegWrite = 0;
        fuif.EMIFInst[31:26] = 0;
        fuif.EMIFInst[15:11] = 0;
        fuif.DEIFInst[31:26] = 0;
        fuif.DEIFInst[20:16] = 0;

    //test i-type mwif a
    fuif.DEIFRegWrite = 0;
    fuif.EMIFRegWrite = 1;
    fuif.MWIFRegWrite = 1;
    fuif.EMIFInst[31:26] = 1;
    fuif.EMIFInst[20:16] = 1;
    fuif.MWIFInst[31:26] = 0;
    fuif.MWIFInst[25:21] = 1;

    expected_ALU_A = fuif.alu_result_emif;
    check_output("emifa test", 0, 0, 0);

    //reset
        fuif.DEIFRegWrite = 0;
        fuif.EMIFRegWrite = 0;
        fuif.MWIFRegWrite = 0;
        fuif.EMIFInst[31:26] = 0;
        fuif.EMIFInst[15:11] = 0;
        fuif.DEIFInst[31:26] = 0;
        fuif.DEIFInst[20:16] = 0;

    //test i-type mwif b
    fuif.DEIFRegWrite = 0;
    fuif.EMIFRegWrite = 1;
    fuif.MWIFRegWrite = 1;
    fuif.EMIFInst[31:26] = 1;
    fuif.EMIFInst[20:16] = 1;
    fuif.MWIFInst[31:26] = 0;
    fuif.MWIFInst[20:16] = 1;

    expected_ALU_A = fuif.alu_result_emif;
    check_output("emifb test", 0, 0, 0);

//Summary
$display("\nTotal tests: %d \nTotal correct: %d \nTotal wrong: %d \n", tb_total_tests, tb_num_right, tb_num_wrong);
$stop();
end
endprogram