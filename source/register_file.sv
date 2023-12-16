/*
register_file.sv
8/22/23
Michael Fuchs
437-03
Version 1.6
Register
*/

`include "register_file_if.vh"

module register_file
(
    //generic
    input logic CLK,
    input logic nRST,
    register_file_if.rf rfif
);

//Register Logic
logic [31:0] [31:0] REGXX;
logic [31:0] [31:0] next_REGXX;

//ff reset case
always_ff @(negedge CLK, negedge nRST) begin : Register
    if(nRST == 0) begin
        REGXX <= 0;
    end else begin
        REGXX <= next_REGXX;
    end
end

//write logic
always_comb begin : Decoder_write
    //Write Logic
    next_REGXX = REGXX;
    if(rfif.WEN) begin
        //Implicit Decoder Logic
        next_REGXX[rfif.wsel] = rfif.wdat;
    end
    next_REGXX[0] = 0;
end

//RSEL1 Mux
assign rfif.rdat1 = REGXX[rfif.rsel1];

//RSEL2 Mux
assign rfif.rdat2 = REGXX[rfif.rsel2];


endmodule