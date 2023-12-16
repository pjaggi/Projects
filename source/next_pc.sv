/*
next_pc.sv
9/17/23
Michael Fuchs
437-03
Version 1.0
abstracted next pc calculation for datapath
*/
//next_pc_if npc();
`include "next_pc_if.vh"
module next_pc (next_pc_if.npc npc);
  
  //BEQ vs BNE
    //Supporting Logic
      logic Zero;
      logic BranchZero;
      always_comb begin : BEQ_BNE
        Zero = npc.Zero;
        if(npc.BNE == 1) Zero = !npc.Zero;
      end
      assign BranchZero = (npc.Branch & Zero);

  //Next PC Logic
      always_comb begin : pc_next
        //if(!npc.stall) begin
          //by default: PC+4
          npc.next_PC = npc.PC4;
          //if branch and zero, use calculated jump
          if(BranchZero) begin
              npc.next_PC = npc.BranchAddr;
          end
          //if jump, jump to instruction
          else if(npc.Jump == 1) begin
              npc.next_PC = npc.JumpAddr;
          end
          //if jr, jump to register
          else if(npc.JumpReg == 1) begin
              npc.next_PC = npc.rdat1;
          end
          else if(npc.JAL) begin
              npc.next_PC = npc.JumpAddr;
          end
        //end
        /*else begin
          npc.next_PC = npc.PC;
        end*/
      end
endmodule