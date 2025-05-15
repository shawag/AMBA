module APB4_SLAVE_INTERFACE#(
    parameter ADDRWIDTH = 12
)
(
    //IO declartion
    input       pclk,
    input       presetn,

    //apb input interface
    input                   psel,
    input   [ADDRWIDTH-1:0] paddr,
    input                   penable,
    input                   pwrite,
    input   [31:0]          pwdata,
    input   [3:0]           pstrb,

    //apb output interface

    output  [31:0]          prdata,
    output                  pready,
    output                  pslverr,

    //reg interface
    output  [ADDRWIDTH-1:0] addr,
    output                  read_en,
    output                  write_en,
    output  [3:0]           byte_strobe,
    output  [31:0]          wdata,
    input   [31:0]          rdata
);

assign  pready = 1'b1;
assign  pslverr = 1'b0;

assign  addr = paddr;
assign  read_en = psel & (~pwrite);
//if apb has write wait state, choose access phase to assert write_en may cause multicycle wen
assign  write_en = psel & pwrite & (~penable);

assign byte_strobe = pstrb;
assign wdata = pwdata;
assign prdata = rdata;

`ifdef SVA
    property always_ready;
        @(posedge pclk) disable iff (~presetn)
        pready == 1'b1;
    endproperty

    property always_error;
        @(posedge pclk) disable iff (~presetn)
        pslverr == 1'b0;
    endproperty

    property read_en_correct;
        @(posedge pclk) disable iff(~presetn)
        read_en == (psel & ~pwrite);
    endproperty

    property write_en_correct;
        @(posedge pclk) disable iff(~presetn)
        write_en == (psel & pwrite & ~penable);
    endproperty

    eve0: assert property(always_ready)
        else $error("At %0t, pready error!", $time);
    eve1: assert property(always_error)
        else $error("At %0t, pslveer error!", $time);
    eve2: assert property(read_en_correct)
        else $error("At %0t, read_en error!", $time);
    eve3: assert property(write_en_correct)
        else $error("At %0t, write_en error!", $time); 
`endif 
    
endmodule