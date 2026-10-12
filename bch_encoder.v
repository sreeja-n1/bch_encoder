`timescale 1ns/1ps
`include "bch_params.vh"

module bch_encoder (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,     // High pulse begins encoding frame
    input  wire [63:0] msg_in,    // 64-bit input message
    output reg         out_vld,   // High when valid bit streaming out
    output reg         out_bit,   // Serial codeword bit (MSB first)
    output reg         busy,      // Encoder working
    output reg         done       // Pulse high when frame output complete
);

    reg [62:0] lfsr;
    reg [63:0] msg_reg;
    reg [6:0]  cnt;

    localparam IDLE       = 2'b00;
    localparam MSG_OUT    = 2'b01;
    localparam PARITY_OUT = 2'b10;

    reg [1:0] state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lfsr    <= 63'b0;
            msg_reg <= 64'b0;
            cnt     <= 7'd0;
            out_vld <= 1'b0;
            out_bit <= 1'b0;
            busy    <= 1'b0;
            done    <= 1'b0;
            state   <= IDLE;
        end else begin
            done <= 1'b0;
            case (state)
                IDLE: begin
                    out_vld <= 1'b0;
                    if (start) begin
                        lfsr    <= 63'b0;
                        msg_reg <= msg_in;
                        cnt     <= 7'd0;
                        busy    <= 1'b1;
                        state   <= MSG_OUT;
                    end else begin
                        busy    <= 1'b0;
                    end
                end

                MSG_OUT: begin
                    out_vld <= 1'b1;
                    out_bit <= msg_reg[63];

                    // Systematic feedback step
                    // Inside bch_encoder.v
if (msg_reg[63] ^ lfsr[62]) begin
    lfsr <= {lfsr[61:0], 1'b0} ^ `GEN_POLY;
end else begin
    lfsr <= {lfsr[61:0], 1'b0};
end

                    msg_reg <= {msg_reg[62:0], 1'b0};
                    cnt     <= cnt + 1'b1;

                    if (cnt == 7'd63) begin
                        cnt   <= 7'd0;
                        state <= PARITY_OUT;
                    end
                end

                PARITY_OUT: begin
                    out_vld <= 1'b1;
                    out_bit <= lfsr[62];
                    lfsr    <= {lfsr[61:0], 1'b0};
                    cnt     <= cnt + 1'b1;

                    if (cnt == 7'd62) begin
                        done  <= 1'b1;
                        busy  <= 1'b0;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule