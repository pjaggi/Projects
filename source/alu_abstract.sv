/*
alu_abstract.sv
9/17/23
Michael Fuchs
437-03
Version 1.0
abstracted alu for datapath
*/

`include "alu_abstract_if.vh"

module alu_abstract(alu_abs_if.aluabs aluabs);
    //declare aluif
    //alu_if aluif();
    alu_file_if aluif();
   //set aluop
    assign aluif.ALUOP = aluabs.ALUOP;

    //assign porta
    assign aluif.porta = aluabs.rdat1;

    //mux for portb
    always_comb begin : aluMux
        aluif.portb = aluabs.rdat2;
        if(aluabs.ALUSrc == 1) begin
            aluif.portb = aluabs.InstrE;
        end
    end

    //assign outputs
    assign aluabs.outport = aluif.outport;
    assign aluabs.zero = aluif.zero;
    assign aluabs.over = aluif.over;
    assign aluabs.neg = aluif.neg;

//alu call
//alu alu(aluif); 
alu_file alu_file(aluif);
endmodule
