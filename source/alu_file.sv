/*
alu_file.sv
8/24/23
Michael Fuchs
437-03
Version 1.0
ALU
*/

`include "alu_file_if.vh"
import cpu_types_pkg::*;

module alu_file
(
    //generic
    alu_file_if.alu aluif
);

always_comb begin : OPCODE_Controller
    aluif.over = 0;
    aluif.zero = 0;
    aluif.neg = 0;

    case (aluif.ALUOP)
        //SLL
        ALU_SLL: begin
            //Set flag conditions
            if(aluif.portb == 0) aluif.zero = 1;
            if((aluif.portb << aluif.porta) < 0) aluif.neg = 1;

            //Set output conditions
            aluif.outport = (aluif.portb << aluif.porta);
        end
        
        //SRL
        ALU_SRL: begin
            //Set flag conditions
            if(aluif.portb == 0) aluif.zero = 1;
            if((aluif.portb >> aluif.porta) < 0) aluif.neg = 1;

            //Set output conditions
            aluif.outport = (aluif.portb >> aluif.porta);
        end

        //AND
        ALU_AND: begin
            //Set flag conditions

            //Set output conditions
            aluif.outport = (aluif.porta & aluif.portb);
        end

        //OR
        ALU_OR: begin
            //Set flag conditions

            //Set output conditions
            aluif.outport = (aluif.porta | aluif.portb);
        end

        //XOR
        ALU_XOR: begin
            //Set flag conditions

            //Set output conditions
            aluif.outport = (aluif.porta ^ aluif.portb);
        end

        //NOR
        ALU_NOR: begin
            //Set flag conditions

            //Set output conditions
            aluif.outport = ~(aluif.porta | aluif.portb);
        end

        //ADD
        ALU_ADD: begin
            //Set flag conditions
            if((aluif.porta + aluif.portb) < 0) aluif.neg = 1;
            if((aluif.porta + aluif.portb) == 0) aluif.zero = 1;
            if(((aluif.porta + aluif.portb) == 0) && ((aluif.porta > 0) && (aluif.portb > 0))) aluif.over = 1; 
            //Set output conditions
            aluif.outport = aluif.porta + aluif.portb;
        end

        //SUB
        ALU_SUB: begin
            //Set flag conditions
                //check if result is negative
            if(((aluif.porta - aluif.portb) > 0) && (aluif.porta <= aluif.portb)) aluif.neg = 1;
                //check if result is zero
            if((aluif.porta - aluif.portb) == 0) aluif.zero = 1;
            //Set output conditions
            aluif.outport = aluif.porta - aluif.portb;
        end

        //SLT
        ALU_SLT: begin
            //Set flag conditions
                //check that lowest number is zero
            if((aluif.porta <= aluif.portb) && (aluif.porta == 0) && (aluif.portb[31] == 0)) begin aluif.zero = 1;end
            if((aluif.portb <= aluif.porta) && (aluif.portb == 0) && (aluif.porta[31] == 0)) begin aluif.zero = 1;end
                //check if lowest number is negative
            if((aluif.porta > aluif.portb) && (aluif.porta[31] == 1)) begin aluif.neg = 1;end
            if((aluif.portb > aluif.porta) && (aluif.portb[31] == 1)) begin aluif.neg = 1;end

            //Set output conditions
            aluif.outport = 0;
            if((aluif.porta < aluif.portb) && (aluif.portb[31] == 0)) aluif.outport = 1;
            if((aluif.porta > aluif.portb) && (aluif.porta[31] == 1)) aluif.outport = 1;
        end

        //SLTU
        ALU_SLTU: begin
            //Set flag conditions
            if((aluif.porta <= aluif.portb) && aluif.porta == 0) begin aluif.zero = 1; end
            if((aluif.portb <= aluif.porta) && aluif.portb == 0) begin aluif.zero = 1; end
            //Set output conditions
                
                //both negative
            if((aluif.porta < 0) && (aluif.portb < 0)) begin
                aluif.outport = aluif.portb;
                if(~aluif.porta < ~aluif.portb) aluif.outport = aluif.porta;
                
                //b is negative
            end else if((aluif.porta > 0) && (aluif.portb < 0)) begin
                aluif.outport = aluif.portb;
                if(aluif.porta < ~aluif.portb) aluif.outport = aluif.porta;
                
                //a is negative
            end else if((aluif.porta < 0) && (aluif.portb > 0)) begin
                aluif.outport = aluif.portb;
                if(~aluif.porta < aluif.portb) aluif.outport = aluif.porta;
                
                //both positive
            end else begin
                aluif.outport = 0;
                if(aluif.porta < aluif.portb) aluif.outport = 1;
            end
        end

    endcase
end

endmodule