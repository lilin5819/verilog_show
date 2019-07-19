module async_fifo_top #(
    parameter DSIZE = 8,
    parameter ASIZE = 4
    )(
    output [DSIZE-1:0] rdata,
    output             wfull,
    output             rempty,
    input  [DSIZE-1:0] wdata,
    input              winc, wclk, wrst_n,
    input              rinc, rclk, rrst_n
    );

wire [ASIZE-1:0] waddr, raddr;
wire [ASIZE:0] wptr, rptr, wrptr2, rwptr2;
wire wclken;

assign wclken = (winc & !wfull);

sync_r2w #(ASIZE) U1(
    .wrptr2(wrptr2),
    .rptr(rptr),
    .wclk(wclk),
    .wrst_n(wrst_n)
    );

sync_w2r #(ASIZE) U2(
    .rwptr2(rwptr2),
    .wptr(wptr),
    .rclk(rclk),
    .rrst_n(rrst_n)
    );

fifomem #(DSIZE, ASIZE) U3(
    .rdata(rdata),
    .wdata(wdata),
    .waddr(waddr),
    .raddr(raddr),
    .wclk(wclk),
    .wclken(wclken)
    );

rptr_empty #(ASIZE) U4(
    .rempty(rempty),
    .raddr(raddr),
    .rptr(rptr),
    .rwptr2(rwptr2),
    .rinc(rinc),
    .rclk(rclk),
    .rrst_n(rrst_n)
    );

wptr_full #(ASIZE) U5(
    .wfull(wfull),
    .waddr(waddr),
    .wptr(wptr),
    .wrptr2(wrptr2),
    .winc(winc),
    .wclk(wclk),
    .wrst_n(wrst_n)
    );

endmodule