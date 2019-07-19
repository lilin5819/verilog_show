// author : lilin
// email  : 1657301947@qq.com

`define WR_MODE 0
`define RD_MODE 1
module i2c_master(
    input clk,
    input rst_n,

    input en,
    input read_mode,
    input [2:0] dev_addr,
    input [15:0] dat_addr,
    input [7:0] tx_len,          //trans tx_len
    input [7:0] rx_len,          //trans rx_len
    input [7:0] tx_byte,
    output reg [7:0] rx_byte,

    output reg tx_ready,
    output reg rx_ready,
    
    output SCL,
    inout SDA
);

reg [9:0] state,next_state;
reg sda_o,sda_oe;
reg [7:0] tx_buf,rx_buf;
reg scl;
wire sda_i;
reg trans_byte,master_ack,slave_ack;
reg cnt_en;
reg [7:0] cnt_max;
reg [7:0] cnt;
reg [7:0] rx_len_r,tx_len_r;
wire cnt_full,cnt_ack,cnt_byte;

assign cnt_full = (cnt==cnt_max);
assign cnt_ack = trans_byte&(cnt >= 4*8) && (cnt < 4*9);
assign cnt_byte = trans_byte&(cnt < 4*8);

assign SCL = scl;
assign SDA = sda_oe ? sda_o : 1'bz ;
assign sda_i = SDA;

localparam  ST_IDLE       = 10'b00_0000_0001,
            ST_WSTART     = 10'b00_0000_0010,
            ST_WCTL       = 10'b00_0000_0100,
            ST_ADDR0      = 10'b00_0000_1000,
            ST_ADDR1      = 10'b00_0001_0000,
            ST_RSTART     = 10'b00_0010_0000,
            ST_RCTL       = 10'b00_0100_0000,
            ST_WDAT       = 10'b00_1000_0000,
            ST_RDAT       = 10'b01_0000_0000,
            ST_STOP       = 10'b10_0000_0000;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        state <= ST_IDLE;
    else
        state <= next_state;
end

always @(*) begin
    if(cnt_full) begin
        case(state)
            ST_IDLE   :begin
                if(en)
                    next_state = ST_WSTART;
                else
                    next_state = ST_IDLE;
            end
            ST_WSTART  :begin
                next_state = ST_WCTL;
            end
            ST_WCTL    :begin
                if( slave_ack)
                    next_state = ST_ADDR0;
                else
                    next_state = ST_STOP;
            end
            ST_ADDR0   :begin
                if( slave_ack)
                    next_state = ST_ADDR1;
                else
                    next_state = ST_STOP;
            end
            ST_ADDR1   :begin
                if( slave_ack)
                    if(read_mode)
                        next_state = ST_RSTART;
                    else
                        next_state = ST_WDAT;
                else
                    next_state = ST_STOP;
            end
            ST_RSTART  :begin
                if( slave_ack)
                    next_state = ST_RCTL;
                else
                    next_state = ST_STOP;
            end
            ST_RCTL    :begin
                if( slave_ack)
                    next_state = ST_RDAT;
                else
                    next_state = ST_STOP;
            end
            ST_WDAT   :begin
                if( slave_ack && (tx_len_r > 0))
                    next_state = ST_WDAT;
                else
                    next_state = ST_STOP;
            end
            ST_RDAT   :begin
                if( master_ack)
                    next_state = ST_RDAT;
                else
                    next_state = ST_STOP;
            end
            ST_STOP   :begin
                next_state = ST_IDLE;
            end
            default:begin
                next_state = ST_IDLE;
            end
        endcase
    end
end
//cnt control     ,4 cnt a bit
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt_en <= 1'b0;
        trans_byte <= 1'b0;
        cnt_max <= 8'd0;
        cnt <= 8'd0;
    end
    else if(state != next_state)begin
        cnt <= 8'd0;
        case(next_state)
            ST_IDLE,ST_WSTART,ST_RSTART,ST_STOP:begin cnt_en <= 1'b1;trans_byte <= 1'b0; cnt_max <= 8'd3; end
            ST_WCTL,ST_ADDR0,ST_ADDR1,ST_WDAT,ST_RCTL,ST_RDAT: begin 
                cnt_en <= 1'b1;
                trans_byte <= 1'b1;
                cnt_max <= (4*9-1);
            end
            default: begin
                cnt_en <= 1'b1;
                trans_byte <= 1'b0;
                cnt_max <= 8'd3;
            end
        endcase
    end
    else if(cnt_full)
        cnt <= 8'd0;
    else
        cnt <= cnt + 1'b1;
end
//  tx 发送或 rx 接收缓存 
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        tx_buf <= 8'h0;
        rx_buf <= 8'h0;
    end
    else if(cnt_full) begin  // load rx_buf
        tx_buf <= tx_buf;
        rx_buf <= rx_buf;
        case(next_state)
            ST_IDLE,ST_STOP,ST_WSTART,ST_RSTART:begin
                // tx_buf <= 8'h0;
                // rx_buf <= 8'h0; 
            end
            ST_WCTL: begin
                tx_buf <= {4'b1010,dev_addr,1'b0}; 
            end
            ST_RCTL: begin 
                tx_buf <= {4'b1010,dev_addr,1'b1}; 
            end
            ST_ADDR0:begin
                tx_buf <= dat_addr[15:8]; 
            end
            ST_ADDR1:begin
                tx_buf <= dat_addr[7:0]; 
            end
            ST_WDAT: begin
                tx_buf <= tx_byte; 
            end
            ST_RDAT: begin
            end
            default: begin
                // tx_buf <= 8'h0;
                // rx_buf <= 8'h0;
            end
        endcase
    end
    else if(cnt[1:0] == 2'b00 && cnt_byte) begin        // shift bit per 4 cnt
        tx_buf <= tx_buf;
        rx_buf <= rx_buf;
        case(state)
            ST_IDLE,ST_STOP,ST_WSTART,ST_RSTART:begin
            end
            ST_WCTL,ST_RCTL,ST_ADDR0,ST_ADDR1,ST_WDAT: begin
                tx_buf <= tx_buf << 1; 
            end
            ST_RDAT: begin
                // rx_buf <= {rx_buf[6:0],sda_i};
            end
            default: begin
            end
        endcase
    end
    else if(cnt[1:0] == 2'b10 && state == ST_RDAT) begin
        tx_buf <= tx_buf;
        rx_buf <= {rx_buf[6:0],sda_i};
    end
    else begin
        tx_buf <= tx_buf;
        rx_buf <= rx_buf;
    end
end
// SDA  direction control
always @(*) begin
    case(state)
        ST_IDLE:begin sda_oe = 1'b0; end
        ST_WSTART,ST_RSTART:begin sda_oe = 1'b1; end
        ST_STOP : begin sda_oe = 1'b1; end
        ST_WCTL,ST_ADDR0,ST_ADDR1,ST_WDAT,ST_RCTL: begin 
            sda_oe = cnt_byte;
        end
        ST_RDAT: begin 
            sda_oe = !cnt_byte;
        end
        default: begin sda_oe = 1'b0; end
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sda_o <= 1'b1;
        scl <= 1'b1;
        master_ack <= 1'b0;
        slave_ack <= 1'b0;
        tx_len_r <= 8'd0;
        rx_len_r <= 8'd0;
    end
    else begin
        tx_ready <= 1'b0;
        rx_ready <= 1'b0;
        master_ack <= master_ack;
        slave_ack <= slave_ack;
        scl <= scl;
        case(state)
            ST_IDLE: begin
                sda_o <= 1'b1;
                scl <= 1'b1;
                master_ack <= 1'b0;
                slave_ack <= 1'b0;
                if(en) begin
                    tx_len_r <= tx_len + 1;
                    rx_len_r <= rx_len + 1;
                end
            end
            ST_WSTART:begin
                master_ack <= 1'b0;
                // slave_ack <= 1'b0;
                case(cnt[1:0])
                    2'b00: begin
                        sda_o <= 1'b1;
                        scl <= 1'b1;
                    end
                    2'b01:begin
                    end
                    2'b10:begin
                        sda_o <= 1'b0;
                    end
                    2'b11: begin
                        scl <= 1'b0;
                    end
                    default: begin
                    end
                endcase
            end
            ST_RSTART:begin
                master_ack <= 1'b1;
                case(cnt[1:0])
                    2'b00: begin
                        sda_o <= 1'b1;
                        scl <= 1'b0;
                    end
                    2'b01:begin
                        scl <= 1'b1;
                    end
                    2'b10:begin
                        sda_o <= 1'b0;
                    end
                    2'b11: begin
                        scl <= 1'b0;
                    end
                    default: begin
                    end
                endcase
            end
            ST_STOP:begin
                master_ack <= 1'b0;
                slave_ack <= 1'b0;
                case(cnt[1:0])
                    2'b00: begin
                        // sda_o <= 1'b0;
                        scl <= 1'b0;
                    end
                    2'b01:begin
                        scl <= 1'b1;
                    end
                    2'b10:begin
                        sda_o <= 1'b1;
                    end
                    2'b11: begin
                        scl <= 1'b1;
                    end
                    default: begin
                    end
                endcase
            end
            ST_WCTL,ST_RCTL,ST_ADDR0,ST_ADDR1:begin
                case(cnt[1:0])
                    2'b00: begin
                        scl <= 1'b0;
                        if(cnt_byte)
                            sda_o <= tx_buf[7];
                        else
                            sda_o <= 1'b0;
                    end
                    2'b01:begin
                        scl <= 1'b1;
                        if(cnt_ack) begin   // read ack
                            slave_ack <= ~sda_i;
                        end
                    end
                    2'b10:begin
                    end
                    2'b11: begin
                        scl <= 1'b0;
                    end
                endcase
            end
            ST_WDAT:begin
                tx_ready <= !cnt;
                case(cnt[1:0])
                    2'b00: begin
                        scl <= 1'b0;
                        if(cnt_byte)
                            sda_o <= tx_buf[7];
                        else
                            sda_o <= 1'b0;
                    end
                    2'b01:begin
                        scl <= 1'b1;
                        if(cnt_ack) begin   // read ack
                            tx_len_r <= tx_len_r - 1'b1;
                            slave_ack <= ~sda_i;
                        end
                    end
                    2'b10:begin
                    end
                    2'b11: begin
                        scl <= 1'b0;
                    end
                endcase
            end
            ST_RDAT:begin
                case(cnt[1:0])
                    2'b00: begin
                        scl <= 1'b0;
                        if(cnt_ack) begin   // write ack
                            sda_o <= (rx_len_r > 1) ? 1'b0 : 1'b1;
                            master_ack <= (rx_len_r > 1);
                            rx_len_r <= rx_len_r - 1'b1;
                            rx_byte <= rx_buf;
                            rx_ready <= 1'b1;
                        end
                    end
                    2'b01:begin
                        scl <= 1'b1;
                    end
                    2'b10:begin
                    end
                    2'b11: begin
                        scl <= 1'b0;
                    end
                endcase
            end
            default:begin
                sda_o <= 1'b1;
                scl <= 1'b1;
                master_ack <= 1'b0;
                slave_ack <= 1'b0;
            end
        endcase
    end
end

endmodule // i2c_master