module APB4_SLAVE_REG #(
    parameter   ADDRWIDTH = 12
)
(
    input                   pclk,
    input                   presetn,

    //reg interface
    input   [ADDRWIDTH-1:0] addr,
    input                   read_en,
    input                   write_en,
    input   [3:0]           byte_strobe,
    input   [31:0]          wdata,
    input   [3:0]           ecorevnum,
    output reg [31:0]       rdata     
);

localparam  SLAVE_REG_PID4 = 32'h00000004;
localparam  SLAVE_REG_PID5 = 32'h00000000;
localparam  SLAVE_REG_PID6 = 32'h00000000;
localparam  SLAVE_REG_PID7 = 32'h00000000;
localparam  SLAVE_REG_PID0 = 32'h00000019;
localparam  SLAVE_REG_PID1 = 32'h000000B8;
localparam  SLAVE_REG_PID2 = 32'h0000001B;
localparam  SLAVE_REG_PID3 = 32'h00000000;
localparam  SLAVE_REG_CID0 = 32'h0000000D;
localparam  SLAVE_REG_CID1 = 32'h000000F0;
localparam  SLAVE_REG_CID2 = 32'h00000005;
localparam  SLAVE_REG_CID3 = 32'h000000B1;

//internal signal
reg [31:0]      data0;
reg [31:0]      data1;
reg [31:0]      data2;
reg [31:0]      data3;
wire [3:0]      wr_sel;


assign wr_sel[0] = ((addr[(ADDRWIDTH-1):2]==10'b0000000000) & (write_en)) ? 1'b1 : 1'b0;
assign wr_sel[1] = ((addr[(ADDRWIDTH-1):2]==10'b0000000001) & (write_en)) ? 1'b1 : 1'b0;
assign wr_sel[2] = ((addr[(ADDRWIDTH-1):2]==10'b0000000010) & (write_en)) ? 1'b1 : 1'b0;
assign wr_sel[3] = ((addr[(ADDRWIDTH-1):2]==10'b0000000011) & (write_en)) ? 1'b1 : 1'b0;



always @(posedge pclk or negedge presetn) begin
    if(~presetn) begin
        data0  <= {32{1'b0}};
    end
    else if(wr_sel[0]) begin
        if(byte_strobe[0])
            data0[7:0]   <= wdata[7:0];
        if(byte_strobe[1])
            data0[15:8]  <= wdata[15:8];
        if(byte_strobe[2])
            data0[23:16] <= wdata[23:16];
        if(byte_strobe[3])
            data0[31:24] <= wdata[31:24];
    end
end

always @(posedge pclk or negedge presetn) begin
    if(~presetn) begin
        data1  <= {32{1'b0}};
    end
    else if(wr_sel[1]) begin
        if(byte_strobe[0])
            data1[7:0]   <= wdata[7:0];
        if(byte_strobe[1])
            data1[15:8]  <= wdata[15:8];
        if(byte_strobe[2])
            data1[23:16] <= wdata[23:16];
        if(byte_strobe[3])
            data1[31:24] <= wdata[31:24]; 
    end
end

always @(posedge pclk or negedge presetn) begin
    if(~presetn) begin
        data2  <= {32{1'b0}};
    end
    else if(wr_sel[2]) begin
        if(byte_strobe[0])
            data2[7:0]   <= wdata[7:0];
        if(byte_strobe[1])
            data2[15:8]  <= wdata[15:8];
        if(byte_strobe[2])
            data2[23:16] <= wdata[23:16];
        if(byte_strobe[3])
            data2[31:24] <= wdata[31:24]; 
    end
end

always @(posedge pclk or negedge presetn) begin
    if(~presetn) begin
        data3  <= {32{1'b0}};
    end
    else if(wr_sel[3]) begin
        if(byte_strobe[0])
            data3[7:0]   <= wdata[7:0];
        if(byte_strobe[1])
            data3[15:8]  <= wdata[15:8];
        if(byte_strobe[2])
            data3[23:16] <= wdata[23:16];
        if(byte_strobe[3])
            data3[31:24] <= wdata[31:24]; 
    end
end


    always @(*) begin
        case(read_en)
        1'b1: begin
            if(addr[11:4] == 8'h00) begin
                case(addr[3:2])
                    2'b00: rdata = data0;
                    2'b01: rdata = data1;
                    2'b10: rdata = data2;
                    2'b11: rdata = data3;
                    default: rdata = {32{1'bx}};
                endcase
            end
            else if(addr[11:6] == 6'h3F) begin
                case(addr[5:2])
                    4'b0100: rdata = SLAVE_REG_PID4;
                    4'b0101: rdata = SLAVE_REG_PID5;
                    4'b0110: rdata = SLAVE_REG_PID6;
                    4'b0111: rdata = SLAVE_REG_PID7;
                    4'b1000: rdata = SLAVE_REG_PID0;
                    4'b1001: rdata = SLAVE_REG_PID1;
                    4'b1010: rdata = SLAVE_REG_PID2;
                    4'b1011: rdata = {SLAVE_REG_PID3[31:8], ecorevnum};
                    4'b1100: rdata = SLAVE_REG_CID0;
                    4'b1101: rdata = SLAVE_REG_CID1;
                    4'b1110: rdata = SLAVE_REG_CID2;
                    4'b1111: rdata = SLAVE_REG_CID3;
                    4'b0000, 4'b0001, 4'b0010, 4'b0011: rdata = {32{1'b0}};
                    default: rdata = {32{1'bx}};
                endcase
            end
            else begin
                rdata = {32{1'b0}};
            end
        end
        1'b0: begin
            rdata = {32{1'b0}};
        end
        default: begin
            rdata = {32{1'bx}};
        end
        endcase
    end
endmodule