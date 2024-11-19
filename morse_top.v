`timescale 1ns / 1ps

module morse_top(
    input wire iCLK,
    input wire [3:0] KEY,
    input wire [1:0] SW,
    input wire rst, // SW7
    input wire [1:0] Menu, // SW8, SW9
    output wire [6:0] HEX0,
    output wire [6:0] HEX1,
    output wire [6:0] HEX2,  
    output wire [6:0] HEX3, 
    output wire [7:3] LEDG, // LEDG[0] TX
    output wire [3:0] kcount
);

    wire [4:0] tflick;
    wire [14:0] tcount;
    wire [19:0] outHEX;
    wire [19:0] rcount;

    // func TX
    TX X1(
        .wiCLK(iCLK),
        .wKEY(KEY),
        .wSW(SW[0]),
        .wrst(rst),
        .wMenu(Menu),
        .wflick(tflick),
        .wcount(tcount),
        .wLEDG(LEDG[3])
    );

    // func RX
    RX X2(
        .wiCLK(iCLK),
        .wKEY(KEY),
        .wSW(SW[1]),
        .wrst(rst),
        .wMenu(Menu),
        .wcount(rcount),
        .ccount(kcount),
        .countled(LEDG[7:5])
    );

    // 4-to-2 MUX and display HEX 
    assign outHEX = (Menu == 2'b00) ? 20'b1001_0001_0001_0111_1111 :
                    (Menu == 2'b01) ? {tcount, tflick} :
                    (Menu == 2'b10) ? {rcount} : 20'b1111_1111_1111_1111_1111;

    seg7alp u4 (.in(outHEX[19:15]), .out(HEX3));
    seg7alp u3 (.in(outHEX[14:10]), .out(HEX2));
    seg7alp u2 (.in(outHEX[9:5]), .out(HEX1));
    seg7alp u1 (.in(outHEX[4:0]), .out(HEX0));

endmodule
