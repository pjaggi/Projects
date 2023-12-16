`include "cpu_types_pkg.vh"
`include "caches_if.vh"
`include "datapath_cache_if.vh"

module old_dcache(
    input logic CLK, nRST,
    datapath_cache_if.dcache dcif,
    caches_if.dcache cif
);

import cpu_types_pkg::*;

typedef enum logic [2:0] {IDLE, WRITEBACK1, WRITEBACK2, LOAD1, LOAD2, FLUSH, COUNT, FLUSHEND} state_type;
state_type state, nextState;

parameter dColumn = 1 << DIDX_W; //8 - index each row
parameter dRow = DWAY_ASS; //2 - set 1 or 2
dcache_frame [dColumn - 1 : 0][dRow - 1 : 0] dFrame;
dcache_frame [dColumn - 1 : 0][dRow - 1 : 0] next_dFrame;
dcachef_t dFormat;
dcachef_t daddr;
logic [31:0] count_hits;
logic [31:0] next_count_hits;
logic invalid_signal;
logic nxt_invalid_signal;
logic [4:0] counter;
logic [4:0] next_counter;
logic [7:0] lru;
logic [7:0] next_lru;

always_ff @ (posedge CLK, negedge nRST) begin
    if(!nRST) begin
        state <= IDLE;
        invalid_signal <= 0;
        counter <= 0;
        count_hits <= 0;
        dFrame <= 0;
        lru <= 0;
    end
    else begin
        state <= nextState;
        invalid_signal <= nxt_invalid_signal;
        counter <= next_counter;
        count_hits <= next_count_hits;
        dFrame <= next_dFrame;
        lru <= next_lru;
    end
end

always_comb begin
    nextState = state;
    case (state)
        IDLE: begin
            nextState = IDLE;
            if(dcif.halt) begin
                nextState = FLUSH;
            end  
            //else if((dcif.dmemWEN || dcif.dmemREN) && (dFormat.tag != dFrame[dFormat.idx][0].tag && dFrame[dFormat.idx][0].valid) &&
            //(dFormat.tag != dFrame[dFormat.idx][1].tag && dFrame[dFormat.idx][1].valid)) begin //is tag != stored tag, && between the two blocks
            else if (/*(dcif.dmemWEN || dcif.dmemREN) &&*/
            ((dFormat.tag != dFrame[dFormat.idx][0].tag && dFormat.tag != dFrame[dFormat.idx][1].tag) &&
            (dFrame[dFormat.idx][0].dirty || dFrame[dFormat.idx][1].dirty))) begin
                nextState = WRITEBACK1;
            end
            else if(/*(dcif.dmemWEN || dcif.dmemREN) &&*/
            ((dFormat.tag != dFrame[dFormat.idx][0].tag && dFormat.tag != dFrame[dFormat.idx][1].tag) &&
            (!dFrame[dFormat.idx][0].dirty || !dFrame[dFormat.idx][1].dirty))) begin//((!dFrame[dFormat.idx][0].dirty) || (!dFrame[dFormat.idx][1].dirty))) begin
                nextState = LOAD1;
            end
        end
        WRITEBACK1: begin
            nextState = WRITEBACK1;
            if(~cif.dwait) begin
                nextState =  WRITEBACK2;
            end
        end
        WRITEBACK2: begin
            nextState =  WRITEBACK2;
            if(~cif.dwait) begin
                nextState =  LOAD1;
            end
        end
        LOAD1: begin
            nextState =  LOAD1;
            if(~cif.dwait) begin
                nextState = LOAD2;
            end
        end
        LOAD2: begin
            nextState =  LOAD2;
            if(~cif.dwait) begin
                nextState = IDLE;
            end
        end
        FLUSH: begin //can it ever go back to dirty
            nextState = FLUSH;
            if(counter == 5'b11111 && /*!cif.dwait &&*/ dFrame[counter[3:1]][counter[4]].dirty) begin //means it is at the end
                nextState = COUNT; //does it go back to idle
            end
            else if(counter == 5'b11111 && !dFrame[counter[3:1]][counter[4]].dirty) begin //means it is at the end
                nextState = COUNT;
            end
        end
        COUNT: begin
            nextState = COUNT;
            if(~cif.dwait) begin //do i need cif.dwait here
                nextState = FLUSHEND;
            end
        end
    endcase
end

assign dFormat = dcif.dmemaddr;
assign cif.daddr = daddr;

always_comb begin: OutputLogic
    cif.dWEN = 0;
    cif.dREN = 0;
    next_count_hits = count_hits; //check this
    daddr = 0;
    nxt_invalid_signal = invalid_signal; //check this
    next_counter = counter;
    next_lru = lru; //check this
    next_dFrame = dFrame;
    dcif.dmemload = 0;
    dcif.flushed = 0;
    cif.dstore = 0;
    dcif.dhit = 0;
    case(state)
        IDLE: begin
            nxt_invalid_signal = dFrame[dFormat.idx][0].valid; //All good to be here
            if(dcif.halt) begin
                next_count_hits = count_hits;
            end
            if(dcif.dmemREN) begin
                    if((dFormat.tag == dFrame[dFormat.idx][0].tag && dFrame[dFormat.idx][0].valid)) begin
                        //dcif.dmemload = dFrame[dFormat.idx][0].data[0];
                        next_lru[dFormat.idx] = 1;
                        next_count_hits = count_hits + 1;
                        dcif.dhit = 1;
                        if(dFormat.blkoff == 0) begin
                            dcif.dmemload = dFrame[dFormat.idx][0].data[0];
                        end
                        else begin
                            dcif.dmemload = dFrame[dFormat.idx][0].data[1];
                        end
                        //dcif.dmemload = dFormat.blkoff ? dFrame[dFormat.idx][0].data[1] : dFrame[dFormat.idx][0].data[0];
                    end
                    else if((dFormat.tag == dFrame[dFormat.idx][1].tag && dFrame[dFormat.idx][1].valid)) begin
                        //dcif.dmemload = dFrame[dFormat.idx][1].data[0];
                        next_lru[dFormat.idx] = 0;
                        next_count_hits = count_hits + 1;
                        dcif.dhit = 1;
                        if(dFormat.blkoff == 0) begin
                            dcif.dmemload = dFrame[dFormat.idx][1].data[0];
                        end
                        else begin
                            dcif.dmemload = dFrame[dFormat.idx][1].data[1];
                        end
                        //dcif.dmemload = dFormat.blkoff ? dFrame[dFormat.idx][1].data[1] : dFrame[dFormat.idx][1].data[0];
                    end
            end
            else if(dcif.dmemWEN) begin 
                    if(dFormat.tag == dFrame[dFormat.idx][0].tag) begin
                        //dcif.dmemload = dFrame[dFormat.idx][0].data[1];
                        next_lru[dFormat.idx] = 1;
                        next_count_hits = count_hits + 1;
                        dcif.dhit = 1;
                        next_dFrame[dFormat.idx][0].dirty = 1;
                        if(dFormat.blkoff == 0) begin
                            next_dFrame[dFormat.idx][0].data[0] = dcif.dmemstore;
                        end
                        else begin
                            next_dFrame[dFormat.idx][0].data[1] = dcif.dmemstore;
                        end
                    end
                    else if(dFormat.tag == dFrame[dFormat.idx][1].tag) begin
                        //dcif.dmemload = dFrame[dFormat.idx][1].data[1];
                        next_lru[dFormat.idx] = 0;
                        next_count_hits = count_hits + 1;
                        dcif.dhit = 1;
                        next_dFrame[dFormat.idx][1].dirty = 1;
                        if(dFormat.blkoff == 0) begin
                            next_dFrame[dFormat.idx][1].data[0] = dcif.dmemstore;
                        end
                        else begin
                            next_dFrame[dFormat.idx][1].data[1] = dcif.dmemstore;
                        end
                    end
            end
        end
        WRITEBACK1: begin
            cif.dWEN = 1;
            if(lru[dFormat.idx] == 0) begin
                //if((dFrame[dFormat.idx][0].dirty && dFrame[dFormat.idx][0].valid)) begin //CHANGED FROM OR TO AND
                    daddr.blkoff = 0;
                    daddr.bytoff = 0;
                    daddr.tag = dFrame[dFormat.idx][0].tag;
                    daddr.idx = dFormat.idx;
                    cif.dstore = dFrame[dFormat.idx][0].data[0];
                //end
            end
            else begin//if(lru[dFormat.idx] == 1) begin
                //if((dFrame[dFormat.idx][1].dirty && dFrame[dFormat.idx][1].valid)) begin //CHANGED FROM OR TO AND
                    daddr.blkoff = 0;
                    daddr.bytoff = 0;
                    daddr.tag = dFrame[dFormat.idx][1].tag;
                    daddr.idx = dFormat.idx;
                    cif.dstore = dFrame[dFormat.idx][1].data[0];
                //end
            end
        end
        WRITEBACK2: begin
            cif.dWEN = 1;
            if(lru[dFormat.idx] == 0) begin
                nxt_invalid_signal = 0;
                //if((dFrame[dFormat.idx][0].dirty && dFrame[dFormat.idx][0].valid)) begin //CHANGED FROM OR TO AND
                    daddr.blkoff = 1;
                    daddr.bytoff = 0;
                    daddr.tag = dFrame[dFormat.idx][0].tag;
                    daddr.idx = dFormat.idx;
                    cif.dstore = dFrame[dFormat.idx][0].data[1];
                //end
            end
            else begin //if(lru[dFormat.idx] == 1) begin
                nxt_invalid_signal = 1;
                //if((dFrame[dFormat.idx][1].dirty && dFrame[dFormat.idx][1].valid)) begin //CHANGED FROM OR TO AND
                    daddr.blkoff = 1;
                    daddr.bytoff = 0;
                    daddr.tag = dFrame[dFormat.idx][1].tag;
                    daddr.idx = dFormat.idx;
                    cif.dstore = dFrame[dFormat.idx][1].data[1];
                //end
            end
        end
        LOAD1: begin
            cif.dREN = 1;
            daddr.blkoff = 0;
            daddr.bytoff = 0;
            daddr.tag = dFormat.tag;
            daddr.idx = dFormat.idx;
            if(invalid_signal) begin //or LRU?
                next_dFrame[dFormat.idx][0].data[0] = cif.dload;
            end
            else begin
                next_dFrame[dFormat.idx][1].data[0] = cif.dload;
            end
        end
        LOAD2: begin
            cif.dREN = 1;
            daddr.blkoff = 1;
            daddr.bytoff = 0;
            daddr.tag = dFormat.tag;
            daddr.idx = dFormat.idx;
            if(invalid_signal) begin //or LRU?
                next_dFrame[dFormat.idx][0].data[1] = cif.dload;
                next_dFrame[dFormat.idx][0].tag = dFormat.tag;
                next_dFrame[dFormat.idx][0].dirty = 0;
                next_dFrame[dFormat.idx][0].valid = 1;
            end
            else begin
                next_dFrame[dFormat.idx][1].data[1] = cif.dload;
                next_dFrame[dFormat.idx][1].tag = dFormat.tag;
                next_dFrame[dFormat.idx][1].dirty = 0;
                next_dFrame[dFormat.idx][1].valid = 1;
            end
        end
        FLUSH: begin
            //push everything dirty to memory
            cif.dWEN = 1;
            next_counter = counter + 1;
            if(dFrame[counter[3:1]][counter[4]].dirty) begin
                cif.dstore = dFrame[counter[3:1]][counter[4]].data[counter[0]];
                daddr.blkoff = counter[0];
                daddr.bytoff = 0;
                daddr.tag = dFrame[counter[3:1]][counter[4]].tag; //datapath side - CHECK THIS
                daddr.idx = counter[3:1];
                if(!cif.dwait) begin
                    next_counter = counter + 1;
                end
                else begin
                    next_counter = counter;
                end
            end
        end
        COUNT: begin
            daddr = 32'h00003100;
            cif.dstore = count_hits;
            cif.dWEN = 1;
            dcif.flushed = 1;
        end
        FLUSHEND: begin
            //dcif.flushed = 1; //flush everything
        end
    endcase
end
endmodule