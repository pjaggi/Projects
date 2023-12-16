/*
control_unit.sv
9/9/23
Michael Fuchs
437-03
Version 1.0
control unit
*/

`include "control_unit_if.vh"
import cpu_types_pkg::*;

module control_unit
(
    input logic CLK,
    input logic nRST,
    control_unit_if.cm cuif
);

logic request_halt;

always_comb begin : ControlSignal
    //default outputs
    cuif.ALUOp = ALU_ADD;
    cuif.RegDst = 0;
    cuif.Jump = 0;
    cuif.JumpReg = 0;
    cuif.JAL = 0;
    cuif.Branch = 0;
    cuif.BNE = 0;
    cuif.MemRead = 0;
    cuif.MemToReg = 0;
    cuif.MemWrite = 0;
    cuif.ALUSrc = 0;
    cuif.RegWrite = 0;
    cuif.SignExtend = 1;
    cuif.LUI = 0;
    //request_halt = 0;
    cuif.Halt = 0;
    cuif.datomic = 0;

    case(cuif.Instruction[31:26])
      //R-Type
        RTYPE: begin
            cuif.RegDst = 1;
            cuif.RegWrite = 1;
            case(funct_t'(cuif.Instruction[5:0]))
                SLLV: begin
                    cuif.ALUOp = ALU_SLL;
                end
                SRLV: begin
                    cuif.ALUOp = ALU_SRL;
                end
                JR: begin
                    cuif.JumpReg = 1;
                end
                ADD: begin
                    cuif.ALUOp = ALU_ADD;
                end
                ADDU: begin
                    cuif.ALUOp = ALU_ADD;
                end
                SUB: begin
                    cuif.ALUOp = ALU_SUB;
                end
                SUBU: begin
                    cuif.ALUOp = ALU_SUB;
                end
                AND: begin
                    cuif.ALUOp = ALU_AND;
                end
                OR: begin
                    cuif.ALUOp = ALU_OR;
                end
                XOR: begin
                    cuif.ALUOp = ALU_XOR;
                end
                NOR: begin
                    cuif.ALUOp = ALU_NOR;
                end
                SLT: begin
                    cuif.ALUOp = ALU_SLT;
                end
                SLTU: begin
                    cuif.ALUOp = ALU_SLTU;
                end
            endcase
        end
        
        J: begin
            cuif.Jump = 1;
            cuif.ALUSrc = 1;
        end
        
        JAL: begin
            cuif.Jump = 1;
            cuif.ALUSrc = 1;
            cuif.RegWrite = 1;
            cuif.JAL = 1;
        end
        
        BEQ: begin
            cuif.ALUOp = ALU_SUB;
            cuif.Branch = 1;
        end
        
        BNE: begin
            cuif.ALUOp = ALU_SUB;
            cuif.Branch = 1;
            cuif.BNE = 1;
        end

        ADDI: begin
            cuif.ALUOp = ALU_ADD;
            cuif.ALUSrc = 1;
            cuif.RegWrite = 1;
        end

        ADDIU: begin
            cuif.ALUOp = ALU_ADD;
            cuif.ALUSrc = 1;
            cuif.RegWrite = 1;
        end

        SLTI: begin
            cuif.ALUOp = ALU_SLT;
            cuif.ALUSrc = 1;
            cuif.RegWrite = 1;
        end

        SLTIU: begin
            cuif.ALUOp = ALU_SLTU;
            cuif.ALUSrc = 1;
            cuif.RegWrite = 1;
        end

        ANDI: begin
            cuif.ALUOp = ALU_AND;
            cuif.ALUSrc = 1;
            cuif.RegWrite = 1;
            cuif.SignExtend = 0;
        end

        ORI: begin
            cuif.ALUOp = ALU_OR;
            cuif.ALUSrc = 1;
            cuif.RegWrite = 1;
            cuif.SignExtend = 0;
        end

        XORI: begin
            cuif.ALUOp = ALU_XOR;
            cuif.ALUSrc = 1;
            cuif.RegWrite = 1;
            cuif.SignExtend = 0;
        end

        LUI: begin
            cuif.ALUOp = ALU_ADD;
            cuif.ALUSrc = 1;
            cuif.RegWrite = 1;
            cuif.LUI = 1;
        end

        LW: begin
            cuif.ALUOp = ALU_ADD;
            cuif.MemRead = 1;
            cuif.MemToReg = 1;
            cuif.ALUSrc = 1;
            cuif.RegWrite = 1;
        end

        SW: begin
            cuif.ALUOp = ALU_ADD;
            cuif.MemWrite = 1;
            cuif.ALUSrc = 1;
        end

        LL: begin
            cuif.ALUOp = ALU_ADD;
            cuif.MemRead = 1;
            cuif.MemToReg = 1;
            cuif.ALUSrc = 1;
            cuif.RegWrite = 1;
            cuif.datomic = 1; //datomic needs to be high
        end

        SC: begin
            cuif.ALUOp = ALU_ADD;
            cuif.MemWrite = 1;
            cuif.ALUSrc = 1;
            cuif.RegWrite = 1;
            cuif.MemToReg = 1;
            cuif.datomic = 1; //datomic needs to be high
        end

        HALT: begin
            //request_halt = 1;
            cuif.Halt = 1;
        end
      //Other Signals that need to be handled
    endcase
end

/*
//Halt Latch
logic nextHalt;
assign nextHalt = cuif.Halt | request_halt;

always_ff @(posedge CLK, negedge nRST) begin : Halt_Latch
    if(nRST == 0) begin
        cuif.Halt <= 0;
    end
    else begin
        cuif.Halt <= nextHalt;
    end
end
*/

endmodule
