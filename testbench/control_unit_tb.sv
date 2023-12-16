/*
control_unit.sv
8/27/23
Michael Fuchs
437-03
Version 1.0
CU_TB
*/

// mapped needs this
`include "control_unit_if.vh"
import cpu_types_pkg::*;

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module control_unit_tb;
  parameter CLK_PERIOD = 10;
  logic CLK = 0, nRST = 1;
  // clock
  always #(CLK_PERIOD/2) CLK++;
  // interface
  control_unit_if cuif();
  // test program
  test PROG (.CLK, .nRST, .cuif);
  // DUT
`ifndef MAPPED
  control_unit DUT(CLK, nRST, cuif);
`else
  control_unit DUT(
    .\cuif.Instruction (cuif.Instruction),
    .\cuif.RegDst (cuif.RegDst),
    .\cuif.Jump (cuif.Jump),
    .\cuif.JumpReg (cuif.JumpReg),
    .\cuif.JAL (cuif.JAL),
    .\cuif.Branch (cuif.Branch),
    .\cuif.BNE (cuif.BNE),
    .\cuif.MemRead (cuif.MemRead),
    .\cuif.MemToReg (cuif.MemToReg),
    .\cuif.MemWrite (cuif.MemWrite),
    .\cuif.ALUSrc (cuif.ALUSrc),
    .\cuif.RegWrite (cuif.RegWrite),
    .\cuif.Halt (cuif.Halt),
    .\cuif.SignExtend (cuif.SignExtend),
    .\cuif.ALUOp (cuif.ALUOp)
  );
`endif

endmodule

program test (
input logic CLK,
output logic nRST,
control_unit_if.tb cuif
);

//define localparams
localparam PROPAGATION_DELAY = 0.8; // Allow for 800 ps for FF propagation delay
localparam CLK_PERIOD = 10;
//define test signals
logic expected_RegDst;
logic expected_Jump;
logic expected_JumpReg;
logic expected_JAL;
logic expected_Branch;
logic expected_BNE;
logic expected_MemRead;
logic expected_MemToReg;
logic expected_MemWrite;
logic expected_ALUSrc;
logic expected_RegWrite;
logic expected_Halt;
logic expected_SignExtend;
logic [3:0] expected_ALUOp;

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

  task check_output;
    input string check_tag;
  begin
    tb_mismatch = 1'b0;
    tb_check    = 1'b1;
    
    //Add delay to show signals
    #(1);

    //check Out
    if(aluop_t'(expected_ALUOp) == cuif.ALUOp) begin // Check passed
      //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect ALUOp %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_ALUOp, cuif.ALUOp);
      tb_num_wrong = tb_num_wrong + 1;
      tb_total_tests = tb_total_tests + 1;
    end

    if(expected_RegDst == cuif.RegDst) begin // Check passed
      //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect RegDst %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_RegDst, cuif.RegDst);
      tb_num_wrong = tb_num_wrong + 1;
      tb_total_tests = tb_total_tests + 1;
    end

    if(expected_Jump == cuif.Jump) begin // Check passed
      //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect Jump %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_Jump, cuif.Jump);
      tb_num_wrong = tb_num_wrong + 1;
      tb_total_tests = tb_total_tests + 1;
    end

    if(expected_JumpReg == cuif.JumpReg) begin // Check passed
      //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect JumpReg %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_JumpReg, cuif.JumpReg);
      tb_num_wrong = tb_num_wrong + 1;
      tb_total_tests = tb_total_tests + 1;
    end

    if(expected_JAL == cuif.JAL) begin // Check passed
      //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect JAL %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_JAL, cuif.JAL);
      tb_num_wrong = tb_num_wrong + 1;
      tb_total_tests = tb_total_tests + 1;
    end

    if(expected_Branch == cuif.Branch) begin // Check passed
      //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect Branch %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_Branch, cuif.Branch);
      tb_num_wrong = tb_num_wrong + 1;
      tb_total_tests = tb_total_tests + 1;
    end

    if(expected_BNE == cuif.BNE) begin // Check passed
      //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect BNE %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_BNE, cuif.BNE);
      tb_num_wrong = tb_num_wrong + 1;
      tb_total_tests = tb_total_tests + 1;
    end

    if(expected_MemRead == cuif.MemRead) begin // Check passed
      //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect MemRead %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_MemRead, cuif.MemRead);
      tb_num_wrong = tb_num_wrong + 1;
      tb_total_tests = tb_total_tests + 1;
    end

    if(expected_MemToReg == cuif.MemToReg) begin // Check passed
      //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect MemToReg %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_MemToReg, cuif.MemToReg);
      tb_num_wrong = tb_num_wrong + 1;
      tb_total_tests = tb_total_tests + 1;
    end

    if(expected_MemWrite == cuif.MemWrite) begin // Check passed
      //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect MemWrite %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_MemWrite, cuif.MemWrite);
      tb_num_wrong = tb_num_wrong + 1;
      tb_total_tests = tb_total_tests + 1;
    end

    if(expected_ALUSrc == cuif.ALUSrc) begin // Check passed
      //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect ALUSrc %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_ALUSrc, cuif.ALUSrc);
      tb_num_wrong = tb_num_wrong + 1;
      tb_total_tests = tb_total_tests + 1;
    end

    if(expected_RegWrite == cuif.RegWrite) begin // Check passed
      //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect RegWrite %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_RegWrite, cuif.RegWrite);
      tb_num_wrong = tb_num_wrong + 1;
      tb_total_tests = tb_total_tests + 1;
    end

    if(expected_SignExtend == cuif.SignExtend) begin // Check passed
      //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect SignExtend %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_SignExtend, cuif.SignExtend);
      tb_num_wrong = tb_num_wrong + 1;
      tb_total_tests = tb_total_tests + 1;
    end

    if(expected_Halt == cuif.Halt) begin // Check passed
      //$display("Correct rdat1 %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_rdat1, rfif.rdat1);
      tb_num_right = tb_num_right + 1;
      tb_total_tests = tb_total_tests + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $display("Incorrect Halt %s during %s test case expected val %d real val %d", check_tag, tb_test_case, expected_Halt, cuif.Halt);
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
tb_test_case = "Normal Operation: R-Type";

// Define the test data stream for this test case
expected_RegDst = 0;
expected_Jump = 0;
expected_JumpReg = 0;
expected_JAL = 0;
expected_Branch = 0;
expected_BNE = 0;
expected_MemRead = 0;
expected_MemToReg = 0;
expected_MemWrite = 0;
expected_ALUSrc = 0;
expected_RegWrite = 0;
expected_Halt = 0;
expected_SignExtend = 1;
expected_ALUOp = ALU_ADD;

reset();

nRST = 1;

// Set opcode and inputs
for(int i = 0; i < 6'b111111; i++) begin
    cuif.Instruction = 32'b0;
    cuif.Instruction[5:0] = i;
    expected_ALUOp = ALU_ADD;
    expected_JumpReg = 0;
    case(funct_t'(i))
                SLLV: begin
                    expected_ALUOp = ALU_SLL;
                end
                SRLV: begin
                    expected_ALUOp = ALU_SRL;
                end
                JR: begin
                    expected_JumpReg = 1;
                end
                ADD: begin
                    expected_ALUOp = ALU_ADD;
                end
                ADDU: begin
                    expected_ALUOp = ALU_ADD;
                end
                SUB: begin
                    expected_ALUOp = ALU_SUB;
                end
                SUBU: begin
                    expected_ALUOp = ALU_SUB;
                end
                AND: begin
                    expected_ALUOp = ALU_AND;
                end
                OR: begin
                    expected_ALUOp = ALU_OR;
                end
                XOR: begin
                    expected_ALUOp = ALU_XOR;
                end
                NOR: begin
                    expected_ALUOp = ALU_NOR;
                end
                SLT: begin
                    expected_ALUOp = ALU_SLT;
                end
                SLTU: begin
                    expected_ALUOp = ALU_SLTU;
                end
            endcase
    expected_RegDst = 1;
    expected_RegWrite = 1;

    #(CLK_PERIOD);
    check_output("after Instruction changes: ");
    $display("I:%d", i);
end

// ************************************************************************
// Test Case 2: Normal Operation
// ************************************************************************
tb_test_num  = tb_test_num + 1;
tb_test_case = "Normal Operation: I/J Type";

// Define the test data stream for this test case

expected_ALUOp = ALU_ADD;
expected_RegDst = 1;
expected_Jump = 0;
expected_JumpReg = 0;
expected_JAL = 0;
expected_Branch = 0;
expected_BNE = 0;
expected_MemRead = 0;
expected_MemToReg = 0;
expected_MemWrite = 0;
expected_ALUSrc = 0;
expected_RegWrite = 1;
expected_SignExtend = 1;
expected_Halt = 0;

reset();

nRST = 1;

// Set opcode and inputs
for(int i = 1; i <= 6'b111111; i++) begin
    cuif.Instruction = 32'b0;
    cuif.Instruction[31:26] = i;
    
    expected_ALUOp = ALU_ADD;
    expected_RegDst = 0;
    expected_Jump = 0;
    expected_JumpReg = 0;
    expected_JAL = 0;
    expected_Branch = 0;
    expected_BNE = 0;
    expected_MemRead = 0;
    expected_MemToReg = 0;
    expected_MemWrite = 0;
    expected_ALUSrc = 0;
    expected_RegWrite = 0;
    expected_SignExtend = 1;
    expected_Halt = 0;

    case(opcode_t'(i))
        J: begin
            expected_Jump = 1;
            expected_ALUSrc = 1;
        end
        
        JAL: begin
            expected_Jump = 1;
            expected_ALUSrc = 1;
            expected_RegWrite = 1;
            expected_JAL = 1;
        end
        
        BEQ: begin
            expected_ALUOp = ALU_SUB;
            expected_Branch = 1;
        end
        
        BNE: begin
            expected_ALUOp = ALU_SUB;
            expected_Branch = 1;
            expected_BNE = 1;
        end

        ADDI: begin
            expected_ALUOp = ALU_ADD;
            expected_ALUSrc = 1;
            expected_RegWrite = 1;
        end

        ADDIU: begin
            expected_ALUOp = ALU_ADD;
            expected_ALUSrc = 1;
            expected_RegWrite = 1;
        end

        SLTI: begin
            expected_ALUOp = ALU_SLT;
            expected_ALUSrc = 1;
            expected_RegWrite = 1;
        end

        SLTIU: begin
            expected_ALUOp = ALU_SLTU;
            expected_ALUSrc = 1;
            expected_RegWrite = 1;
        end

        ANDI: begin
            expected_ALUOp = ALU_AND;
            expected_ALUSrc = 1;
            expected_RegWrite = 1;
            expected_SignExtend = 0;
        end

        ORI: begin
            expected_ALUOp = ALU_OR;
            expected_ALUSrc = 1;
            expected_RegWrite = 1;
            expected_SignExtend = 0;
        end

        XORI: begin
            expected_ALUOp = ALU_XOR;
            expected_ALUSrc = 1;
            expected_RegWrite = 1;
            expected_SignExtend = 0;
        end

        LUI: begin
            expected_ALUOp = ALU_ADD;
            expected_ALUSrc = 1;
            expected_RegWrite = 1;
        end

        LW: begin
            expected_ALUOp = ALU_ADD;
            expected_MemRead = 1;
            expected_MemToReg = 1;
            expected_ALUSrc = 1;
            expected_RegWrite = 1;
        end

        SW: begin
            expected_ALUOp = ALU_ADD;
            expected_MemWrite = 1;
            expected_ALUSrc = 1;
        end

        HALT: begin
            expected_Halt = 1;
        end
    endcase

    #(CLK_PERIOD);
    check_output("after Instruction changes: ");
    $display("I:%d",i);
end



//Summary
$display("\nTotal tests: %d \nTotal correct: %d \nTotal wrong: %d \n", tb_total_tests, tb_num_right, tb_num_wrong);
$stop();
end
endprogram
