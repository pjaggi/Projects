/*
sign_extend.sv
9/17/23
Michael Fuchs
437-03
Version 1.0
abstracted sign extend calculation for datapath
*/
//sign_extend_if se();
`include "sign_extend_if.vh"
module sign_extend (sign_extend_if.se se);

    logic [31:0] InstrExtended;
    always_comb begin : Extender
        InstrExtended = $unsigned(se.Instruction[15:0]);
        if(se.SignExtend == 1) begin
            InstrExtended = $signed(se.Instruction[15:0]);
        end
        if(se.LUI == 1) begin
            InstrExtended = InstrExtended << 16;
        end
    end

    assign se.InstrE = InstrExtended;

endmodule