`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    21:34:44 03/12/2012
// Design Name:
// Module Name:    REGS EX/MEM Latch
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module   REG_EX_MEM(input clk,                                      //EX/MEM Latch
                    input rst,
                    input EN,                                       //娴佹按瀵勫瓨鍣ㄤ娇锟�?
                    input flush,                                    //寮傚父鏃舵竻闄ゅ紓甯告寚浠ゅ苟绛夊緟涓柇澶勭悊(淇濈暀)锟�?
                    input [31:0] IR_EX,                             //褰撳墠鎵ц鎸囦护(娴嬭瘯)
                    input [31:0] PCurrent_EX,                       //褰撳墠鎵ц鎸囦护瀛樺偍鍣ㄦ寚锟�?
                    input [31:0] ALUO_EX,                           //褰撳墠ALU鎵ц杈撳嚭锛氭湁鏁堝湴锟�?鎴朅LU鎿嶄綔
                    input [31:0] B_EX,                              //ID绾ц鍑哄瘎瀛樺櫒B鏁版嵁锛欳PU杈撳嚭鏁版嵁
                    input [4:0]  rd_EX,                             //浼狅拷?锟藉綋鍓嶆寚浠ゅ啓鐩殑瀵勫瓨鍣ㄥ湴锟�?
                    input DatatoReg_EX,                      //浼狅拷?锟藉綋鍓嶆寚浠EG鍐欐暟鎹拷?锟介亾閫夋嫨
                    input RegWrite_EX,                              //浼狅拷?锟藉綋鍓嶆寚浠ゅ瘎瀛樺櫒鍐欎俊锟�?
                    input WR_EX,                                    //浼狅拷?锟藉綋鍓嶆寚浠ゅ瓨鍌ㄥ櫒璇诲啓淇″彿
                    input[2:0] u_b_h_w_EX,
                    input MIO_EX,

                    output reg[31:0] PCurrent_MEM,                  //閿佸瓨浼狅拷?锟藉綋鍓嶆寚浠ゅ湴锟�?
                    output reg[31:0] IR_MEM,                        //閿佸瓨浼狅拷?锟藉綋鍓嶆寚锟�?(娴嬭瘯)
                    output reg[31:0] ALUO_MEM,                      //閿佸瓨ALU鎿嶄綔缁撴灉锛氭湁鏁堝湴锟�?鎴朅LU鎿嶄綔
                    output reg[31:0] Datao_MEM,                     //閿佸瓨浼狅拷?锟藉綋鍓嶆寚浠よ緭鍑篗IO鏁版嵁
                    output reg[4:0]  rd_MEM,                        //閿佸瓨浼狅拷?锟藉綋鍓嶆寚浠ゅ啓鐩殑瀵勫瓨鍣ㄥ湴锟�?
                    output reg       DatatoReg_MEM,                 //閿佸瓨浼狅拷?锟藉綋鍓嶆寚浠EG鍐欐暟鎹拷?锟介亾閫夋嫨
                    output reg       RegWrite_MEM,                  //閿佸瓨浼狅拷?锟藉綋鍓嶆寚浠ゅ瘎瀛樺櫒鍐欎俊锟�?
                    output reg       WR_MEM,                         //閿佸瓨浼狅拷?锟藉綋鍓嶆寚浠ゅ瓨鍌ㄥ櫒璇诲啓淇″彿
                    output reg[2:0]  u_b_h_w_MEM,
                    output reg       MIO_MEM
                );

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            IR_MEM       <= 0;
            PCurrent_MEM <= 0;
            rd_MEM       <= 0;
            RegWrite_MEM <= 0;
            WR_MEM       <= 0;
            MIO_MEM      <= 0;
        end
        else if(EN) begin                                      //EX绾ф甯镐紶杈撳埌MEM锟�?
                IR_MEM       <= IR_EX;
                PCurrent_MEM <= PCurrent_EX;                  //浼狅拷?锟介攣瀛樺綋鍓嶆寚浠ゅ湴锟�?
                ALUO_MEM     <= ALUO_EX;                      //閿佸瓨鏈夋晥鍦板潃鎴朅LU鎿嶄綔
                Datao_MEM    <= B_EX;                         //浼狅拷?锟介攣瀛楥PU杈撳嚭鏁版嵁
                DatatoReg_MEM <= DatatoReg_EX;                      //浼狅拷?锟介攣瀛楻EG鍐欐暟鎹拷?锟介亾閫夋嫨
                RegWrite_MEM  <= RegWrite_EX;                 //浼狅拷?锟介攣瀛樼洰鐨勫瘎瀛樺櫒鍐欎俊锟�?
                WR_MEM        <= WR_EX;                       //浼狅拷?锟介攣瀛樺瓨鍌ㄥ櫒璇诲啓淇″彿
                rd_MEM        <= rd_EX;                       //浼狅拷?锟介攣瀛樺啓鐩殑瀵勫瓨鍣ㄥ湴锟�?
                u_b_h_w_MEM   <= u_b_h_w_EX;
                MIO_MEM       <= MIO_EX;
        end
    end

endmodule