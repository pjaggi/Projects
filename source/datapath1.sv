`include "datapath_cache_if.vh"
`include "fetch_decode_if.vh"
`include "decode_execute_if.vh"
`include "execute_memory_if.vh"
`include "memory_writeback_if.vh"
`include "alu_abstract_if.vh"
`include "register_file_abstract_if.vh"
`include "control_unit_if.vh"

module datapath(input logic CLK, nRST, 
datapath_cache_if.dp dpif);

import cpu_types_pkg::*;
//pc_init = 0

//interface names
fetch_decode_if fdif();
decode_execute_if deif();
execute_memory_if emif();
memory_writeback_if mwif();
alu_abstract_if alu_abs();
register_file_abstract_if rf_abs();
control_unit_if cuif();
program_counter_if pc();
next_pc_if npc();
branch_addr_if ba();
jump_addr_if ra();

//DUT
fetch_decode FD(CLK, nRST, fdif);
decode_execute DE(CLK, nRST, deif);
execute_memory EM(CLK, nRST, emif);
memory_writeback MW(CLK, nRST, mwif);
alu_abstract ALU(alu_abs);
register_file_abstract REGFILE(CLK, nRST, rf_abs);
control_unit CTRL(cuif);
program_counter PC(CLK, nRST, pc);
next_pc NPC(npc);
branch_addr BA(ba);
jump_addr JA(ra);


//fetch-decode
assign fdif.fetch_instr_in = dpif.imemload;//or from icache
assign fdif.ihit = dpif.ihit;
assign fdif.dhit = dpif.dhit;
assign fdif.flush = dpif.flushed;//CHECK THIS
//assign fdif.pc4_in = pcif.pc;
//assign fdif.pc4_in = pcif.pc4;//CHECK THIS OUT

//decode-execute
assign deif.flush = huif.flush;//from halt unit or from dpif??
assign deif.ihit = dpif.ihit;
assign deif.pc4_in = fdif.pc4_out;//CHECK THIS OUT
assign deif.decode_instr_in = fdif.decode_instr_out;//LOOK AT THIS AGAIN!!!!!


//execute-memory
//control signals needed
//assign emif.flush = huif.flush;
assign emif.dhit = dpif.dhit;
assign emif.ihit = dpif.ihit;
assign emif.rdat1_in = deif.rdat1_out;
assign emif.rdat2_in = deif.rdat2_out;//DOUBLE CHECK THIS
assign emif.aluop_in = deif.aluop_out;
assign emif.RegDst_in = deif.RegDst_out;
assign emif.bne_in = deif.bne_out;
assign emif.SignExtend_in = deif.SignExtend_out; //enable signal whenever andi, ori, xori are selected
assign emif.MemtoReg_in = deif.MemtoReg_out;
assign emif.dWEN_in = deif.dWEN_out; //only for store
assign emif.dREN_in = deif.dREN_out; //only for load
assign emif.halt_in = deif.halt_out;//DOES CONTROL DEAL WITH HALT
assign emif.AluSrc_in = deif.AluSrc_out;
assign emif.jump_in = deif.jump_out;
assign emif.branch_in = deif.branch_out;
assign emif.jr_in = deif.jr_out;
assign emif.lui_in = deif.lui_out;
assign emif.jal_in = deif.jal_out;
assign emif.RegWrite_in = deif.RegWrite_out; //reg write enable signal
//INSTR
assign emif.instruction_in = deif.decode_instr_out;//LOOK AT THIS AGAIN!!!!!
assign emif.InstrE_in = deif.InstrE_out;//output of sign extender
assign emif.pc4_in = deif.pc4_out;
//assign emif.rdat1_in = deif.rdat1_out;
//assign emif.rdat2_in = deif.rdat2_out;

//memory-writeback
assign mwif.ihit = ;
assign mwif.dhit = ;
assign mwif.pc4_in = emif.pc4_out;
assign mwif.outport_in = emif.outport_out;
assign mwif.instruction_in = emif.instruction_out;

///SPECIFIC BLOCKS///

//PC//
//inputs
assign pc.ihit = dpif.ihit;
assign pc.next_PC = mwif.next_pc_out;//is it output of memory/write back
//outputs
assign fdif.pc_in = pc.PC;
assign fdif.pc4_in = pc.PC4;

//SIGN EXTENDER//
//inputs
assign se.Instruction = fdif.decode_instr_out;
assign se.SignExtend = cuif.SignExtend;//aox signal from control unit
assign se.LUI = cuif.LUI;
//output
assign deif.InstrE_in = se.InstrE;//output of sign extender

//REGISTER//
//inputs
assign rf_abs.RegWrite = cuif.RegWrite;
assign rf_abs.JAL = cuif.JAL;
assign rf_abs.Instruction = fdif.decode_instr_out;
assign rf_abs.RegDst = cuif.RegDst;
assign rf_abs.dload = mwif.dload_out;
assign rf_abs.ihit = ;//needs to propogate through
assign rf_abs.ALUResult = mwif.outport_out;//alu result outport from write back
//outputs
assign deif.rdat1_in = rf_abs.rdat1;
assign deif.rdat2_in = rf_abs.rdat2;

//CONTROL UNIT//
//inputs
assign cuif.ihit = ;
assign cuif.dhit = ;
assign cuif.Instruction = fdif.decode_instr_out;
//outputs
assign deif.RegDst_in = cuif.RegDst;
assign deif.jump_in = cuif.Jump;
assign deif.jr_in = cuif.JumpReg; //jr
assign deif.jal_in = cuif.JAL;
assign deif.branch_in = cuif.Branch;
assign deif.bne_in = cuif.BNE;
assign deif.dWEN_in = cuif.MemWrite; //dWEN - only for store
assign deif.MemtoReg_in = cuif.MemToReg;
assign deif.dREN_in = cuif.MemRead; //dREN - only for load
assign deif.AluSrc_in = cuif.ALUSrc;
assign deif.RegWrite_in = cuif.RegWrite;
assign deif.aluop_in = cuif.ALUOp;//what should default value be?
assign deif.SignExtend_in = cuif.SignExtend; //enable signal whenever andi, ori, xori are selected
assign deif.halt_in = cuif.Halt;//DOES CONTROL DEAL WITH HALT
assign deif.lui_in = cuif.LUI;

//BRANCH ADDR//
//inputs
assign ba.InstrE = deif.InstrE_out;
assign ba.PC4 = deif.pc4_out;
//output
assign emif.branchaddr_in = ba.BranchAddr;//ouput of branch addr

//JUMP ADDR//
//inputs
assign ra.Instruction = deif.decode_instr_out; //instruction passed through from decode/execute
assign ra.PC4 = deif.pc4_out;
//output
assign emif.jumpaddr_in = ra.JumpAddr;//output of jump addr

//ALU//
//inputs
assign alu_abs.rdat1 = deif.rdat1_out;
assign alu_abs.rdat2 = deif.rdat2_out;
assign alu_abs.InstrE = deif.InstrE_out;
assign alu_abs.ALUOP = deif.aluop_out;
assign alu_abs.ALUSrc = deif.AluSrc_out;
//outputs
assign emif.outport_in = alu_abs.outport;//output of alu result
assign emif.zero_in = alu_abs.zero;
assign emif.overflow_in = alu_abs.over;
assign emif.neg_in = alu_abs.neg;

//NEXT PC//
//inputs
assign npc.BranchAddr = emif.branchaddr_out;
assign npc.JumpAddr = emif.jumpaddr_out;
assign npc.PC4 = emif.pc4_out;
assign npc.rdat1 = emif.rdat1_out;
assign npc.Zero = emif.zero_out;
assign npc.BNE = emif.bne_out;
assign npc.JumpReg = emif.jr_out;
assign npc.JAL = emif.jal_out;
//output
assign mwif.next_pc_in = npc.next_pc;

//CACHES//??
assign mwif.dload_in = ;

//put halt here??
//datapath
assign dpif.imemREN = 1;
assign dpif.dmemWEN = emif.dWEN_out;
assign dpif.dmemstore = emif.rdat2_out;
assign dpif.imemaddr = pc.PC;//pc from program counter or should it be propogated??
assign dpif.dmemaddr = emif.outport_out;
assign dpif.dmemREN = emif.dREN_out;
endmodule