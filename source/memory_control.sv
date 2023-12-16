/*
  Michael Fuchs
  mjfuchs@icloud.com

  this block is the coherence protocol
  and artibtration for ram
*/

// interface include
`include "cache_control_if.vh"

// memory types
`include "cpu_types_pkg.vh"

module memory_control (
  input CLK, nRST,
  cache_control_if.cc ccif
);
  // type import
  import cpu_types_pkg::*;

  // number of cpus for cc
  parameter CPUS = 2;

  ///request logic for multicore caches
  logic requestI, nextrequestI;

  //signals for arbitration of source to read from and target to write to
  logic source, nextSource;
  logic target, nextTarget;

  //bus controller logic for cache to cache coherence
  typedef enum logic [4:0] {ARBITRATE, SNOOP, SNOOPRESP, RESPONSEI, C2C1, C2C2, WRITE1, WRITE2, WRITEBACK1, WRITEBACK2, READRAM1, READRAM2} state_type;
  state_type state, nextState;

  always_comb begin : nextStateLogic
      nextState = state;
      case(state)
          ARBITRATE: begin
              //arbitrate by selecting request
              if((ccif.dWEN[0] || ccif.dWEN[1])) begin
                  nextState = WRITE1;
              end
              else if((ccif.dREN[0] || ccif.dREN[1])) begin
                  nextState = SNOOP;
              end
              else if((ccif.iREN[0] || ccif.iREN[1])) begin
                  nextState = RESPONSEI;
              end
          end
        
          RESPONSEI: begin
              //move to ARBITRATE if not waiting and not writing back
              if((ccif.ramstate == ACCESS)) begin
                  nextState = ARBITRATE;
              end
              //otherwise stay in RESPONSE until value is retrieved
          end
        
          SNOOP: begin
              //snoop caches, if value is in other cache write from cache to cache, 
              //else defer to arbiter
              nextState = SNOOPRESP;
          end

          SNOOPRESP: begin
              if(!(ccif.cctrans[target])) begin
                nextState = READRAM1;
              end
              else if(ccif.cctrans[target] && ccif.ccwrite[source]) begin
                nextState = C2C1;
              end
              else if(ccif.cctrans[target] && !ccif.ccwrite[source]) begin
                nextState = WRITEBACK1;
              end
          end
        
          C2C1: begin
            nextState = C2C2;
          end
          C2C2: begin
            nextState = ARBITRATE;
          end
        
          WRITE1: begin
            if((ccif.ramstate == ACCESS)) begin
              nextState = WRITE2;
            end
          end
          WRITE2: begin
            if((ccif.ramstate == ACCESS)) begin
              nextState = ARBITRATE;
            end
          end

          WRITEBACK1: begin
            if((ccif.ramstate == ACCESS)) begin
              nextState = WRITEBACK2;
            end
          end
          WRITEBACK2: begin
            if((ccif.ramstate == ACCESS)) begin
              nextState = ARBITRATE;
            end
          end
        
          READRAM1: begin
            if((ccif.ramstate == ACCESS)) begin
              nextState = READRAM2;
            end
          end
          READRAM2: begin
            if((ccif.ramstate == ACCESS)) begin
              nextState = ARBITRATE;
            end
          end
      endcase
  end

  always_ff @(posedge CLK, negedge nRST) begin : nextStateFlops
      //if reset wait for request, set request's to 0 by default
      if(!nRST) begin
          state <= ARBITRATE;
          requestI <= 0;
          source <= 0;
          target <= 0;
      //else go to the next state
      end else begin
          state <= nextState;
          requestI <= nextrequestI;
          source <= nextSource;
          target <= nextTarget;
      end
  end

  always_comb begin : outputLogicBusArbiter
      //set wait signals (high from after request until complete state)
      ccif.dwait[0] = 1;
      ccif.dwait[1] = 1;
      ccif.iwait[0] = 1;
      ccif.iwait[1] = 1;
      ccif.ccwait[0] = 0;
      ccif.ccwait[1] = 0;

      //set invalidate signal
      ccif.ccinv[0] = 0;
      ccif.ccinv[1] = 0;

      //init variables
      ccif.dload[0] = 0;
      ccif.dload[1] = 0;
      ccif.iload[0] = 0;
      ccif.iload[1] = 0;
      ccif.ccsnoopaddr[0] = 0;
      ccif.ccsnoopaddr[1] = 0;

      //ram init variablessim:/system_tb/DUT/CPU/cif0/cctrans

      ccif.ramaddr = 0;
      ccif.ramstore = 0;
      ccif.dload[0] = 0;
      ccif.dload[1] = 0;
      ccif.iload[0] = 0;
      ccif.iload[1] = 0;

      ccif.ramWEN = 0;
      ccif.ramREN = 0;

      

      nextrequestI = requestI;
      nextSource = source;
      nextTarget = target;

      case(state)
          ARBITRATE: begin
            //next requestI logic
            ccif.ccinv[target] = ccif.ccwrite[source];
            ccif.ccsnoopaddr[target] = ccif.daddr[source];
            nextrequestI = requestI;
            if(requestI == 0) begin
              nextrequestI = 1;
            end
            else if(requestI == 1) begin
              nextrequestI = 0;
            end

            //source and target calculation
            nextSource = source;
            nextTarget = target;
            if(ccif.dREN[0] || ccif.dWEN[0]) begin
              nextSource = 0;
              nextTarget = 1;
            end
            else if(ccif.dREN[1] || ccif.dWEN[1]) begin
              nextSource = 1;
              nextTarget = 0;
            end
          end

          RESPONSEI: begin
            ccif.ramaddr = ccif.iaddr[source];
            ccif.ramstore = 0;
            ccif.iload[requestI] = 0;
            ccif.iwait[requestI] = 1;
            ccif.ramWEN = 0;
            ccif.ramREN = 1;
            ccif.ramaddr = ccif.iaddr[requestI];
            if(ccif.ramstate == ACCESS) begin
              ccif.iload[requestI] = ccif.ramload;
              ccif.iwait[requestI] = 0;
            end
          end

          WRITE1: begin //do a ramWrite of target
            ccif.ramWEN = 1;
            ccif.ccsnoopaddr[target] = ccif.daddr[source];
            ccif.ccinv[target] = ccif.ccwrite[source];
            ccif.ramstore = ccif.dstore[source];
            ccif.ramaddr = ccif.daddr[source];
            ccif.dwait[source] = 1;
            if(ccif.ramstate == ACCESS) begin
              ccif.dwait[source] = 0;
            end
          end
          WRITE2: begin //do a ramWrite of target
            ccif.ramWEN = 1;
            ccif.ccsnoopaddr[target] = ccif.daddr[source];
            ccif.ccinv[target] = ccif.ccwrite[source];
            ccif.ramstore = ccif.dstore[source];
            ccif.ramaddr = ccif.daddr[source];
            ccif.dwait[source] = 1;
            if(ccif.ramstate == ACCESS) begin
              ccif.dwait[source] = 0;
            end
          end
          
          SNOOP: begin
            ccif.ccinv[target] = ccif.ccwrite[source];
            ccif.ccwait[target] = 1;
            ccif.dwait[source] = 1;
            //ccif.iwait[source] = 1;
            ccif.ccsnoopaddr[target] = ccif.daddr[source];
          end

          SNOOPRESP: begin
            ccif.ccinv[target] = ccif.ccwrite[source];
            ccif.ccwait[target] = 1;
            ccif.dwait[source] = 1;
            //ccif.iwait[source] = 1;
            ccif.ccsnoopaddr[target] = ccif.daddr[source];
          end

          WRITEBACK1: begin //do a ramWrite of target
            ccif.ramWEN = 1;
            ccif.ccsnoopaddr[target] = ccif.daddr[source];
            ccif.ramstore = ccif.dstore[target];
            ccif.ramaddr = ccif.daddr[target];
            ccif.dwait[target] = 1;

            ccif.dwait[source] = 1;
            ccif.ccwait[target] = 1;

            ccif.dload[source] = ccif.dstore[target];

            if(ccif.ramstate == ACCESS) begin
              ccif.dwait[target] = 0;
              ccif.dwait[source] = 0;
            end
          end
          WRITEBACK2: begin //do a ramWrite of target
            ccif.ramWEN = 1;
            ccif.ccsnoopaddr[target] = ccif.daddr[source];
            ccif.ramstore = ccif.dstore[target];
            ccif.ramaddr = ccif.daddr[target];
            ccif.dwait[target] = 1;

            ccif.dload[source] = ccif.dstore[target];
            
            ccif.dwait[source] = 1;
            ccif.ccwait[target] = 1;

            if(ccif.ramstate == ACCESS) begin
              ccif.dwait[target] = 0;
              ccif.dwait[source] = 0;
            end
          end
        
          C2C1: begin ///hit in cache, send block 0 in one cycle
            ccif.dload[source] = ccif.dstore[target];

            ccif.ccsnoopaddr[target] = ccif.daddr[source];
            ccif.ccwait[target] = 1;
            ccif.dwait[source] = 0;
            ccif.dwait[target] = 0;
            //ccif.ccinv[target] = ccif.ccwrite[source];
          end
          C2C2: begin //hit in cache, send block 1 in one cycle
            ccif.dload[source] = ccif.dstore[target];

            ccif.ccsnoopaddr[target] = ccif.daddr[source];
            ccif.ccwait[target] = 1;
            ccif.dwait[source] = 0;
            ccif.dwait[target] = 0;
            //ccif.ccinv[target] = ccif.ccwrite[source];
            
          end

          READRAM1: begin //missed snoop, read block 0 value from ram
            ccif.dload[source] = ccif.ramload;
            ccif.ramREN = 1;
            //ccif.ccsnoopaddr[source] = ccif.daddr[source];
            ccif.ramstore = 0;
            ccif.ramaddr = ccif.daddr[source];
            ccif.dwait[source] = 1;
            if(ccif.ramstate == ACCESS) begin
              ccif.dwait[source] = 0;
            end
          end
          READRAM2: begin //missed snoop, read block 1 value from ram
            ccif.dload[source] = ccif.ramload;
            ccif.ramREN = 1;
            //ccif.ccsnoopaddr[source] = ccif.daddr[source];
            ccif.ramstore = 0;
            ccif.ramaddr = ccif.daddr[source];
            ccif.dwait[source] = 1;
            if(ccif.ramstate == ACCESS) begin
              ccif.dwait[source] = 0;
            end
          end
      endcase
  end
endmodule
