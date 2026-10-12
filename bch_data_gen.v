module bch_data_gen (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        gen_start,     // Pulse to generate new random frame
    output reg  [63:0] msg_out,       // Generated 64-bit message
    output reg         msg_vld        // Payload valid flag
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            msg_out <= 64'b0;
            msg_vld <= 1'b0;
        end else if (gen_start) begin
            // Generate pseudo-random 64-bit vector using SystemVerilog randomizer
            msg_out <= {$urandom, $urandom};
            msg_vld <= 1'b1;
        end else begin
            msg_vld <= 1'b0;
        end
    end

endmodule