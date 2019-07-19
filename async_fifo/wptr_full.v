module wptr_full #(
    parameter ADDRSIZE = 4
    )(
    output     [ADDRSIZE-1:0] waddr,
    output reg [ADDRSIZE:0]   wptr,
    output reg                wfull,
    input      [ADDRSIZE:0]   wrptr2,
    input                     winc, wclk, wrst_n
    );

reg [ADDRSIZE:0] wbin, wgnext, wbnext;

// Grey code pointer
always @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n) begin
        wptr <= 0;
        wbin <= 0;
    end
    else begin
        wptr <= wgnext;
        wbin <= wbnext;
    end
end

always @(*) begin
    wbnext = (!wfull)? (wbin + winc) : wbin;
    wgnext = (wbnext>>1)^wbnext;
end

// Memory read-address pointer
assign waddr = wbin[ADDRSIZE-1:0];

// FIFO full generation
always @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n) wfull <= 1'b0;
    else wfull <= ((wgnext[ADDRSIZE]     != wrptr2[ADDRSIZE]  ) &&
                   (wgnext[ADDRSIZE-1]   != wrptr2[ADDRSIZE-1]) &&
                   (wgnext[ADDRSIZE-2:0] == wrptr2[ADDRSIZE-2:0]));
end

endmodule