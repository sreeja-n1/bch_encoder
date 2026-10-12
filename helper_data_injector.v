`timescale 1ns/1ps

module helper_data_injector (
    input  wire [126:0] raw_codeword,
    input  wire [126:0] helper_mask,    // Bitmask containing helper XOR bits or errors
    output wire [126:0] modified_output  // Resulting corrupted codeword
);

    // Bitwise XOR between raw BCH codeword and Helper Data Mask
    assign modified_output = raw_codeword ^ helper_mask;

endmodule