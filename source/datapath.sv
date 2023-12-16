/*
datapath.sv
9/18/23
Pranay Jaggi
437-03
Version 1.1
datapath
*/
`include "datapath_cache_if.vh"
`include "fetch_decode_if.vh"
`include "decode_execute_if.vh"
`include "execute_memory_if.vh"
`include "memory_writeback_if.vh"
`include "alu_abstract_if.vh"
`include "register_file_abstract_if.vh"
`include "control_unit_if.vh"
`include "program_counter_if.vh"
`include "next_pc_if.vh"
`include "branch_addr_if.vh"
`include "jump_addr_if.vh"
`include "halt_if.vh"
`include "sign_extend_if.vh"
`include "hazard_unit_if.vh"
`include "branch_predict_if.vh"
`include "forwarding_unit_if.vh"

module datapath(
    input logic CLK, nRST, 
    datapath_cache_if.dp dpif
);

import cpu_types_pkg::*;
parameter PC_INIT = 0;

//INTERFACE NAMES///
    fetch_decode_if fdif();
    decode_execute_if deif();
    execute_memory_if emif();
    memory_writeback_if mwif();
    alu_abs_if alu_abs();
    register_file_abstract_if rf_abs();
    control_unit_if cuif();
    program_counter_if pc();
    next_pc_if npc();
    branch_addr_if b();
    jump_addr_if j();
    halt_if huif();
    sign_extend_if se();
    hazard_unit_if haif();
    branch_predict_if bpif();
    forwarding_unit_if fuif();

//DUT///
    fetch_decode FD(CLK, nRST, fdif);
    decode_execute DE(CLK, nRST, deif);
    execute_memory EM(CLK, nRST, emif);
    memory_writeback MW(CLK, nRST, mwif);
    alu_abstract ALU(alu_abs);
    register_file_abstract REGFILE(CLK, nRST, rf_abs);
    control_unit CTRL(CLK, nRST, cuif);
    program_counter #(.PC_INIT(PC_INIT)) PC(CLK, nRST, pc);
    next_pc NPC(npc);
    branch_addr BA(b);
    jump_addr JA(j);
    halt HALT1(CLK, nRST, huif);
    sign_extend SIGN(se);
    hazard_unit HA(haif);
    branch_predict BP(bpif);
    forwarding_unit FU(fuif);

///REGISTERS///
    
    //fetch-decode
        assign fdif.fetch_instr_in = dpif.imemload;
        assign fdif.ihit = dpif.ihit;
        assign fdif.dhit = dpif.dhit;
        assign fdif.flush = emif.halt_out | dpif.halt | bpif.flushFD | haif.flushFD | deif.jump_out | deif.jal_out | deif.jr_out;

    //decode-execute
        assign deif.ihit = dpif.ihit;
        assign deif.dhit = dpif.dhit;
        assign deif.pc4_in = fdif.pc4_out;
        assign deif.next_pc_in = fdif.next_pc_out;
        assign deif.decode_instr_in = fdif.decode_instr_out;
        assign deif.flush = emif.halt_out | dpif.halt | bpif.flushDE | 
        ((deif.jump_out | deif.jal_out | deif.jr_out |  haif.flushDE) & (dpif.ihit | dpif.dhit)) | haif.flushHALT;

    //execute-memory
        assign emif.dhit = dpif.dhit;
        assign emif.ihit = dpif.ihit;
        //assign emif.rdat1_in = deif.rdat1_out;
        assign emif.rdat2_in = fuif.ALU_B;
        assign emif.aluop_in = deif.aluop_out;
        assign emif.RegDst_in = deif.RegDst_out;
        assign emif.bne_in = deif.bne_out;
        assign emif.SignExtend_in = deif.SignExtend_out;
        assign emif.MemtoReg_in = deif.MemtoReg_out;
        assign emif.dWEN_in = deif.dWEN_out;
        assign emif.dREN_in = deif.dREN_out;
        assign emif.halt_in = deif.halt_out;
        assign emif.AluSrc_in = deif.AluSrc_out;
        assign emif.jump_in = deif.jump_out;
        assign emif.branch_in = deif.branch_out;
        assign emif.jr_in = deif.jr_out;
        assign emif.lui_in = deif.lui_out;
        assign emif.jal_in = deif.jal_out;
        assign emif.RegWrite_in = deif.RegWrite_out;
        //INSTR
        assign emif.instruction_in = deif.decode_instr_out;
        assign emif.InstrE_in = deif.InstrE_out;
        assign emif.pc4_in = deif.pc4_out;
        assign emif.next_pc_in = deif.next_pc_out;
        assign emif.flush = dpif.halt | ((bpif.flushEM | haif.flushEM) & (dpif.ihit | dpif.dhit)) | haif.flushHALT;

    //memory-writeback
        assign mwif.dhit = dpif.dhit;
        assign mwif.ihit = dpif.ihit;
        assign mwif.rdat2_in = emif.rdat2_out;
        assign mwif.RegDst_in = emif.RegDst_out;
        assign mwif.MemtoReg_in = emif.MemtoReg_out;
        assign mwif.jal_in = emif.jal_out;
        assign mwif.RegWrite_in = emif.RegWrite_out;
        assign mwif.pc4_in = emif.pc4_out;
        assign mwif.outport_in = emif.outport_out;
        assign mwif.instruction_in = emif.instruction_out;
        assign mwif.halt_in = emif.halt_out;
        assign mwif.flush = dpif.halt | haif.flushMW;

///SPECIFIC BLOCKS///

    //HALT - fetch//
        //input
        assign huif.halt_in = mwif.halt_out;
        //output
        assign dpif.halt = huif.halt_out;

    //PC - fetch//
        //inputs
        assign pc.ihit = dpif.ihit;
        assign pc.stall = ((haif.stallFD  | haif.stallDE | haif.stallEM | haif.stallMW | !dpif.ihit) & 
        (!(deif.jump_out | deif.jal_out | deif.jr_out) & 
        !(((!emif.bne_out & emif.zero_out) | (emif.bne_out & !emif.zero_out)) & emif.branch_out)));
        //outputs
        assign fdif.pc_in = pc.PC;
        assign fdif.pc4_in = pc.PC4;

    //SIGN EXTENDER - decode//
        //inputs
        assign se.Instruction = fdif.decode_instr_out;
        assign se.SignExtend = cuif.SignExtend;
        assign se.LUI = cuif.LUI;
        //output
        assign deif.InstrE_in = se.InstrE;

    //REGISTER - decode//
        //inputs
        assign rf_abs.RegWrite = mwif.RegWrite_out;
        assign rf_abs.MemToReg = mwif.MemtoReg_out;
        assign rf_abs.JAL = mwif.jal_out;
        assign rf_abs.Instruction = fdif.decode_instr_out;
        assign rf_abs.lastInstruction = mwif.instruction_out;
        assign rf_abs.RegDst = mwif.RegDst_out;
        assign rf_abs.dload = mwif.dload_out;
        assign rf_abs.ALUResult = mwif.outport_out;
        assign rf_abs.PC4 = mwif.pc4_out;
        //outputs
        assign deif.rdat1_in = rf_abs.rdat1;
        assign deif.rdat2_in = rf_abs.rdat2;

    //CONTROL UNIT - decode//
        //inputs
        assign cuif.ihit = dpif.ihit;
        assign cuif.dhit = dpif.dhit;
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

        assign deif.datomic_in = cuif.datomic;
        assign emif.datomic_in = deif.datomic_out;

    //BRANCH ADDR - execute//
        //inputs
        assign b.InstrE = emif.InstrE_out;
        assign b.PC4 = emif.pc4_out;
        //output
        assign npc.BranchAddr = b.BranchAddr;//ouput of branch addr

    //JUMP ADDR - move to decode//
        //inputs
        assign j.Instruction = deif.decode_instr_out;//dpif.imemload; //instruction passed through from decode/execute
        assign j.PC4 = deif.pc4_out;//pc.PC4;
        //output
        assign npc.JumpAddr = j.JumpAddr;//output of jump addr

    //ALU - execute//
        //inputs
        //assign alu_abs.rdat1 = fuif.ALU_A;//deif.rdat1_out; //go to forwarding unit, and that will send out A
        //assign alu_abs.rdat2 = fuif.ALU_B;//deif.rdat2_out; //go to forwarding unit, and that will send out B
        assign alu_abs.InstrE = deif.InstrE_out;
        assign alu_abs.ALUOP = deif.aluop_out;
        assign alu_abs.ALUSrc = deif.AluSrc_out;
        //outputs
        assign emif.outport_in = alu_abs.outport;//output of alu result
        assign emif.zero_in = alu_abs.zero;
        assign emif.overflow_in = alu_abs.over;
        assign emif.neg_in = alu_abs.neg;

    //NEXT PC - fetch//
        //inputs
        assign npc.PC4 = pc.PC4;
        assign npc.rdat1 = deif.rdat1_out;
        assign npc.Zero = emif.zero_out;
        assign npc.BNE = emif.bne_out;
        assign npc.Jump = deif.jump_out;
        assign npc.JumpReg = deif.jr_out;//don't know where it is coming from
        assign npc.JAL = deif.jal_out;
        assign npc.Branch = emif.branch_out;
        //assign npc.stall = (haif.stallFD | haif.stallDE | haif.stallEM | haif.stallMW);
        //assign npc.stall = 0;
        //output
        assign pc.next_PC = npc.next_PC;
        assign fdif.next_pc_in = npc.next_PC;

    //DATAPATH SIGNALS//
    assign mwif.dload_in = dpif.dmemload;
    assign dpif.imemREN = !dpif.halt & !(dpif.dmemWEN | dpif.dmemREN);//1 - CHECK THIS OUT
    assign dpif.dmemWEN = emif.dWEN_out;
    assign dpif.dmemstore = emif.rdat2_out;
    assign dpif.imemaddr = pc.PC;
    assign dpif.dmemaddr = emif.outport_out;
    assign dpif.dmemREN = emif.dREN_out;

    //HAZARD//
        //inputs
        assign haif.FDIFinst = fdif.decode_instr_out;//fdif.fetch_instr_in;
        assign haif.DEIFinst = deif.decode_instr_out;//deif.decode_instr_in;
        assign haif.EMIFinst = emif.instruction_out;//emif.instruction_in;
        assign haif.MWIFinst = mwif.instruction_out;
        assign haif.deif_branch = deif.branch_out;
        //outputs
        assign fdif.stall = haif.stallFD;
        //assign fdif.flush = haif.flushFD;
        assign deif.stall = haif.stallDE;
        //assign deif.flush = haif.flushDE;
        assign  emif.stall = haif.stallEM;
        //assign emif.flush = haif.flushEM;
        assign  mwif.stall = haif.stallMW;
        //assign mwif.flush = haif.flushMW;

        assign haif.DEIFRegWrite = deif.RegWrite_out;
        assign haif.EMIFRegWrite = emif.RegWrite_out;
        assign haif.dWEN = emif.dWEN_out;

    //BRANCH PREDICT//
        //inputs
        assign bpif.zero = emif.zero_out;
        assign bpif.Branch = emif.branch_out;
        assign bpif.BNE = emif.bne_out;

        //outputs
        //assign deif.flush = bpif.flushDE;
        //assign fdif.flush = bpif.flushFD | haif.flushFD;

    //FORWARDING//
        //inputs 
        assign fuif.rdat1 = deif.rdat1_out;
        assign fuif.rdat2 = deif.rdat2_out;
        assign fuif.DEIFRegWrite = deif.RegWrite_out;
        assign fuif.EMIFRegWrite = emif.RegWrite_out;
        assign fuif.MWIFRegWrite = mwif.RegWrite_out;
        assign fuif.DEIFInst = deif.decode_instr_out;
        assign fuif.EMIFInst = emif.instruction_out;
        assign fuif.MWIFInst = mwif.instruction_out;
        assign fuif.alu_result_emif = emif.outport_out;
        assign fuif.alu_result_mwif = mwif.outport_out;
        assign fuif.dload_emif = dpif.dmemload;
        assign fuif.dload_mwif = mwif.dload_out;
        assign fuif.RegDst_EMIF = emif.RegDst_out;
        assign fuif.RegDst_MWIF = mwif.RegDst_out;

        //outputs
        assign alu_abs.rdat1 = fuif.ALU_A;
        assign alu_abs.rdat2 = fuif.ALU_B;

    //LLSC//
        assign dpif.datomic = emif.datomic_out;

//DO NOT DELETE THIS
    r_t instrout;
    assign instrout = r_t'(dpif.imemload);
endmodule