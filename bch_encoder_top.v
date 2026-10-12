`timescale 1ns/1ps

module bch_encoder_top (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         gen_start,        // Trigger vector generation & encoding
    input  wire [126:0] helper_xor_mask,  // Helper data / noise pattern
    output wire [126:0] final_codeword,   // Final modified codeword for decoder
    output wire         enc_done          // Encoder frame done pulse
);

    wire [63:0] gen_msg;
    wire        gen_vld;
    wire        enc_vld;
    wire        enc_bit;
    
    reg [126:0] raw_cw_reg;
    reg [6:0]   bit_idx;

    // 1. Module 1: Data Generator
    bch_data_gen u_data_gen (
        .clk(clk),
        .rst_n(rst_n),
        .gen_start(gen_start),
        .msg_out(gen_msg),
        .msg_vld(gen_vld)
    );

    // 2. Module 2: BCH Encoder
    bch_encoder u_encoder (
        .clk(clk),
        .rst_n(rst_n),
        .start(gen_vld),
        .msg_in(gen_msg),
        .out_vld(enc_vld),
        .out_bit(enc_bit),
        .busy(),
        .done(enc_done)
    );

    // Convert streaming encoder bits into a 127-bit parallel register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            raw_cw_reg <= 127'b0;
            bit_idx    <= 7'd126;
        end else if (gen_vld) begin
            bit_idx    <= 7'd126;
        end else if (enc_vld) begin
            raw_cw_reg[bit_idx] <= enc_bit;
            if (bit_idx > 0) bit_idx <= bit_idx - 1'b1;
        end
    end

    // 3. Module 3: Helper Data / Noise Injector
    helper_data_injector u_injector (
        .raw_codeword(raw_cw_reg),
        .helper_mask(helper_xor_mask),
        .modified_output(final_codeword)
    );

endmodule