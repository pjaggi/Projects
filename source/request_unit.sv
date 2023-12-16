`include "cpu_types_pkg.vh"
`include "request_unit_if.vh"

module request_unit (
    input logic CLK, nRST,
    request_unit_if.ru ruif
);
// type import
import cpu_types_pkg::*;

always_ff @(posedge CLK, negedge nRST) begin
    if(1'b0 == nRST) begin
        ruif.dmemread <= '0;
        ruif.dmemwrite <= '0;
    end
    else if(ruif.ihit) begin //does it matter if i check for ihit before dhit??
        ruif.dmemread <= ruif.memread;
        ruif.dmemwrite <= ruif.memwrite;
    end
    else if(ruif.dhit) begin
        ruif.dmemread <= '0;
        ruif.dmemwrite <= '0;
    end
    /*else begin //what is the default case?? - will there ever be a case neither ihit or dhit
        ruif.dmemread <= '0;
        ruif.dmemwrite <= '0;
    end*/
end
endmodule