// `define ROT0  16'h3244          // up 14
// `define ROT1  16'h1DAC
// `define ROT2  16'h0FAE
// `define ROT3  16'h07F5
// `define ROT4  16'h03FF
// `define ROT5  16'h0200
// `define ROT6  16'h0100
// `define ROT7  16'h0080
// `define ROT8  16'h0040
// `define ROT9  16'h0020
// `define ROT10 16'h0010
// `define ROT11 16'h0008
// `define ROT12 16'h0004
// `define ROT13 16'h0002
// `define ROT14 16'h0001
// // `define ROT15 16'h0000
// `define K_UP14     16'h26DD                    
// `define K_UP15     16'h4DBA                    
// `define K_UP16     16'h9B75   

// iter addr
// author : lilin
// email  : 1657301947@qq.com

`define MODE_SIN_COS 1'b0                     // theta ----> sin cos
`define MODE_ANG 1'b1                         // x,y   ----> atan
 
module cordic_iter_16bit(
    input clk,
    input rst_n,
    // input en,
    input mode,          // 0 calc sin cos, 1 calc angle z
    input signed [15:0] rot_z,
    input [3:0] rot_num,
    input signed [15:0] xi,
    input signed [15:0] yi,
    input signed [15:0] zi,
    output reg signed [15:0] xo,
    output reg signed [15:0] yo,
    output reg signed [15:0] zo
);

// reg [15:0] zrom [3:0];
wire signed [15:0] xs,ys;
assign xs = xi >>> rot_num;
assign ys = yi >>> rot_num;
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        xo <= 16'b0;                         
        yo <= 16'b0;
        zo <= 16'b0;
    end
    else if(mode == `MODE_SIN_COS) begin
        if(zi >= 0)   begin      // zi >= 0 减角度 顺时针旋转 
            xo <= xi - ys;
            yo <= yi + xs;
            zo <= zi - rot_z;
        end
        else   begin                  // zi < 0 加角度 逆时针旋转 
            xo <= xi + ys;
            yo <= yi - xs;
            zo <= zi + rot_z;
        end
    end
    else begin
        if(yi >= 0)   begin      // yi >= 0 加角度 逆时针旋转 
            xo <= xi + ys;
            yo <= yi - xs;
            zo <= zi + rot_z;
        end
        else   begin                  // yi < 0 减角度 顺时针旋转 
            xo <= xi - ys;
            yo <= yi + xs;
            zo <= zi - rot_z;
        end
    end

end

endmodule // cordic_cotator