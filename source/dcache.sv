`include "cpu_types_pkg.vh"
`include "caches_if.vh"
`include "datapath_cache_if.vh"
`include "cache_control_if.vh"

module dcache(
    input logic CLK, nRST,
    datapath_cache_if.dcache dcif,
    caches_if.dcache cif
);

import cpu_types_pkg::*;

typedef enum logic [4:0] {IDLE, WRITEBACK1, WRITEBACK2, LOAD1, LOAD2, FLUSH, FLUSHEND, READMSI, SETSNOOP1, SETSNOOP2, READXCONFIRM} state_type;
state_type state, nextState, lastState, nextLastState;

//typedef enum logic [1:0] {M, S, I} state_type;
//state_type transition, nextTransition;

parameter dColumn = 1 << DIDX_W; //8 - index each row
parameter dRow = DWAY_ASS; //2 - set 1 or 2
dcache_frame [dColumn - 1 : 0][dRow - 1 : 0] dFrame;
dcache_frame [dColumn - 1 : 0][dRow - 1 : 0] next_dFrame;
dcachef_t dFormat;
dcachef_t daddr;
dcachef_t dSnoop;
logic [31:0] count_hits;
logic [31:0] next_count_hits;
logic [5:0] counter;
logic [5:0] next_counter;
logic [7:0] lru;
logic [7:0] next_lru;
//logic next_cctrans;
logic miss, miss2;
logic valid, nextvalid;
logic [31:0] link, nextlink;

always_ff @ (posedge CLK, negedge nRST) begin
    if(!nRST) begin
        state <= IDLE;
        //transition <= I;
        lastState <= IDLE;
        counter <= 0;
        count_hits <= 0;
        dFrame <= 0;
        lru <= 0;
        valid <= 0;
        link <= 0;
    end
    else begin
        state <= nextState;
        //transition <= nextTransition;
        lastState <= nextLastState;
        counter <= next_counter;
        count_hits <= next_count_hits;
        dFrame <= next_dFrame;
        lru <= next_lru;
        valid <= nextvalid;
        link <= nextlink;
    end
end

always_comb begin
    nextState = state;
    nextLastState = lastState;
    case (state) //do i need to base on lastState
        IDLE: begin
            nextState = IDLE;
            if(dcif.halt) begin
                nextState = FLUSH;
            end
            else if(cif.ccwait && ((dSnoop.tag == dFrame[dSnoop.idx][0].tag && dFrame[dSnoop.idx][0].valid == 1) || (dSnoop.tag == dFrame[dSnoop.idx][1].tag && dFrame[dSnoop.idx][1].valid == 1))) begin //&& !dcif.dmemWEN
                nextState = READMSI;
                nextLastState = IDLE;
            end
            else if(miss) begin
                
                //if(dFormat.tag == dFrame[dFormat.idx][0].tag && dFrame[dFormat.idx][0].valid) nextState = READXCONFIRM;
                //else if(dFormat.tag == dFrame[dFormat.idx][1].tag && dFrame[dFormat.idx][1].valid) nextState = READXCONFIRM;
                //else 
                //begin
                    if(dFrame[dFormat.idx][lru[dFormat.idx]].dirty) begin
                        nextState = WRITEBACK1;
                    end
                    else begin
                        nextState = LOAD1;
                    end
                //end
            end
        end
        /*READXCONFIRM: begin
            nextState = IDLE;
        end*/
        WRITEBACK1: begin
            nextState = WRITEBACK1;
            /*if(cif.ccwait) begin
                nextState = READMSI;
                nextLastState = WRITEBACK1;
            end*/
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
            //should i transition to READMSI here?
            /*if(cif.ccwait) begin
                nextState = READMSI;
                nextLastState = LOAD1;
            end*/
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
            if(cif.ccwait && ((dSnoop.tag == dFrame[dSnoop.idx][0].tag && dFrame[dSnoop.idx][0].valid == 1) || (dSnoop.tag == dFrame[dSnoop.idx][1].tag && dFrame[dSnoop.idx][1].valid == 1))) begin
                nextState = READMSI;
                nextLastState = FLUSH;
            end
            else if(counter == 6'b011111 && !cif.dwait && dFrame[counter[3:1]][counter[4]].dirty) begin //means it is at the end
                nextState = FLUSHEND; //does it go back to idle
            end
            else if(counter == 6'b011111 && !dFrame[counter[3:1]][counter[4]].dirty) begin //means it is at the end
                nextState = FLUSHEND;
            end
        end
        FLUSHEND: begin
            nextState = FLUSHEND; //just in case to make sure we stay in flushend
        end
        READMSI: begin
            nextState = SETSNOOP1;
            /*
            if(!cif.ccwait) begin
                nextState = SETSNOOP1;
            end
            */
        end
        SETSNOOP1: begin
            if(!cif.dwait) begin
                nextState = SETSNOOP2;
            end
        end
        SETSNOOP2: begin
            if(!cif.dwait) begin
                nextState = lastState;
            end
        end
    endcase
end

assign dFormat = dcif.dmemaddr; //can access dmemaddr certain bits
assign dSnoop = cif.ccsnoopaddr;
assign cif.daddr = daddr; //set the daddr to cif.daddr, same as setting it inside output logic block
//assign cif.ccwrite = dcif.dmemWEN;//CORRECT

always_comb begin: OutputLogic
    cif.dWEN = 0;
    cif.dREN = 0;
    next_count_hits = count_hits;
    daddr = 0;
    next_counter = counter;
    next_lru = lru;
    next_dFrame = dFrame;
    dcif.dmemload = 0;
    dcif.flushed = 0;
    cif.dstore = 0;
    dcif.dhit = 0;
    miss = 0;
    cif.cctrans = 0;
    cif.ccwrite = dcif.dmemWEN;
    //set LLSC initial
    nextvalid = valid;
    nextlink = link;
    case(state)
        IDLE: begin
            if((cif.ccsnoopaddr == link)) begin// && cif.ccinv) begin
                //next_dFrame[dFormat.idx][lru[dFormat.idx]].dirty = 1;
                nextvalid = 0;
                nextlink = 0;
                //cif.ccwrite = 1; //invalidation of other cache
                //next_dFrame[dFormat.idx][lru[dFormat.idx]].valid = 0;
                //cif.cctrans = 0;
            end
            if(dcif.halt) begin //don't want to update count hits if there is halt
                next_count_hits = count_hits;
            end
            else if(dcif.dmemREN) begin //read and hit case
                    //LL
                    if(dcif.datomic) begin
                        nextlink = dcif.dmemaddr;
                        nextvalid = 1;
                    end
                    //LW
                    if((dFormat.tag == dFrame[dFormat.idx][0].tag && dFrame[dFormat.idx][0].valid)) begin
                        next_lru[dFormat.idx] = 1;
                        next_count_hits = count_hits + 1;
                        dcif.dhit = 1;
                        if(dFormat.blkoff == 0) begin
                            dcif.dmemload = dFrame[dFormat.idx][0].data[0];
                        end
                        else begin
                            dcif.dmemload = dFrame[dFormat.idx][0].data[1];
                        end
                    end
                    else if((dFormat.tag == dFrame[dFormat.idx][1].tag && dFrame[dFormat.idx][1].valid)) begin
                        next_lru[dFormat.idx] = 0;
                        next_count_hits = count_hits + 1;
                        dcif.dhit = 1;
                        if(dFormat.blkoff == 0) begin
                            dcif.dmemload = dFrame[dFormat.idx][1].data[0];
                        end
                        else begin
                            dcif.dmemload = dFrame[dFormat.idx][1].data[1];
                        end
                    end
                    else begin //don't want to increment if there is a miss
                        //next_count_hits = count_hits - 1;
                        miss = 1; //use this in next state logic to determine miss, easiest way
                    end
            end
            else if(dcif.dmemWEN) begin //write and hit case
                    //SC
                    if(dcif.datomic) begin
                        dcif.dmemload = (valid && (dcif.dmemaddr == link)); //RT if the test is successful
                    //if link register is not valid, then we dont want to set miss, avoid going to miss state. Stay in IDLE!!!!!!
                    //if SC is successful, then we can stay in IDLE and set dcif.dhit, dcif.dmemload
                    //processor needs to know when store conditional is done, setting dhit properly

                    //link and valid then do store and rt = 1
                    //failed then do not do store rt = 0 - it doesnt do store right
                    //link register must be invalidated on matching coherent store
                    //snoop address must be checked against the link register for stores and register must be invalidated on a match                    
                        if(valid && (dcif.dmemaddr == link)) begin
                            if(dFormat.tag == dFrame[dFormat.idx][0].tag) begin
                                if(dFrame[dFormat.idx][0].valid && !dFrame[dFormat.idx][0].dirty) begin
                                    next_lru[dFormat.idx] = 0;
                                    next_dFrame[dFormat.idx][0].dirty = 1;
                                    miss = 1;
                                end
                                else begin
                                    cif.ccwrite = 1;
                                    next_lru[dFormat.idx] = 1;
                                    next_count_hits = count_hits + 1;
                                    dcif.dhit = 1;
                                    nextlink = 0; //added for SC success, reset
                                    nextvalid = 0; //added for SC success, reset
                                    next_dFrame[dFormat.idx][0].dirty = 1; //would dirty depend on if snoop is executed first
                                    if(dFormat.blkoff == 0) begin
                                        next_dFrame[dFormat.idx][0].data[0] = dcif.dmemstore;
                                    end
                                    else begin
                                        next_dFrame[dFormat.idx][0].data[1] = dcif.dmemstore;
                                    end
                                end
                            end
                            else if(dFormat.tag == dFrame[dFormat.idx][1].tag) begin
                                if(dFrame[dFormat.idx][1].valid && !dFrame[dFormat.idx][1].dirty) begin
                                    next_lru[dFormat.idx] = 1;
                                    next_dFrame[dFormat.idx][1].dirty = 1;
                                    miss = 1;     
                                end
                                else begin
                                    cif.ccwrite = 1;
                                    next_lru[dFormat.idx] = 0;
                                    next_count_hits = count_hits + 1;
                                    dcif.dhit = 1;
                                    nextlink = 0; //added for SC success, reset
                                    nextvalid = 0; //added for SC success, reset
                                    next_dFrame[dFormat.idx][1].dirty = 1;
                                    if(dFormat.blkoff == 0) begin
                                        next_dFrame[dFormat.idx][1].data[0] = dcif.dmemstore;
                                    end
                                    else begin
                                        next_dFrame[dFormat.idx][1].data[1] = dcif.dmemstore;
                                    end
                                end
                            end
                            else begin //miss again
                                //next_count_hits = count_hits - 1;
                                miss = 1;
                            end
                        end
                        else begin
                            dcif.dhit = 1; //set dhit if it fails anyways
                        end
                    end
                    //SW
                    else begin
                        if(dcif.dmemaddr == link) begin //what is the SW signal
                            //if snoopaddr equals link reg addr for store, then register must be invalidated
                            nextlink = 0; //reset link register, need for atomicity
                            nextvalid = 0; //reset link valid, need for atomicity
                        end
                        //if(cif.ccinv) begin
                            //next_dFrame[dFormat.idx][0].valid = 0;
                        //end
                        //still need to check tag and valid and dirty
                        //could do tag and then valid and not dirty which is a miss
                        //else hit
                        if(dFormat.tag == dFrame[dFormat.idx][0].tag) begin
                            if(dFrame[dFormat.idx][0].valid && !dFrame[dFormat.idx][0].dirty) begin                            
                                next_lru[dFormat.idx] = 0;
                                next_dFrame[dFormat.idx][0].dirty = 1;
                                miss = 1;
                            end
                            else begin
                                next_lru[dFormat.idx] = 1;
                                // next_count_hits = count_hits + 1;
                                dcif.dhit = 1;
                                next_dFrame[dFormat.idx][0].dirty = 1; //would dirty depend on if snoop is executed first
                                if(dFormat.blkoff == 0) begin
                                    next_dFrame[dFormat.idx][0].data[0] = dcif.dmemstore;
                                end
                                else begin
                                    next_dFrame[dFormat.idx][0].data[1] = dcif.dmemstore;
                                end
                            end
                        end
                        else if(dFormat.tag == dFrame[dFormat.idx][1].tag) begin
                            if(dFrame[dFormat.idx][1].valid && !dFrame[dFormat.idx][1].dirty) begin                 
                                next_lru[dFormat.idx] = 1;
                                next_dFrame[dFormat.idx][1].dirty = 1;
                                miss = 1;
                            end
                            else begin
                                next_lru[dFormat.idx] = 0;
                                // next_count_hits = count_hits + 1;
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
                        else begin //miss again
                            miss = 1;
                            if(dFormat.tag == dFrame[dFormat.idx][0].tag && dFrame[dFormat.idx][0].valid) begin
                                cif.ccwrite = 1;
                                next_lru[dFormat.idx] = 0;
                                next_dFrame[dFormat.idx][0].dirty = 1;
                            end
                            else if(dFormat.tag == dFrame[dFormat.idx][1].tag && dFrame[dFormat.idx][1].valid) begin
                                cif.ccwrite = 1;
                                next_lru[dFormat.idx] = 1;
                                next_dFrame[dFormat.idx][1].dirty = 1;
                            end
                        end
                        /*else if(dFormat.tag == dFrame[dFormat.idx][0].tag && dFrame[dFormat.idx][0].valid) begin
                            miss2 = 1;
                            cif.ccwrite = 1;
                            next_lru[dFormat.idx] = 0;
                            next_dFrame[dFormat.idx][0].dirty = 0;
                            next_dFrame[dFormat.idx][0].valid = 1;
                        end
                        else if(dFormat.tag == dFrame[dFormat.idx][1].tag && dFrame[dFormat.idx][1].valid) begin
                            miss2 = 1;
                            cif.ccwrite = 1;
                            next_lru[dFormat.idx] = 1;
                            next_dFrame[dFormat.idx][1].dirty = 0;
                            next_dFrame[dFormat.idx][1].valid = 1;
                        end
                        else begin
                            miss = 1;
                        end*/
                    end
            end
        end
        /*READXCONFIRM: begin
            if(dFormat.tag == dFrame[dFormat.idx][0].tag && dFrame[dFormat.idx][0].valid) begin
                next_lru[dFormat.idx] = 0;
                next_dFrame[dFormat.idx][0].dirty = 1;
            end
            else if(dFormat.tag == dFrame[dFormat.idx][1].tag && dFrame[dFormat.idx][1].valid) begin
                next_lru[dFormat.idx] = 1;
                next_dFrame[dFormat.idx][1].dirty = 1;
            end
        end*/
        WRITEBACK1: begin
            // if(lru[dFormat.idx] == 0) begin
            //     if((dFrame[dFormat.idx][0].dirty && dFrame[dFormat.idx][0].valid)) begin
            //         cif.dWEN = 1; //only WEN when it is actually writing
            //         daddr.blkoff = 0; //first block
            //         daddr.bytoff = 0;
            //         daddr.tag = dFrame[dFormat.idx][0].tag;
            //         daddr.idx = dFormat.idx;
            //         cif.dstore = dFrame[dFormat.idx][0].data[0];
            //     end
            // end
            // else if(lru[dFormat.idx] == 1) begin
            //     if((dFrame[dFormat.idx][1].dirty && dFrame[dFormat.idx][1].valid)) begin 
            //         cif.dWEN = 1; //only WEN when it is actually writing
            //         daddr.blkoff = 0; //first block
            //         daddr.bytoff = 0;
            //         daddr.tag = dFrame[dFormat.idx][1].tag;
            //         daddr.idx = dFormat.idx;
            //         cif.dstore = dFrame[dFormat.idx][1].data[0];
            //     end
            // end
            if (dFormat.tag == dFrame[dFormat.idx][0].tag && dFrame[dFormat.idx][0].valid) begin
                if(dFrame[dFormat.idx][0].dirty) begin
                        cif.dWEN = 1;
                        daddr.blkoff = 0;
                        daddr.bytoff = 0;
                        daddr.tag = dFrame[dFormat.idx][0].tag;
                        daddr.idx = dFormat.idx;
                        cif.dstore = dFrame[dFormat.idx][0].data[0];
                end
            end
            else if (dFormat.tag == dFrame[dFormat.idx][1].tag && dFrame[dFormat.idx][1].valid) begin
                if(dFrame[dFormat.idx][1].dirty) begin
                        cif.dWEN = 1;
                        daddr.blkoff = 0;
                        daddr.bytoff = 0;
                        daddr.tag = dFrame[dFormat.idx][1].tag;
                        daddr.idx = dFormat.idx;
                        cif.dstore = dFrame[dFormat.idx][1].data[0];
                end
            end
            else if(lru[dFormat.idx] == 0) begin
                if((dFrame[dFormat.idx][0].dirty && dFrame[dFormat.idx][0].valid)) begin
                    cif.dWEN = 1;
                    daddr.blkoff = 0;
                    daddr.bytoff = 0;
                    daddr.tag = dFrame[dFormat.idx][0].tag;
                    daddr.idx = dFormat.idx;
                    cif.dstore = dFrame[dFormat.idx][0].data[0];
                end
            end
            else if(lru[dFormat.idx] == 1) begin
                if((dFrame[dFormat.idx][1].dirty && dFrame[dFormat.idx][1].valid)) begin
                    cif.dWEN = 1;
                    daddr.blkoff = 0; //second block
                    daddr.bytoff = 0;
                    daddr.tag = dFrame[dFormat.idx][1].tag;
                    daddr.idx = dFormat.idx;
                    cif.dstore = dFrame[dFormat.idx][1].data[0];
                end
            end
        end
        WRITEBACK2: begin
            if (dFormat.tag == dFrame[dFormat.idx][0].tag && dFrame[dFormat.idx][0].valid) begin
                if(dFrame[dFormat.idx][0].dirty) begin
                        cif.dWEN = 1;
                        daddr.blkoff = 1;
                        daddr.bytoff = 0;
                        daddr.tag = dFrame[dFormat.idx][0].tag;
                        daddr.idx = dFormat.idx;
                        cif.dstore = dFrame[dFormat.idx][0].data[1];
                end
            end
            else if (dFormat.tag == dFrame[dFormat.idx][1].tag && dFrame[dFormat.idx][1].valid) begin
                if(dFrame[dFormat.idx][1].dirty) begin
                        cif.dWEN = 1;
                        daddr.blkoff = 1;
                        daddr.bytoff = 0;
                        daddr.tag = dFrame[dFormat.idx][1].tag;
                        daddr.idx = dFormat.idx;
                        cif.dstore = dFrame[dFormat.idx][1].data[1];
                end
            end
            else if(lru[dFormat.idx] == 0) begin
                if((dFrame[dFormat.idx][0].dirty && dFrame[dFormat.idx][0].valid)) begin
                    cif.dWEN = 1;
                    daddr.blkoff = 1;
                    daddr.bytoff = 0;
                    daddr.tag = dFrame[dFormat.idx][0].tag;
                    daddr.idx = dFormat.idx;
                    cif.dstore = dFrame[dFormat.idx][0].data[1];
                end
            end
            else if(lru[dFormat.idx] == 1) begin
                if((dFrame[dFormat.idx][1].dirty && dFrame[dFormat.idx][1].valid)) begin
                    cif.dWEN = 1;
                    daddr.blkoff = 1; //second block
                    daddr.bytoff = 0;
                    daddr.tag = dFrame[dFormat.idx][1].tag;
                    daddr.idx = dFormat.idx;
                    cif.dstore = dFrame[dFormat.idx][1].data[1];
                end
            end
        end
        LOAD1: begin //first block
            cif.dREN = 1; //reading memory into cache
            daddr.blkoff = 0; //first block
            daddr.bytoff = 0;
            daddr.tag = dFormat.tag;
            daddr.idx = dFormat.idx;
            if (dFormat.tag == dFrame[dFormat.idx][0].tag) begin
                next_dFrame[dFormat.idx][0].data[0] = cif.dload;
            end
            else if (dFormat.tag == dFrame[dFormat.idx][1].tag) begin
                next_dFrame[dFormat.idx][1].data[0] = cif.dload;
            end
            else if(lru[dFormat.idx] == 0) begin //check LRU
                next_dFrame[dFormat.idx][0].data[0] = cif.dload;
            end
            else begin
                next_dFrame[dFormat.idx][1].data[0] = cif.dload;
            end
        end
        LOAD2: begin //second block
            //cif.cctrans = 1; //let bus know load is done
            cif.dREN = 1; //reading memory into cache
            daddr.blkoff = 1; //second block
            daddr.bytoff = 0;
            daddr.tag = dFormat.tag;
            daddr.idx = dFormat.idx;
            if (dFormat.tag == dFrame[dFormat.idx][0].tag) begin
                next_dFrame[dFormat.idx][0].tag = dFormat.tag;
                next_dFrame[dFormat.idx][0].dirty = dcif.dmemWEN;
                next_dFrame[dFormat.idx][0].valid = 1;
                next_dFrame[dFormat.idx][0].data[1] = cif.dload;
                // next_lru[dFormat.idx] = 1;
            end
            else if (dFormat.tag == dFrame[dFormat.idx][1].tag) begin
                next_dFrame[dFormat.idx][1].tag = dFormat.tag;
                next_dFrame[dFormat.idx][1].dirty = dcif.dmemWEN;
                next_dFrame[dFormat.idx][1].valid = 1;
                next_dFrame[dFormat.idx][1].data[1] = cif.dload;
                // next_lru[dFormat.idx] = 0;
            end
            else if(lru[dFormat.idx] == 0) begin //check LRU
                next_dFrame[dFormat.idx][0].tag = dFormat.tag;
                next_dFrame[dFormat.idx][0].dirty = dcif.dmemWEN;
                next_dFrame[dFormat.idx][0].valid = 1;
                next_dFrame[dFormat.idx][0].data[1] = cif.dload;
                // next_lru[dFormat.idx] = 1;
            end
            else begin
                next_dFrame[dFormat.idx][1].tag = dFormat.tag;
                next_dFrame[dFormat.idx][1].dirty = dcif.dmemWEN;
                next_dFrame[dFormat.idx][1].valid = 1;
                next_dFrame[dFormat.idx][1].data[1] = cif.dload;
                // next_lru[dFormat.idx] = 0;
            end
        end
           
        FLUSH: begin
            //push everything dirty to memory
            if(counter == 6'b011111 && !cif.dwait) begin
                next_dFrame = '0;
            end
            next_counter = counter + 1;
            if(dFrame[counter[3:1]][counter[4]].dirty && dFrame[counter[3:1]][counter[4]].valid) begin
                cif.dWEN = 1;
                cif.ccwrite = 1;
                cif.dstore = dFrame[counter[3:1]][counter[4]].data[counter[0]];
                daddr.blkoff = counter[0];
                daddr.bytoff = 0;
                daddr.tag = dFrame[counter[3:1]][counter[4]].tag;
                daddr.idx = counter[3:1];
                // cif.ccsnoopaddr = daddr;
                if(!cif.dwait) begin
                    next_counter = counter + 1; 
                    // next_dFrame[counter[3:1]][counter[4]].valid = 0;
                    // next_dFrame[counter[3:1]][counter[4]].dirty = 0;
                end
                else begin
                    next_counter = counter;
                end
            end
        end
        FLUSHEND: begin
            dcif.flushed = 1; //flush everything
            next_dFrame = '0;
        end
        //ccwrite: WB signal
        //cctrans: done w/ snoop
        //ccinv: Invalidate signal
        //ccwait: pause processor/cache
        //ccsnoopaddr: taken care of
        //DO WE NEED TO CHECK FOR SNOOPDIRTY OR SOMETHING?

        //WHEN TO DO CCWRITE PROPERLY?
        READMSI: begin //bus state transitions
            //cif.ccwrite = 0;
            if(dSnoop.tag == dFrame[dSnoop.idx][0].tag && dFrame[dSnoop.idx][0].valid) begin
                next_dFrame[dSnoop.idx][0].valid = dFrame[dSnoop.idx][0].valid;
                next_dFrame[dSnoop.idx][0].dirty = dFrame[dSnoop.idx][0].dirty;
                if(cif.ccinv) begin
                    next_dFrame[dSnoop.idx][0].valid = 0;
                    // next_dFrame[dFormat.idx][0].dirty = 0;
                end
                if((dFrame[dSnoop.idx][0].valid == 1 && dFrame[dSnoop.idx][0].dirty == 1)) begin //cif.dWEN) //M and BusRd
                    //M to S
                    //cif.ccwrite = 1;
                    //cif.dREN = 1;
                    cif.cctrans = 1;
                    //next_dFrame[dSnoop.idx][0].valid = 1;
                    next_dFrame[dSnoop.idx][0].dirty = 0;
                end
                else if((dFrame[dSnoop.idx][0].valid == 1 && dFrame[dSnoop.idx][0].dirty == 1)) begin //cif.dWEN) begin//M and BusRdX
                    //M to I
                    //cif.dREN = 1;
                    cif.ccwrite = 1;
                    cif.cctrans = 1;
                    next_dFrame[dSnoop.idx][0].dirty = 0;
                    //next_dFrame[dSnoop.idx][0].valid = 0;
                end
                else if((dFrame[dSnoop.idx][0].valid == 1 && dFrame[dSnoop.idx][0].dirty == 0)) begin //cif.dWEN) //S and BusRdX
                    //S to I
                    //cif.dREN = 1;
                    cif.ccwrite = 1;
                    cif.cctrans = 1;
                    next_dFrame[dSnoop.idx][0].dirty = 0;
                    next_dFrame[dSnoop.idx][0].valid = 0; //set I
                end
            end
            else if(dSnoop.tag == dFrame[dSnoop.idx][1].tag && dFrame[dSnoop.idx][1].valid) begin
                next_dFrame[dSnoop.idx][1].valid = dFrame[dSnoop.idx][1].valid;
                next_dFrame[dSnoop.idx][1].dirty = dFrame[dSnoop.idx][1].dirty;
                if(cif.ccinv) begin
                    next_dFrame[dSnoop.idx][1].valid = 0;
                    // next_dFrame[dFormat.idx][1].dirty = 0;
                end
                if((dFrame[dSnoop.idx][1].valid == 1 && dFrame[dSnoop.idx][1].dirty == 1)) begin //cif.dWEN)//M and BusRd
                    //M to S
                    //cif.ccwrite = 1;
                    //cif.dREN = 1;
                    cif.cctrans = 1;
                    //next_dFrame[dSnoop.idx][1].valid = 1;
                    next_dFrame[dSnoop.idx][1].dirty = 0;
                end
                else if((dFrame[dSnoop.idx][1].valid == 1 && dFrame[dSnoop.idx][1].dirty == 1)) begin //cif.dWEN)//M and BusRdX
                    //M to I
                    //cif.dREN = 1;
                    cif.ccwrite = 1;
                    cif.cctrans = 1;
                    next_dFrame[dSnoop.idx][1].dirty = 0;
                    //next_dFrame[dSnoop.idx][1].valid = 0;
                end
                else if((dFrame[dSnoop.idx][1].valid == 1 && dFrame[dSnoop.idx][1].dirty == 0)) begin //cif.dWEN)//and BusRdX
                    //S to I
                    //cif.dREN = 1;
                    cif.ccwrite = 1;
                    cif.cctrans = 1;
                    next_dFrame[dSnoop.idx][1].dirty = 0;
                    next_dFrame[dSnoop.idx][1].valid = 0; //set I
                end
            end
        end
        SETSNOOP1: begin //bus state transitions
            if(dSnoop.tag == dFrame[dSnoop.idx][0].tag) begin
                cif.dstore = dFrame[dSnoop.idx][0].data[0];
                daddr.blkoff = 0;
                daddr.bytoff = 0;
                daddr.tag = dSnoop.tag;
                daddr.idx = dSnoop.idx;
            end
            else if(dSnoop.tag == dFrame[dSnoop.idx][1].tag) begin
                cif.dstore = dFrame[dSnoop.idx][1].data[0];
                daddr.blkoff = 0;
                daddr.bytoff = 0;
                daddr.tag = dSnoop.tag;
                daddr.idx = dSnoop.idx;
            end
        end
        SETSNOOP2: begin //bus state transitions
            if(dSnoop.tag == dFrame[dSnoop.idx][0].tag) begin
                cif.dstore = dFrame[dSnoop.idx][0].data[1];
                daddr.blkoff = 1;
                daddr.bytoff = 0;
                daddr.tag = dSnoop.tag;
                daddr.idx = dSnoop.idx;
            end
            else if(dSnoop.tag == dFrame[dSnoop.idx][1].tag) begin
                cif.dstore = dFrame[dSnoop.idx][1].data[1];
                daddr.blkoff = 1;
                daddr.bytoff = 0;
                daddr.tag = dSnoop.tag;
                daddr.idx = dSnoop.idx;
            end
        end
    endcase
end
endmodule