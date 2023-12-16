/*
Pranay Jaggi
9/27/23
forwarding_unit
Version 1.0
*/

`include "forwarding_unit_if.vh"
`include "cpu_types_pkg.vh"
module forwarding_unit(forwarding_unit_if.fu fuif);
  import cpu_types_pkg::*;

    logic EMIFA, MWIFA, EMIFB, MWIFB;
    logic [4:0] RegDst_EMIF, RegDst_MWIF; 
    //logic EMIFRegWrite;
    logic [31:0] dload_mwif;
    
  always_comb begin: FORWARDING_UNIT
    EMIFA = 0;
    MWIFA = 0;
    EMIFB = 0;
    MWIFB = 0;

    RegDst_EMIF = fuif.EMIFInst[20:16];
    if(fuif.RegDst_EMIF == 1) begin
        RegDst_EMIF = fuif.EMIFInst[15:11];
    end 

    RegDst_MWIF = fuif.MWIFInst[20:16];
    if(fuif.RegDst_MWIF == 1) begin
        RegDst_MWIF = fuif.MWIFInst[15:11];
    end 
    //R-TYPE//
        //if write from prev. instr to valid address        and destination register matches A of current instruction then forward A
    if(fuif.DEIFInst[31:26] == LUI && fuif.EMIFRegWrite == 1) begin
        EMIFB = 1;
    end
    //25:21 = RS//
    //20:16 = RT//
    //15:11 = RD//
    if(fuif.MWIFRegWrite && RegDst_MWIF) begin
        if(RegDst_MWIF == fuif.DEIFInst[25:21]) begin
            MWIFA = 1;
        end
        if(RegDst_MWIF == fuif.DEIFInst[20:16]) begin
            MWIFB = 1;
        end
    end
    if(fuif.EMIFRegWrite && RegDst_EMIF) begin
        if(RegDst_EMIF == fuif.DEIFInst[25:21]) begin
            EMIFA = 1;
        end
        if(RegDst_EMIF == fuif.DEIFInst[20:16]) begin
            EMIFB = 1;
        end
    end
  end
    always_comb begin: ALU_A
        fuif.ALU_A = fuif.rdat1;
        if(fuif.DEIFInst[25:21] == fuif.MWIFInst[20:16] && (fuif.MWIFInst[31:26] == LW || fuif.MWIFInst[31:26] == LL || fuif.MWIFInst[31:26] == SC)) begin
            fuif.ALU_A = fuif.dload_mwif;
        end
        else if(EMIFA) begin
            fuif.ALU_A = fuif.alu_result_emif;
        end
        else if(MWIFA) begin
            fuif.ALU_A = fuif.alu_result_mwif;
        end
    end

    always_comb begin: ALU_B
        fuif.ALU_B = fuif.rdat2;
        if(fuif.DEIFInst[20:16] == fuif.MWIFInst[20:16] && (fuif.MWIFInst[31:26] == LW || fuif.MWIFInst[31:26] == LL || fuif.MWIFInst[31:26] == SC)) begin
            fuif.ALU_B = fuif.dload_mwif;
        end
        else if(EMIFB) begin
            fuif.ALU_B = fuif.alu_result_emif;
        end
        else if(MWIFB) begin
            fuif.ALU_B = fuif.alu_result_mwif;
        end
    end

  r_t instroutDE;
  assign instroutDE = r_t'(fuif.DEIFInst);
  r_t instroutEM;
  assign instroutEM = r_t'(fuif.EMIFInst);
  r_t instroutMW;
  assign instroutMW = r_t'(fuif.MWIFInst);

  r_t instroutALU_A;
  assign instroutALU_A = r_t'(fuif.ALU_A);
  r_t instroutALU_B;
  assign instroutALU_B = r_t'(fuif.ALU_B);
endmodule

