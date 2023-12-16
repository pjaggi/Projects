`include "cpu_types_pkg.vh"
`include "alu_if.vh"
module alu(alu_if.alu aluif);
import cpu_types_pkg::*;
always_comb begin
    //need to initialize outputs to avoid latch
    aluif.outport = 0;
    aluif.neg = 0;
    aluif.over = 0;
    aluif.zero = 0;
    case(aluif.ALUOP)
        ALU_SLL: begin //SLL
            aluif.outport = aluif.portb << aluif.porta[4:0];
        end
        ALU_SRL: begin //SRL
            aluif.outport = aluif.portb >> aluif.porta[4:0];
        end
        ALU_ADD: begin //ADD - need to add more
            aluif.outport = $signed(aluif.porta) + $signed(aluif.portb);
            aluif.over = (~aluif.outport[31] & aluif.porta[31] & aluif.portb[31]) | (aluif.outport[31] & (~aluif.porta[31]) & (~aluif.portb[31]));
            //aluif.over = (aluif.porta[31] ^ aluif.portb[31]) & (aluif.outport[31] ^ aluif.porta[31]);
        end
        ALU_SUB: begin //SUB - need to add more
            aluif.outport = $signed(aluif.porta) - $signed(aluif.portb);
            aluif.over = (~aluif.outport[31] & aluif.porta[31] & ~aluif.portb[31]) | (aluif.outport[31] & ~aluif.porta[31] & aluif.portb[31]);
            //aluif.over = (aluif.porta[31] ^ aluif.portb[31]) & (aluif.outport[31] ^ aluif.porta[31]);
        end
        ALU_AND: begin //AND
            aluif.outport = aluif.porta & aluif.portb;
        end
        ALU_OR: begin //OR
            aluif.outport = aluif.porta | aluif.portb;
        end
        ALU_XOR: begin //XOR
            aluif.outport = aluif.porta ^ aluif.portb;
        end
        ALU_NOR: begin //NOR
            aluif.outport = ~(aluif.porta | aluif.portb);
        end
        ALU_SLT: begin //SLT
            /*if(($signed(aluif.porta) < $signed(aluif.portb)) & aluif.porta == 0 || ($signed(aluif.portb) < $signed(aluif.porta)) & aluif.portb == 0) begin
                aluif.zero = 0;
            end*/
            aluif.outport = ($signed(aluif.porta) < $signed(aluif.portb)) ? 1 : 0;
        end
        ALU_SLTU: begin //SLTU
        /*if((aluif.porta < aluif.portb) & aluif.porta == 0 || (aluif.portb < aluif.porta) & aluif.portb == 0) begin
                aluif.zero = 0;
            end*/
            aluif.outport = (aluif.porta < aluif.portb) ? 1 : 0;
        end
    endcase
    if(aluif.outport == 0) begin //zero flag case
        aluif.zero = 1;
    end
    if(aluif.outport[31] == 1) begin //negative flag case, 1 in msb
        aluif.neg = 1;
    end
end




endmodule