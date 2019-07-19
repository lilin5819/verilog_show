module sync_w2r #(
    parameter ADDRSIZE = 4
    )(
    output reg [ADDRSIZE:0] rwptr2,
    input      [ADDRSIZE:0] wptr,
    input                   rclk, rrst_n
    );

reg [ADDRSIZE:0] rwptr1;

always @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n) begin
        {rwptr2, rwptr1} <= 0;
    end
    else begin
        {rwptr2, rwptr1} <= {rwptr1, wptr};
    end
end

endmodule