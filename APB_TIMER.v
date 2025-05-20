`timescale 1ns/1ns
module APB_TIMER(
    input           pclk,
    input           pclkg,
    input           presetn,

    input           psel,
    input   [11:2]  paddr,
    input           penable,
    input           pwrite,
    input   [31:0]  pwdata,

    input   [3:0]   ecorevnum,

    output  [31:0]  prdata,
    output          pready,
    output          pslveer,

    input           extin,
    output          timerint
);

localparam      APB_TIMER_PID0 = 8'h22;
localparam      APB_TIMER_PID1 = 8'hB8;
localparam      APB_TIMER_PID2 = 8'h1B;
localparam      APB_TIMER_PID3 = 4'h0;
localparam      APB_TIMER_PID4 = 8'h04;
localparam      APB_TIMER_PID5 = 8'h00;
localparam      APB_TIMER_PID6 = 8'h00;
localparam      APB_TIMER_PID7 = 8'h00;
localparam      APB_TIMER_CID0 = 8'h0D;
localparam      APB_TIMER_CID1 = 8'hF0;
localparam      APB_TIMER_CID2 = 8'h05;
localparam      APB_TIMER_CID3 = 8'hB1;

wire        read_enable;
wire        write_enable;
wire        write_enable00;
wire        write_enable04;
wire        write_enable08;
wire        write_enable0c;

reg     [7:0]   read_mux_byte0;
reg     [7:0]   read_mux_byte0_reg;
reg     [31:0]  read_mux_word;
wire    [3:0]   pid3_value;

reg     [3:0]   reg_ctrl;
reg     [31:0]  reg_curr_val;
reg     [31:0]  reg_reload_val;
reg     [31:0]  nxt_curr_val;

reg             ext_in_sync1;
reg             ext_in_sync2;
reg             ext_in_delay;
wire            ext_in_enable;
wire            dec_ctrl;
wire            clk_ctrl;
wire            enable_ctrl;
wire            edge_detect;
reg             reg_timer_int;
wire            timer_int_clear;
wire            timer_int_set;
wire            update_timer_int;


assign  read_enable = psel & (~pwrite);
assign  write_enable = psel & pwrite & (~penable);
assign  write_enable00 = write_enable & (paddr[11:2] == 10'h00);
assign  write_enable04 = write_enable & (paddr[11:2] == 10'h01);
assign  write_enable08 = write_enable & (paddr[11:2] == 10'h02);
assign  write_enable0c = write_enable & (paddr[11:2] == 10'h03);


always @(posedge pclkg or negedge presetn) begin
    if(~presetn)
        reg_ctrl <= {4{1'b0}};
    else if(write_enable00)
        reg_ctrl <= pwdata[3:0];
end

always @(posedge pclk or negedge presetn) begin
    if(~presetn)
        reg_curr_val <= {32{1'b0}};
    else if(write_enable04 | dec_ctrl)
        reg_curr_val <= nxt_curr_val;
end

always @(posedge pclkg or negedge presetn) begin
    if(~presetn)
        reg_reload_val <= {32{1'b0}};
    else if(write_enable08)
        reg_reload_val <= pwdata[31:0];
end

assign pid3_value = APB_TIMER_PID3;


always @(*) begin
    if(paddr[11:4] == 8'h00) begin
        case (paddr[3:2])
        2'h0: read_mux_byte0 = {{4{1'b0}, reg_ctrl}};
        2'h1: read_mux_byte0 = {8{1'b0}};
        2'h2: read_mux_byte0 = reg_reload_val[7:0];
        2'h3: read_mux_byte0 = {{7{1'b0}}, reg_timer_int};
        default: read_mux_byte0 = {8{1'bx}};
        endcase
    end
    else if(paddr[11:6] == 6'h3F) begin
        case(paddr[5:2])
        4'h0,4'h1,4'h2,4'h3: read_mux_byte0 = {8{1'b0}};
        4'h4: read_mux_byte0 = APB_TIMER_PID4;
        4'h5: read_mux_byte0 = APB_TIMER_PID5;
        4'h6: read_mux_byte0 = APB_TIMER_PID6;
        4'h7: read_mux_byte0 = APB_TIMER_PID7;
        4'h8: read_mux_byte0 = APB_TIMER_PID0;
        4'h9: read_mux_byte0 = APB_TIMER_PID1;
        4'hA: read_mux_byte0 = APB_TIMER_PID2;
        4'hB: read_mux_byte0 = {ecorevnum[3:0],pid3_value[3:0]};
        4'hC: read_mux_byte0 = APB_TIMER_CID0;
        4'hC: read_mux_byte0 = APB_TIMER_CID1;
        4'hD: read_mux_byte0 = APB_TIMER_CID2;
        4'hF: read_mux_byte0 = APB_TIMER_CID3;
        default: read_mux_byte0 = {8{1'bx}};
        endcase
    end
    else begin
        read_mux_byte0 = {8{1'b0}};
    end
end

always @(posedge pclkg or negedge presetn) begin
    if(~presetn)
        read_mux_byte0_reg <= {8{1'b0}};
    else if(read_enable)
        read_mux_byte0_reg <= read_mux_byte0;
end

always @(*) begin
    if(paddr[11:4] == 8'h00) begin
        case(paddr[3:2])
        2'b01: read_mux_word = {reg_curr_val[31:0]};
        2'b10: read_mux_word = {reg_reload_val[31:8], read_mux_byte0_reg};
        2'b00,2'b11: read_mux_word = {{24{1'b0}, read_mux_byte0_reg}};
        default: read_mux_word = {32{1'bx}};
        endcase
    end
    else begin
        read_mux_word = {{24{1'b0}}, read_mux_byte0_reg};
    end
end

assign prdata = (read_enable) ? read_mux_word : {32{1'b0}};
assign pready = 1'b1;
assign pslveer = 1'b0;

assign ext_in_enable = reg_ctrl[1] | reg_ctrl[2] | psel;


always @(posedge pclk or negedge presetn) begin
    if(~presetn) begin
        ext_in_sync1 <= 1'b0;
        ext_in_sync2 <= 1'b0;
        ext_in_delay <= 1'b0;
    end
    else if(ext_in_enable) begin
        ext_in_sync1 <= extin;
        ext_in_sync2 <= ext_in_sync1;
        ext_in_delay <= ext_in_sync2;
    end
end

assign edge_detect = ext_in_sync2 & (~ext_in_delay);

assign clk_ctrl = reg_ctrl[2] ? edge_detect : 1'b1;

assign enable_ctrl = reg_ctrl[1] ? ext_in_sync2 : 1'b1;

assign dec_ctrl = reg_ctrl[0] & enable_ctrl & clk_ctrl;

always @(*) begin
    if(write_enable04)
        nxt_curr_val = pwdata[31:0];
    else if(dec_ctrl) begin
        if(reg_curr_val == {32{1'b0}})
            nxt_curr_val = reg_reload_val;
        else
            nxt_curr_val = reg_curr_val - 1'b1;
    end
    else
        nxt_curr_val = reg_curr_val;
end

assign timer_int_set = (dec_ctrl & reg_ctrl[3] & (reg_curr_val==32'h00000001));
assign timer_int_clear = write_enable0c & pwdata[0];
assign update_timer_int = timer_int_set | timer_int_clearl

always @(posedge pclk or negedge presetn) begin
    if(~presetn)
        reg_timer_int <= 1'b0;
    else if(update_timer_int)
        reg_timer_int <= timer_int_set;
end

assign timerint = reg_timer_int;


endmodule