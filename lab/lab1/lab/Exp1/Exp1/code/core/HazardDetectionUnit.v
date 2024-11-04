`timescale 1ps/1ps

module HazardDetectionUnit(
    input clk,
    input Branch_ID, rs1use_ID, rs2use_ID,
    input[1:0] hazard_optype_ID,
    input[4:0] rd_EXE, rd_MEM, rs1_ID, rs2_ID, rs2_EXE,
    output PC_EN_IF, reg_FD_EN, reg_FD_stall, reg_FD_flush,
        reg_DE_EN, reg_DE_flush, reg_EM_EN, reg_EM_flush, reg_MW_EN,
    output forward_ctrl_ls,
    output[1:0] forward_ctrl_A, forward_ctrl_B
);
    //according to the diagram, design the Hazard Detection Unit

    //activate registers
    assign reg_FD_EN = 1'b1;
    assign reg_DE_EN = 1'b1;
    assign reg_EM_EN = 1'b1;
    assign reg_MW_EN = 1'b1;

    //hazard operation type transfer
    reg[1:0] hazard_optype_EXE, hazard_optype_MEM;
    always@(posedge clk)begin
        hazard_optype_MEM <= hazard_optype_EXE;
        hazard_optype_EXE <= hazard_optype_ID & {2{~reg_DE_flush}};     //there is no data hazard in EXE stage if DE flush is active
    end

    //forward and stall control logic
    localparam hazard_optype_ALU   = 2'b01;
    localparam hazard_optype_LOAD  = 2'b10;
    localparam hazard_optype_STORE = 2'b11;

    wire rs1_stall = rs1use_ID && rs1_ID && (rs1_ID == rd_EXE) && (hazard_optype_EXE == hazard_optype_LOAD);//rs2 of store instruction is only used in MEM stage, but rs1 is used in EXE stage
    wire rs2_stall = rs2use_ID && rs2_ID && (rs2_ID == rd_EXE) && (hazard_optype_EXE == hazard_optype_LOAD) && (hazard_optype_ID != hazard_optype_STORE);

    wire rs1_forward_from_EXE = rs1use_ID && rs1_ID && (rs1_ID == rd_EXE) && (hazard_optype_EXE == hazard_optype_ALU);
    wire rs2_forward_from_EXE = rs2use_ID && rs2_ID && (rs2_ID == rd_EXE) && (hazard_optype_EXE == hazard_optype_ALU);

    wire rs1_forward_from_MEM_ALU = (~rs1_forward_from_EXE) && rs1use_ID && rs1_ID && (rs1_ID == rd_MEM) && (hazard_optype_MEM == hazard_optype_ALU);// if EXE stage is not hazardous, then rs1 can be forwarded from MEM stage
    wire rs2_forward_from_MEM_ALU = (~rs2_forward_from_EXE) && rs2use_ID && rs2_ID && (rs2_ID == rd_MEM) && (hazard_optype_MEM == hazard_optype_ALU);

    wire rs1_forward_from_MEM_LOAD = rs1use_ID && rs1_ID && (rs1_ID == rd_MEM) && (hazard_optype_MEM == hazard_optype_LOAD);// forward loaded data from MEM stage to ID stage
    wire rs2_forward_from_MEM_LOAD = rs2use_ID && rs2_ID && (rs2_ID == rd_MEM) && (hazard_optype_MEM == hazard_optype_LOAD);

    wire rs2_EXE_forward_from_MEM = rs2_EXE && (rs2_EXE == rd_MEM) && (hazard_optype_MEM == hazard_optype_LOAD) && (hazard_optype_EXE == hazard_optype_STORE);

    wire stall = rs1_stall | rs2_stall;

    assign PC_EN_IF = ~stall;
    assign reg_FD_stall = stall;
    assign reg_FD_flush = Branch_ID;
    assign reg_DE_flush = stall;

    assign forward_ctrl_A = {2{rs1_forward_from_EXE}}      & 2'b01 |
                            {2{rs1_forward_from_MEM_ALU}}  & 2'b10 |
                            {2{rs1_forward_from_MEM_LOAD}} & 2'b11 ;
    assign forward_ctrl_B = {2{rs2_forward_from_EXE}}      & 2'b01 |
                            {2{rs2_forward_from_MEM_ALU}}  & 2'b10 |
                            {2{rs2_forward_from_MEM_LOAD}} & 2'b11 ;
    assign forward_ctrl_ls = rs2_EXE_forward_from_MEM;

endmodule