`ifndef BCH_PARAMS_VH
`define BCH_PARAMS_VH

// BCH(127,64,10) Configuration Parameters
`define N_GF        127                    // Codeword length
`define K_GF        64                     // Message length
`define M_GF        7                      // GF(2^7) extension degree
`define T_GF        10                     // Error correction capability
`define PARITY_BITS (`N_GF - `K_GF)        // 63 parity bits

// Generator Polynomial G(x) of degree 63 for BCH(127,64,10)
`define GEN_POLY    63'h723D4715A36A816F

`endif