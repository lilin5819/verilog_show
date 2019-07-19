module sync_r2w #(
    parameter ADDRSIZE = 4
    )(
    output reg [ADDRSIZE:0] wrptr2,
    input      [ADDRSIZE:0] rptr,
    input                   wclk, wrst_n
    );

reg [ADDRSIZE:0] wrptr1;

always @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n) begin
        {wrptr2, wrptr1} <= 0;
    end
    else begin
        {wrptr2, wrptr1} <= {wrptr1, rptr};
    end
end

endmodule