`timescale 1ns / 1ps

module ExceptionUnit(
    input clk, rst,
    input csr_rw_in,                  //判断当前指令是否为CSR类
    input[1:0] csr_wsc_mode_in,       //标记CSR指令的种类
    input csr_w_imm_mux,              //判断参与运算的操作数是立即数还是cpu寄存器内容
    input[11:0] csr_rw_addr_in,       //表示CSR指令中涉及的CSR寄存器的地址
    input[31:0] csr_w_data_reg,       //假设操作数是寄存器，表示寄存器的内容
    input[4:0] csr_w_data_imm,        //假设操作数是立即数，表示立即数
    output[31:0] csr_r_data_out,      //表示CSR指令需要存入rd的内容

    input interrupt,                  //表示外设是否产生中断请求
    input illegal_inst,               //指令是否为非法指令
    input l_access_fault,             //读内存地址错误
    input s_access_fault,             //写内存地址错误
    input ecall_m,                    //该指令是否为ECALL

    input mret,                       //该指令是否为MRET

    input[31:0] epc_cur,              //出现异常时，导致异常的指令
    input[31:0] epc_next,             //导致异常指令结束后执行的指令
    output[31:0] PC_redirect,         //重定向的地址
    output redirect_mux,              //是否需要重定向

    output reg_FD_flush, reg_DE_flush, reg_EM_flush, reg_MW_flush, 
    output RegWrite_cancel            //是否需要取消写寄存器
);

    reg[11:0] csr_raddr, csr_waddr;
    reg[31:0] csr_wdata;
    reg csr_w;
    reg[1:0] csr_wsc;

    wire[31:0] mstatus;

    reg[1:0] state = 2'd0;
    reg[1:0] next_state = 2'd0;
    reg[31:0] EPC;
    reg[31:0] CAUSE;

    parameter MSTATUS = 12'h300;
    parameter MTVEC   = 12'h305;
    parameter MEPC    = 12'h341;
    parameter MCAUSE  = 12'h342;
    parameter MTVAL   = 12'h343;
    parameter MIE     = 12'h304;

    parameter STATE_IDEL = 2'd0;
    parameter STATE_MEPC = 2'd1;
    parameter STATE_MCAUSE = 2'd2;
    
    wire exception, trap_in;

    assign reg_FD_flush = (state == STATE_IDEL) & (trap_in | mret) | state == STATE_MEPC;
    assign reg_DE_flush = (state == STATE_IDEL) & (trap_in | mret);
    assign reg_EM_flush = (state == STATE_IDEL) & (trap_in | mret);
    assign reg_MW_flush = (state == STATE_IDEL) & trap_in;

    assign exception = illegal_inst | l_access_fault | s_access_fault | ecall_m;
    assign trap_in = exception | interrupt;

    assign PC_redirect = csr_r_data_out;
    assign redirect_mux = (state == STATE_IDEL & mret) | (state == STATE_MEPC);

    assign RegWrite_cancel = state == STATE_IDEL & exception;

    always @* begin
        case(state)
        STATE_IDEL:begin
            if (trap_in) begin
                csr_w <=1;
                csr_wsc <= 2'd1;
                csr_waddr <= MSTATUS;
                csr_wdata <= {mstatus[31:8], mstatus[3], mstatus[6:4], 1'b0, mstatus[2:0]};

                EPC <= exception ? epc_cur : epc_next;
                CAUSE <= interrupt ? {1'd1, 31'd0} : (illegal_inst ? 32'd2 : (l_access_fault ? 32'd5 : (s_access_fault ? 32'd7 : (ecall_m ? 32'd11 : 32'd0))));

                next_state <= STATE_MEPC;
            end
            else if (mret) begin
                csr_w <=1;
                csr_wsc <= 2'd1;
                csr_raddr <= MEPC;
                csr_waddr <= MSTATUS;
                csr_wdata <= {mstatus[31:8], 1'b0, mstatus[6:4], mstatus[7], mstatus[2:0]};

                next_state <= STATE_IDEL;
            end
            else if (csr_rw_in) begin
                csr_w <= 1;
                csr_wsc <= csr_wsc_mode_in;
                csr_raddr <= csr_rw_addr_in;
                csr_waddr <= csr_rw_addr_in;
                csr_wdata <= csr_w_imm_mux ? {{27'd0},csr_w_data_imm} : csr_w_data_reg;

                next_state <= STATE_IDEL;
            end
            else begin
                csr_w <= 0;

                next_state <= STATE_IDEL;
            end
        end
        STATE_MEPC:begin
            csr_w <= 1;
            csr_wsc <= 2'd1;
            csr_raddr <= MTVEC;
            csr_waddr <= MEPC;
            csr_wdata <= EPC;

            next_state <= STATE_MCAUSE;
        end
        STATE_MCAUSE:begin
            csr_w <= 1;
            csr_wsc <= 2'd1;
            csr_waddr <= MCAUSE;
            csr_wdata <= CAUSE;
            
            next_state <= STATE_IDEL;
        end
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= STATE_IDEL;
        end
        else begin
            state <= next_state;
        end
    end

    CSRRegs csr(.clk(clk),.rst(rst),.csr_w(csr_w),.raddr(csr_raddr),.waddr(csr_waddr),
        .wdata(csr_wdata),.rdata(csr_r_data_out),.mstatus(mstatus),.csr_wsc_mode(csr_wsc));

endmodule