// author : lilin
// email  : 1657301947@qq.com

module spi_master(
    input clk,
    input rst_n,
    input en,
    input [7:0] tx_byte,
    output reg [7:0] rx_byte,
    output reg tx_ready,
    output reg rx_ready,

    input MISO,
    output reg SS,
    output reg SCK,
    output reg MOSI
);
    reg [3:0] state,next_state;
    reg [3:0] trans_cnt;
    reg [7:0] tx_buf;
    reg [7:0] rx_buf;
    wire [2:0] bit_cnt;
    wire cnt_full;

    assign bit_cnt = trans_cnt[3:1];
    assign cnt_full = (trans_cnt == 15);

localparam ST_IDLE   = 4'b0001,
           ST_START  = 4'b0010,
           ST_TRANS  = 4'b0100,
           ST_STOP   = 4'b1000;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        state <= ST_IDLE;
    else
        state <= next_state;
end

always @(*) begin
    case (state)
        ST_IDLE   : begin
            if(en)
                next_state = ST_START;
            else
                next_state = ST_IDLE;
        end
        ST_START  : begin
            next_state = ST_TRANS;
        end
        ST_TRANS  : begin
            if(cnt_full && !en)
                next_state = ST_STOP;
            else
                next_state = ST_TRANS;
        end
        ST_STOP   : begin
            next_state = ST_IDLE;
        end
        default: next_state = ST_IDLE;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        trans_cnt <= 4'd0;
        SS <= 1'b1;
        SCK <= 1'b1;
        MOSI <= 1'b1;
        rx_buf <= 8'h0;
        tx_buf <= 8'h0;
        rx_byte <= 8'h0;
        tx_ready <= 1'b0;
        rx_ready <= 1'b0;
    end
    else begin
        trans_cnt <= 4'd0;
        SS <= SS;
        SCK <= 1'b1;
        MOSI <= SS;
        rx_buf <= rx_buf;
        tx_buf <= tx_buf;
        tx_ready <= 1'b0;
        rx_ready <= 1'b0;
        case(state)
            ST_IDLE     :begin
                SS <= 1'b1;
                SCK <= 1'b1;
            end
            ST_START    :begin
                trans_cnt <= 4'd0;
                SS <= 1'b0;
                tx_buf <= tx_byte;
            end
            ST_TRANS    :begin
                trans_cnt <= trans_cnt + 1'b1;
                SS <= 1'b0;
                case(trans_cnt)
                    0:  begin  SCK <= 1'b0; MOSI <= tx_buf[7]; tx_ready <= 1'b1;end
                    2:  begin  SCK <= 1'b0; MOSI <= tx_buf[6]; end
                    4:  begin  SCK <= 1'b0; MOSI <= tx_buf[5]; end
                    6:  begin  SCK <= 1'b0; MOSI <= tx_buf[4]; end
                    8:  begin  SCK <= 1'b0; MOSI <= tx_buf[3]; end
                    10: begin  SCK <= 1'b0; MOSI <= tx_buf[2]; end
                    12: begin  SCK <= 1'b0; MOSI <= tx_buf[1]; end
                    14: begin  SCK <= 1'b0; MOSI <= tx_buf[0]; end
                    1,3,5,7,9,11,13: begin rx_buf <= {rx_buf[6:0],MISO}; end
                    15: begin
                        rx_byte <= {rx_buf[6:0],MISO};
                        tx_buf <= tx_byte;
                        rx_ready <= 1'b1;
                    end
                    default: ;
                endcase
            end
            ST_STOP     :begin
                trans_cnt <= 4'd0;
                SS <= 1'b1;
                SCK <= 1'b1;
                tx_buf <= 8'h0;
                rx_ready <= 1'b0;
            end
            default:;
        endcase
    end 
end

endmodule // spi_master_fsm