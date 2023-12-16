`include "cpu_types_pkg.vh"
`include "caches_if.vh"
`include "datapath_cache_if.vh"

module Icache (
  input logic CLK, nRST,
  datapath_cache_if.icache dcif,
  caches_if.icache cif
);

import cpu_types_pkg::*;
logic miss;
//use icahcef_t from cpu_types_pkg

typedef enum logic {HIT, MISS} state_type;
state_type state, nextState;

parameter icacheSize = 1 << IIDX_W;
  icache_frame [icacheSize - 1 : 0] iFrame, nextiFrame;
icachef_t iFormat;

always_comb begin : nextStateLogic
    iFormat = dcif.imemaddr;
    nextState = state;
    case(state)
        HIT: begin
            if((iFormat.tag != iFrame[iFormat.idx].tag) || !iFrame[iFormat.idx].valid) begin
                nextState = MISS;
            end    
        end
        MISS: begin
            if(!cif.iwait) begin
                nextState = HIT;
            end
        end
    endcase
end

always_ff @(posedge CLK, negedge nRST) begin : nextStateFlops
    if(!nRST) begin
        state <= HIT;
        iFrame <= 0;
    end else begin
        state <= nextState;
        iFrame <= nextiFrame;
    end
end

always_comb begin : outputLogic
    nextiFrame = iFrame;
    dcif.imemload = 0;
    case(state)
        HIT: begin
            miss = 0;
            cif.iREN = 0;
            cif.iaddr = 0;
            dcif.ihit = 0;
            if((iFormat.tag == iFrame[iFormat.idx].tag) && iFrame[iFormat.idx].valid && dcif.imemREN) begin //is imemREN necessary
                dcif.ihit = 1;
                dcif.imemload = iFrame[iFormat.idx].data;
            end
        end
        MISS: begin
            miss = 1;
            dcif.ihit = 0;
            cif.iREN = dcif.imemREN;
            cif.iaddr = dcif.imemaddr;
            if(!cif.iwait) begin
                nextiFrame[iFormat.idx].data = cif.iload;
                nextiFrame[iFormat.idx].valid = 1;
                nextiFrame[iFormat.idx].tag = iFormat.tag;
            end
        end
    endcase
end


endmodule
