// `timescale 1ns/10ps
`define LOW_CLK_CNT 16'd249  

module i2c_master_tb;
reg clk;
reg rst_n;
reg en;
reg [15:0] dat_addr;
reg [7:0] tx_byte;
wire [7:0] rx_byte;
wire tx_ready,rx_ready;
reg read_mode;
wire SCL;
wire SDA;
reg [7:0] tx_len,rx_len;


clk_div clk_div_i2c(
    .clk(clk),
    .rst_n(rst_n),
    .en(1'b1),
    .cnt(`LOW_CLK_CNT),
    .clk_o(clk_i2c)
);

i2c_master i2c_master(
    .clk(clk_i2c),
    .rst_n(rst_n),
    .en(en),
    .read_mode(read_mode),
    .dev_addr(3'b001),
    .dat_addr(dat_addr),
    .tx_len(tx_len),          //trans tx_len
    .rx_len(rx_len),          //trans rx_len
    .tx_byte(tx_byte),
    .rx_byte(rx_byte),
    .tx_ready(tx_ready),
    .rx_ready(rx_ready),
    .SCL(SCL),
    .SDA(SDA)
);

M24LC64 i2c_dev(
    .A0(1'b1), 
    .A1(1'b0), 
    .A2(1'b0), 
    .WP(1'b0), 
    .SDA(SDA), 
    .SCL(SCL), 
    .RESET(~rst_n)
);

localparam CLK_PERIOD = 20;
always #(CLK_PERIOD/2) clk=~clk;

// always @(posedge tx_ready) tx_byte = $random %255;

initial begin
    #1 rst_n<=1'bx;clk<=1'bx;
    tx_byte = 8'h81;
    // sda_oe = 1'b0;
    dat_addr = 16'h0000;
    tx_byte = 16'h00;
    tx_len = 8'd31;
    rx_len = 8'd0;
    read_mode = 0;
    en = 0;
    #(CLK_PERIOD*3) rst_n<=1;
    #(CLK_PERIOD*3) rst_n<=0;clk<=0;
    repeat(5) @(posedge clk);
    rst_n<=1;
    @(posedge clk);
    repeat(2) @(posedge clk);
    en = 1;
    repeat(31)begin
        @(negedge tx_ready)
        tx_byte = tx_byte + 1;
    end
    tx_len = 0;
    en = 0;
    #10000
    en = 1;
    read_mode = 1;
    rx_len = 8'd40;
    #10000000
    en = 0;
    #1000;
    $finish(2);
end

endmodule