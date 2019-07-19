`define ROT0  16'h3244          // up 14
`define ROT1  16'h1DAC
`define ROT2  16'h0FAE
`define ROT3  16'h07F5
`define ROT4  16'h03FF
`define ROT5  16'h0200
`define ROT6  16'h0100
`define ROT7  16'h0080
`define ROT8  16'h0040
`define ROT9  16'h0020
`define ROT10 16'h0010
`define ROT11 16'h0008
`define ROT12 16'h0004
`define ROT13 16'h0002
`define ROT14 16'h0001
// `define ROT15 16'h0000
`define K_UP14     16'h26DD                    
`define K_UP15     16'h4DBA                    
`define K_UP16     16'h9B75       

// pipeline mode cordic
// author : lilin
// email  : 1657301947@qq.com

module cordic_pipeline_top(
    input clk,
    input rst_n,
    input en,
    input mode,
    input [15:0] xi,
    input [15:0] yi,
    input [15:0] zi,

    output [15:0] xo,
    output [15:0] yo,
    output [15:0] zo,
    output valid
);

wire [15:0] x[15:0],y[15:0],z[15:0];
reg [15:0] valid_r;
assign x[0] = xi;
assign y[0] = yi;
assign z[0] = zi;
assign valid = valid_r[14];

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        valid_r <= 16'b0;
    else
        valid_r <= {valid_r,en};
end

cordic_iter_16bit cordic_rotator_16bit_00(
    .clk(clk),
    .rst_n(rst_n),
    .mode(mode),
    .rot_z(`ROT0),
    .rot_num(4'd0),
    .xi(x[0]),
    .yi(y[0]),
    .zi(z[0]),
    .xo(x[1]),
    .yo(y[1]),
    .zo(z[1])
);
cordic_iter_16bit cordic_rotator_16bit_01(
    .clk(clk),
    .rst_n(rst_n),
    .mode(mode),
    .rot_z(`ROT1),
    .rot_num(4'd1),
    .xi(x[1]),
    .yi(y[1]),
    .zi(z[1]),
    .xo(x[2]),
    .yo(y[2]),
    .zo(z[2])
);
cordic_iter_16bit cordic_rotator_16bit_02(
    .clk(clk),
    .rst_n(rst_n),
    .mode(mode),
    .rot_z(`ROT2),
    .rot_num(4'd2),
    .xi(x[2]),
    .yi(y[2]),
    .zi(z[2]),
    .xo(x[3]),
    .yo(y[3]),
    .zo(z[3])
);
cordic_iter_16bit cordic_rotator_16bit_03(
    .clk(clk),
    .rst_n(rst_n),
    .mode(mode),
    .rot_z(`ROT3),
    .rot_num(4'd3),
    .xi(x[3]),
    .yi(y[3]),
    .zi(z[3]),
    .xo(x[4]),
    .yo(y[4]),
    .zo(z[4])
);
cordic_iter_16bit cordic_rotator_16bit_04(
    .clk(clk),
    .rst_n(rst_n),
    .mode(mode),
    .rot_z(`ROT4),
    .rot_num(4'd4),
    .xi(x[4]),
    .yi(y[4]),
    .zi(z[4]),
    .xo(x[5]),
    .yo(y[5]),
    .zo(z[5])
);
cordic_iter_16bit cordic_rotator_16bit_05(
    .clk(clk),
    .rst_n(rst_n),
    .mode(mode),
    .rot_z(`ROT5),
    .rot_num(4'd5),
    .xi(x[5]),
    .yi(y[5]),
    .zi(z[5]),
    .xo(x[6]),
    .yo(y[6]),
    .zo(z[6])
);
cordic_iter_16bit cordic_rotator_16bit_06(
    .clk(clk),
    .rst_n(rst_n),
    .mode(mode),
    .rot_z(`ROT6),
    .rot_num(4'd6),
    .xi(x[6]),
    .yi(y[6]),
    .zi(z[6]),
    .xo(x[7]),
    .yo(y[7]),
    .zo(z[7])
);
cordic_iter_16bit cordic_rotator_16bit_07(
    .clk(clk),
    .rst_n(rst_n),
    .mode(mode),
    .rot_z(`ROT7),
    .rot_num(4'd7),
    .xi(x[7]),
    .yi(y[7]),
    .zi(z[7]),
    .xo(x[8]),
    .yo(y[8]),
    .zo(z[8])
);
cordic_iter_16bit cordic_rotator_16bit_08(
    .clk(clk),
    .rst_n(rst_n),
    .mode(mode),
    .rot_z(`ROT8),
    .rot_num(4'd8),
    .xi(x[8]),
    .yi(y[8]),
    .zi(z[8]),
    .xo(x[9]),
    .yo(y[9]),
    .zo(z[9])
);
cordic_iter_16bit cordic_rotator_16bit_09(
    .clk(clk),
    .rst_n(rst_n),
    .mode(mode),
    .rot_z(`ROT9),
    .rot_num(4'd9),
    .xi(x[9]),
    .yi(y[9]),
    .zi(z[9]),
    .xo(x[10]),
    .yo(y[10]),
    .zo(z[10])
);
cordic_iter_16bit cordic_rotator_16bit_10(
    .clk(clk),
    .rst_n(rst_n),
    .mode(mode),
    .rot_z(`ROT10),
    .rot_num(4'd10),
    .xi(x[10]),
    .yi(y[10]),
    .zi(z[10]),
    .xo(x[11]),
    .yo(y[11]),
    .zo(z[11])
);
cordic_iter_16bit cordic_rotator_16bit_11(
    .clk(clk),
    .rst_n(rst_n),
    .mode(mode),
    .rot_z(`ROT11),
    .rot_num(4'd11),
    .xi(x[11]),
    .yi(y[11]),
    .zi(z[11]),
    .xo(x[12]),
    .yo(y[12]),
    .zo(z[12])
);
cordic_iter_16bit cordic_rotator_16bit_12(
    .clk(clk),
    .rst_n(rst_n),
    .mode(mode),
    .rot_z(`ROT12),
    .rot_num(4'd12),
    .xi(x[12]),
    .yi(y[12]),
    .zi(z[12]),
    .xo(x[13]),
    .yo(y[13]),
    .zo(z[13])
);
cordic_iter_16bit cordic_rotator_16bit_13(
    .clk(clk),
    .rst_n(rst_n),
    .mode(mode),
    .rot_z(`ROT13),
    .rot_num(4'd13),
    .xi(x[13]),
    .yi(y[13]),
    .zi(z[13]),
    .xo(x[14]),
    .yo(y[14]),
    .zo(z[14])
);
cordic_iter_16bit cordic_rotator_16bit_14(
    .clk(clk),
    .rst_n(rst_n),
    .mode(mode),
    .rot_z(`ROT14),
    .rot_num(4'd14),
    .xi(x[14]),
    .yi(y[14]),
    .zi(z[14]),
    .xo(x[15]),
    .yo(y[15]),
    .zo(z[15])
);

assign xo = x[15];
assign yo = y[15];
assign zo = z[15];


endmodule // cordic_top