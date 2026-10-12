`timescale 1ns/1ps

module tb_bch_encoder_top;

    // Testbench Clock and Reset
    reg         clk;
    reg         rst_n;

    // Top Module Control Signals
    reg         gen_start;
    reg [126:0] helper_xor_mask;

    // Top Module Outputs
    wire [126:0] final_codeword;
    wire        enc_done;

    // Instantiate Top-Level Pre-Decoding Wrapper
    bch_encoder_top u_top (
        .clk(clk),
        .rst_n(rst_n),
        .gen_start(gen_start),
        .helper_xor_mask(helper_xor_mask),
        .final_codeword(final_codeword),
        .enc_done(enc_done)
    );

    // 100 MHz Clock Generation
    initial clk = 0;
    always #5 clk = ~clk;

    // File Handle for Export
    integer file_handle;
    integer frame_cnt;

    initial begin
        // Initialize Inputs
        rst_n           = 0;
        gen_start       = 0;
        helper_xor_mask = 127'b0;

        // Open output file in XSIM directory
        file_handle = $fopen("test_vectors.txt", "w");
        if (!file_handle) begin
            $display("\n[XSIM ERROR] Could not open test_vectors.txt for writing!");
            $finish;
        end

        // Release Reset
        #20 rst_n = 1; 
        #10;

        $display("\n=========================================================================");
        $display("          XSIM PRE-DECODING TOP-LEVEL SIMULATION EXECUTION               ");
        $display("=========================================================================\n");

        // Run 5 test frames
        for (frame_cnt = 1; frame_cnt <= 5; frame_cnt = frame_cnt + 1) begin

            // Define specific XOR bit-flip masks for helper/error injection
            // Frame 1: Flips at index 5, 22, 80
            // Other frames: Dynamic offsets based on frame number
            helper_xor_mask = (127'b1 << (frame_cnt * 5)) | 
                              (127'b1 << (frame_cnt * 15)) | 
                              (127'b1 << (frame_cnt * 25));

            $display("-------------------------------------------------------------------------");
            $display("[XSIM FRAME %0d] STEP 1: Triggering Data Generation & Encoding...", frame_cnt);

            // Pulse start signal
            @(posedge clk);
            gen_start = 1'b1;
            @(posedge clk);
            gen_start = 1'b0;

            // Wait for encoder to finish processing frame
            @(posedge enc_done);
            #1; // Settling delay for combinational signals

            $display("[XSIM FRAME %0d] STEP 2: Generated & Encoded Successfully", frame_cnt);
            $display("  -> Applied XOR Mask : %b", helper_xor_mask);
            $display("  -> Final Codeword   : %b", final_codeword);

            // Write 127-bit vector to test_vectors.txt
            $fdisplay(file_handle, "%b", final_codeword);
            $display("  -> Exported frame %0d to test_vectors.txt\n", frame_cnt);

            #50;
        end

        $fclose(file_handle);

        $display("=========================================================================");
        $display("  SUCCESS: ALL 5 TEST VECTORS WRITTEN TO test_vectors.txt IN XSIM DIRECTORY ");
        $display("=========================================================================\n");

        $finish;
    end

endmodule