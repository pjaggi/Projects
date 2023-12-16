/*
  Eric Villasenor
  evillase@gmail.com

  datapath contains register file, control, hazard,
  muxes, and glue logic for processor
*/

// data path interface
`include "datapath_cache_if.vh"
`include "alu_if.vh"
`include "control_unit_if.vh"
`include "request_unit_if.vh"
`include "register_file_if.vh"

// alu op, mips op, and instruction type
`include "cpu_types_pkg.vh"

module datapath (
  input logic CLK, nRST,
  datapath_cache_if.dp dpif
);
  // import types
  import cpu_types_pkg::*;

  // pc init
  parameter PC_INIT = 0;
//interfaces
request_unit_if ruif();
alu_if aluif();
register_file_if rfif();
control_unit_if cuif ();

request_unit request(CLK, nRST, ruif);
alu alu(aluif);
register_file register(CLK, nRST, rfif);
control_unit control(cuif);

logic [31:0] pc, pc_nxt, pc4;
logic [31:0] BranchAddr, JumpAddr, extendZeroImm;
logic Zero;

//HALT  - ALL GOOD
always_ff @(posedge CLK, negedge nRST) begin
  if(1'b0 == nRST) begin
    dpif.halt <= '0;
  end
  else begin
    dpif.halt <= cuif.halt | dpif.halt;
  end
end


//control unit
assign cuif.instr = dpif.imemload;

//PC - need to add more logic
//assign pc_nxt = pc + 4;
always_ff @(posedge CLK, negedge nRST) begin
  if(1'b0 == nRST) begin
    pc <= PC_INIT;
  end
  else if(dpif.ihit) begin
    pc <= pc_nxt;
  end
end

assign pc4 = pc + 4;

//Signed, Zero, etc.
//BRANCH ADDR, JUMP ADDR
//LUI_IMM????//
logic [15:0] imm;
assign imm = cuif.instr[15:0];
assign extendZeroImm = {16'h0000,imm};//zero extend with immediate
//assign extendSignedImm = (imm[15] == 0) ? {16'h0000,imm} {16'hffff,imm};//sign extend with immediate
//CHECK if 16'b0 and 16'b1 are allowed or if it should be 16'hffff and 16'h0000
//assign shamt = {27'b0,dpif.imemload[10:6]};//should we use this???

//Datapath
assign dpif.imemREN = 1;//!halt instead?
assign dpif.imemaddr = pc;
assign dpif.dmemREN = ruif.dmemread;//why should it be request unit
assign dpif.dmemWEN = ruif.dmemwrite;//why should it be request unit
assign dpif.dmemstore = rfif.rdat2;
assign dpif.dmemaddr = aluif.outport;

assign cuif.ihit = dpif.ihit;
assign cuif.dhit = dpif.dhit;
//Request
assign ruif.ihit = dpif.ihit;
assign ruif.dhit = dpif.dhit;
assign ruif.memread = cuif.dREN;//read enable same as dREN?
assign ruif.memwrite = cuif.dWEN;//write enable same as dWEN?

//Register
assign rfif.rsel1 = cuif.instr[25:21];//rs
assign rfif.rsel2 = cuif.instr[20:16];//rt
assign rfif.WEN = cuif.RegWrite;
always_comb begin //only two values for regdst?
  rfif.wsel = cuif.instr[20:16];
  if(cuif.RegDst == 1) begin//CHECK THIS - BASE CASE GOOD?
    rfif.wsel = cuif.instr[15:11];
  end
  else if(cuif.jal == 1 & dpif.ihit) begin//CHECK THIS
    rfif.wsel = 31;
  end
end
//CHECK THIS - ihit and dhit dont matter
always_comb begin
  if(cuif.lui) begin
    rfif.wdat = {imm,16'b0};
  end
  else if(cuif.jal) begin
    rfif.wdat = pc4;//I THINK?
    //rfif.wsel = 31;
  end
  else if(cuif.MemtoReg) begin
    rfif.wdat = dpif.dmemload;
  end
  else begin//!cuif.MemtoReg
    rfif.wdat = aluif.outport;
  end
end

always_comb begin
  if(cuif.branch == 1) begin//CHECK CALCULATION OF BRANCH ADDR
  //SHOULD I CONSIDER aluif.zero or cuif.BNE
    //if(cuif.instr[15] == 1) begin
      BranchAddr = ({{16'hffff},cuif.instr[15:0]} << 2) + pc4;//16{1'b1}
    //end
    //else begin
      //BranchAddr = ({{16'h0000},cuif.instr[15:0]} << 2) + pc4;//16{1'b0}
    //end
  end
  else begin
    BranchAddr = pc4;
  end
end
assign JumpAddr = {pc4[31:28],dpif.imemload[25:0],2'b00};

//PC_NXT VALUE UPDATE
always_comb begin
  if(cuif.bne) begin
    Zero = ~aluif.zero;
  end
  else begin
    Zero = aluif.zero;
  end
end

always_comb begin
  if(cuif.branch & Zero) begin
    pc_nxt = BranchAddr;
  end
  else if(cuif.jal) begin//jal
    pc_nxt = JumpAddr;
  end
  else if(cuif.jump) begin//j
    pc_nxt = JumpAddr;
  end
  else if(cuif.jr) begin
    pc_nxt = rfif.rdat1;
  end  
  else begin
    pc_nxt = pc4;
  end
end

//ALU - CHECK PORTB?
assign aluif.porta = rfif.rdat1;
always_comb begin //only two values for alusrc?
//DO I NEED LUI???//
  //if andi, ori, xori then zero extend
  //But andi, ori, and xori ALUSrc is 1 as well
  if(cuif.aox) begin//NEED TO IMPLEMENT IN CONTROL UNIT
    aluif.portb = extendZeroImm;
  end
  //if sll or srl then shamt
  //if shamt is used then add these signals to control_unit and control_unit_if
  /*else if(cuif.SLL | cuif.SRL) begin//NEED TO IMPLEMENT IN CONTROL UNIT
    aluif.portb = shamt;
  end*/
  else if(cuif.AluSrc == 1) begin//CHECK THIS
    if(cuif.instr[15] == 1) begin
      aluif.portb = {16'hffff,cuif.instr[15:0]};
    end
    else begin
      aluif.portb = {16'h0000,cuif.instr[15:0]};
    end
  end
  else //if(cuif.AluSrc == 0) begin//COULD BE THE ELSE/BASE CASE
    aluif.portb = rfif.rdat2;
  //end
  /*else begin//CHECK THIS
    aluif.portb = shamt;
  end*/
end
assign aluif.ALUOP = cuif.aluop;

r_t instrout;
assign instrout = r_t'(dpif.imemload);
endmodule
