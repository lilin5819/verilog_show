module fifomem
#(
    parameter  DATASIZE = 8, // Memory data word width               
    parameter  ADDRSIZE = 4 
) // Number of mem address bits
(
    output [DATASIZE-1:0] rdata, 
    input  [DATASIZE-1:0] wdata, 
    input  [ADDRSIZE-1:0] waddr, raddr, 
    // input                 winc, wfull, wclk
    input                 wclk,wclken
);
 


localparam DEPTH = 1<<ADDRSIZE;   // 左移相当于乘法，2^4
reg [DATASIZE-1:0] mem [0:DEPTH-1]; //生成2^4个位宽位8的数组
assign rdata = mem[raddr];
always @(posedge wclk)  //当写使能有效且还未写满的时候将数据写入存储实体中，注意这里是与wclk同步的
    if (wclken)
        mem[waddr] <= wdata;
 
 endmodule