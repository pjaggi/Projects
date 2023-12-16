/*
register_file_abstract.sv
9/17/23
Michael Fuchs
437-03
Version 1.1
abstracted register_file for datapath
*/
`include "register_file_abstract_if.vh"
module register_file_abstract (
    input logic CLK,
    input logic nRST,
    register_file_abstract_if.rf rf_abs
);
    //register file call
    register_file_if rfif();

    assign rfif.WEN = rf_abs.RegWrite;//& !(rf_abs.dhit | rf_abs.ihit);
    assign rfif.rsel1 = rf_abs.Instruction[25:21];
    assign rfif.rsel2 = rf_abs.Instruction[20:16];
    
    always_comb begin : wsel_mux
        rfif.wsel = rf_abs.lastInstruction[20:16];
        if(rf_abs.RegDst == 1) begin
            rfif.wsel = rf_abs.lastInstruction[15:11];
        end 
        else if(rf_abs.JAL) begin
            rfif.wsel = 31;
        end
    end

    always_comb begin : wdat_mux
        rfif.wdat = rf_abs.ALUResult;
        if(rf_abs.JAL == 1) begin
            rfif.wdat = rf_abs.PC4;
        end
        else if(rf_abs.MemToReg == 1) begin
            rfif.wdat = rf_abs.dload;
        end
    end

    //assign outputs
    assign rf_abs.rdat1 = rfif.rdat1;
    assign rf_abs.rdat2 = rfif.rdat2;

    //register call
    register_file regfile(CLK, nRST, rfif);
endmodule
