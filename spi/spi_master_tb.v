// `include "spi_master.v"

module spi_master_tb;
reg clk;
reg rst_n;
reg en;
reg [7:0] tx_byte;
wire [7:0] rx_byte;
wire tx_ready,rx_ready;
reg MISO;
wire SS,SCK,MOSI;

spi_master spi_master00(
    .clk(clk),
    .rst_n(rst_n),
    .en(en),
    .tx_byte(tx_byte),
    .rx_byte(rx_byte),
    .tx_ready(tx_ready),
    .rx_ready(rx_ready),
    .MISO(MISO),
    .SS(SS),
    .SCK(SCK),
    .MOSI(MOSI)
);

localparam CLK_PERIOD = 20;
always #(CLK_PERIOD/2) clk=~clk;

// always @(posedge ready) tx_byte = $random %255;
reg [16:0] data;
always @(negedge SCK) MISO = $random %2;

initial begin
    #1 rst_n<=1'bx;clk<=1'bx;
    tx_byte = 8'hf0;
    MISO = 0; 
    en = 0;
    #(CLK_PERIOD*3) rst_n<=1;
    #(CLK_PERIOD*3) rst_n<=0;clk<=0;
    repeat(5) @(posedge clk);
    rst_n<=1;
    @(posedge clk);
    repeat(2) @(posedge clk);
    en = 1;

    @(posedge tx_ready) tx_byte = $random %255; 
    @(negedge rx_ready) data = {data[7:0],rx_byte}; 
    // @(posedge tx_ready) tx_byte = $random %255; 
    en = 0;
    @(negedge rx_ready) data = {data[7:0],rx_byte}; 
    #1000;
    $finish(2);
end

endmodule