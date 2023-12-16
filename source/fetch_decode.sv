/*
fetch_decode.sv
9/18/23
Pranay Jaggi
437-03
Version 1.0
fetch_decode
*/
`include "cpu_types_pkg.vh"
`include "fetch_decode_if.vh"
//fetch_decode_if fdif();
module fetch_decode(
    input logic CLK, nRST,
    fetch_decode_if.fd fdif
    );

import cpu_types_pkg::*;
//logic nxt_ihit;
always_ff @(posedge CLK, negedge nRST) begin
    if(!nRST) begin
        fdif.decode_instr_out <= '0;
        fdif.pc4_out <= '0;
        fdif.pc_out <= '0;
        fdif.next_pc_out <= '0;
    end
    //if not stall do below
    else if(fdif.flush || (fdif.dhit && !fdif.stall)) begin //think about ihit
        fdif.decode_instr_out <= '0;
        fdif.pc4_out <= '0;
        fdif.pc_out <= '0;
        fdif.next_pc_out <= '0;
    end
    //remove this stall logic and implement above 
    else if(fdif.ihit && !fdif.flush && !fdif.stall) begin
        fdif.decode_instr_out <= fdif.fetch_instr_in;
        fdif.pc4_out <= fdif.pc4_in;
        fdif.pc_out <= fdif.pc_in;
        fdif.next_pc_out <= fdif.next_pc_in;
    end
end
//DO NOT DELETE THIS
    r_t instrout;
    assign instrout = r_t'(fdif.decode_instr_out);
/*always_comb begin
    nxt_ihit = decode.ihit;
    if(flush) begin
        nxt_ihit = 0;
    end
    else if(enable) begin
        nxt_ihit = fetch.ihit;
    end
end 

always_ff @(posedge CLK, negedge nRST) begin
    if(!nRST) begin
        decode.ihit <= 0;
    end
    else begin
        decode.ihit <= nxt.ihit;
    end
end*/
endmodule