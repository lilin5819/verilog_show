module rptr_empty #(
    parameter ADDRSIZE = 4
    )(
    output     [ADDRSIZE-1:0] raddr,
    output reg [ADDRSIZE:0]   rptr,
    output reg                rempty,
    input      [ADDRSIZE:0]   rwptr2,
    input                     rinc, rclk, rrst_n
    );

reg [ADDRSIZE:0] rbin, rgnext, rbnext;

// Grey code pointer
always @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n) begin
        rptr <= 0;
        rbin <= 0;
    end
    else begin
        rptr <= rgnext;
        rbin <= rbnext;
    end
end

always @(*) begin
    rbnext = (!rempty)? (rbin + rinc) : rbin;
    rgnext = (rbnext>>1)^rbnext; // binary to gray
end

// Memory read-address pointer
assign raddr = rbin[ADDRSIZE-1:0];

// FIFO empty on reset or when the next rptr == synchronized wptr
always @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n) rempty <= 1'b1;
    else rempty <= (rgnext == rwptr2);
end

endmodule