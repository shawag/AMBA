module APB_SLAVE(
    input           PCLK    ,
    input           RST_N   ,
    input  [3:0]    PADDR   ,
    input           PWRITE  ,
    input           PSEL    ,
    input           PENABLE ,
    input  [15:0]   PWDATA  ,
    output [15:0]   PRDATA                                                                   
);

reg [15:0]  R_PRDATA;

assign PRDATA = R_PRDATA;

localparam  IDLE = 4'b0001;
localparam  SETUP = 4'b0010;
localparam  WPHASE = 4'b0100;
localparam  RPHASE = 4'b1000;

reg [3:0]   state;
reg [3:0]   state_nxt;


reg [15:0] ram [0:15];

always @(posedge PCLK or negedge RST_N) begin
    if(~RST_N)
        state <= IDLE;
    else
        state <= state_nxt;
end

always @(*) begin
    state_nxt = state;
    case (state)
        IDLE: begin
            if(PSEL)
                state_nxt = SETUP;
        end
        SETUP: begin
            if(PWRITE)
                state_nxt = PWDATA;
            else
                state_nxt = PRDATA;
        end
        WPHASE: begin
            if(PENABLE)
                state_nxt = IDLE;
        end
        RPHASE: begin
            if(PENABLE)
                state_nxt = IDLE;
        end
        default :
            state_nxt = IDLE;
    endcase
end

always @(posedge PCLK or negedge RST_N) begin
    if(~RST_N) begin
        ram[0] <= {16{1'b0}};
        ram[1] <= {16{1'b0}};
        ram[2] <= {16{1'b0}};
        ram[3] <= {16{1'b0}};
        ram[4] <= {16{1'b0}};
        ram[5] <= {16{1'b0}};
        ram[6] <= {16{1'b0}};
        ram[7] <= {16{1'b0}};
        ram[8] <= {16{1'b0}};
        ram[9] <= {16{1'b0}};
        ram[10] <= {16{1'b0}};
        ram[11] <= {16{1'b0}};
        ram[12] <= {16{1'b0}};
        ram[13] <= {16{1'b0}};
        ram[14] <= {16{1'b0}};
        ram[15] <= {16{1'b0}};
    end
    else if(state == WPHASE && PENABLE)
        ram[PADDR] <= PWDATA;
    else
        ram <= ram;
end

always @(posedge PCLK or negedge RST_N) begin
    if(~RST_N)
        R_PRDATA <= {16{1'b0}};
    else if(state==RPHASE && PENABLE)
        R_PRDATA <= ram[PADDR]
    else
        R_PRDATA <= R_PRDATA;
end


endmodule