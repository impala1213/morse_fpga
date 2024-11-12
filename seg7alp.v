`timescale 1ns / 1ps

module seg7alp(
    input wire [4:0] in,     // 5-bit input for 26 alphabets (0-25)
    output reg [6:0] out     // 7-bit output for seven segment display
    // Segment encoding: abc_defg
    // For Spartan-7 7-segment display:
    //     a
    //    ---
    // f |   | b
    //    -g-
    // e |   | c
    //    ---
    //     d
);

    // Using always block instead of assign for better synthesis results
    always @(*) begin
        case(in)
            5'd0:  out = 7'b1110111; // a
            5'd1:  out = 7'b1111100; // b
            5'd2:  out = 7'b1011000; // c
            5'd3:  out = 7'b1011110; // d
            5'd4:  out = 7'b1111001; // e
            5'd5:  out = 7'b1110001; // f
            5'd6:  out = 7'b0111101; // g
            5'd7:  out = 7'b1110110; // h
            5'd8:  out = 7'b0110000; // i
            5'd9:  out = 7'b0011110; // j
            5'd10: out = 7'b1111010; // k
            5'd11: out = 7'b0111000; // l
            5'd12: out = 7'b1010101; // m
            5'd13: out = 7'b1010100; // n
            5'd14: out = 7'b1011100; // o
            5'd15: out = 7'b1110011; // p
            5'd16: out = 7'b1100111; // q
            5'd17: out = 7'b1010000; // r
            5'd18: out = 7'b1101101; // s
            5'd19: out = 7'b1111000; // t
            5'd20: out = 7'b0011100; // u
            5'd21: out = 7'b1111110; // v
            5'd22: out = 7'b1101010; // w
            5'd23: out = 7'b0110110; // x
            5'd24: out = 7'b1101110; // y
            5'd25: out = 7'b1001001; // z
            default: out = 7'b0000000; // all segments off
        endcase
    end

endmodule
