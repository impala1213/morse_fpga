`timescale 1ns / 1ps

module TX(
    input wire wiCLK,          
    input wire [3:0] wKEY,     
    input wire wSW,            
    input wire [1:0] wMenu,    
    input wire wrst,           
    output wire [4:0] wflick,  
    output wire [14:0] wcount, 
    output wire wLEDG          
);

    reg [4:0] counter;
    reg [14:0] count;
    reg [139:0] data;
    reg [7:0] I;
    wire [3:0] sec;
    wire [3:0] hal_sec;
    reg morse_active;
    reg [3:0] morse_bit_count;

    // 디바운싱 관련 레지스터
    reg [3:0] button_stable_0;
    reg [3:0] button_stable_1;
    reg [3:0] button_stable_2;
    reg [3:0] button_stable_3;
    reg [3:0] button_valid;
    reg [3:0] prev_button_valid;

    // State definitions
    localparam IDLE = 2'b00;
    localparam INPUT = 2'b01;
    localparam DISPLAY = 2'b10;
    reg [1:0] current_state;

    // Second counter instantiation
    second z1(
        .rst(wrst),
        .clk(wiCLK),
        .sec(sec),
        .half_sec(hal_sec)
    );

    // 디바운싱 로직
    always @(posedge wiCLK or negedge wrst) begin
        if (!wrst) begin
            button_stable_0 <= 4'b1111;
            button_stable_1 <= 4'b1111;
            button_stable_2 <= 4'b1111;
            button_stable_3 <= 4'b1111;
            button_valid <= 4'b0000;
        end else begin
            button_stable_0 <= {button_stable_0[2:0], wKEY[0]};
            button_stable_1 <= {button_stable_1[2:0], wKEY[1]};
            button_stable_2 <= {button_stable_2[2:0], wKEY[2]};
            button_stable_3 <= {button_stable_3[2:0], wKEY[3]};
            
            button_valid[0] <= (button_stable_0 == 4'b0000);
            button_valid[1] <= (button_stable_1 == 4'b0000);
            button_valid[2] <= (button_stable_2 == 4'b0000);
            button_valid[3] <= (button_stable_3 == 4'b0000);
        end
    end

    // 메인 로직
    always @(posedge wiCLK or negedge wrst) begin
        if (~wrst) begin
            current_state <= IDLE;
            morse_active <= 0;
            morse_bit_count <= 0;
            I <= 8'b0;
            count <= 15'b1111_1111_1111_111;
            counter <= 5'b0;
            data <= 140'b0;
            prev_button_valid <= 4'b0000;
        end else begin
            prev_button_valid <= button_valid;

            case (current_state)
                IDLE: begin
                    if (wMenu == 2'b01) begin
                        current_state <= INPUT;
                        $display("Time %t: Entering INPUT state", $time);
                    end
                end

                INPUT: begin
                    if (button_valid[0] && !prev_button_valid[0]) begin
                        counter <= 5'd0;
                        $display("Time %t: Counter reset to 0", $time);
                    end
                    else if (button_valid[1] && !prev_button_valid[1]) begin
                        counter <= (counter == 5'd25) ? 5'd0 : counter + 1'b1;
                        $display("Time %t: Counter changed to %d", $time, counter);
                    end
                    else if (button_valid[2] && !prev_button_valid[2]) begin
                        data <= {data[125:0], morse_code(counter)};
                        count <= {count[9:0], counter};
                        $display("Time %t: Added letter %c to data", $time, counter + "A");
                    end
                    else if (button_valid[3] && !prev_button_valid[3]) begin
                        data <= 140'b0;
                        count <= 15'b11111_11111_11111;
                        $display("Time %t: Data and count reset", $time);
                    end

                    if (wSW) begin
                        current_state <= DISPLAY;
                        morse_active <= 1;
                        $display("Time %t: Starting Morse code display", $time);
                    end
                end

                DISPLAY: begin
                    if (!wSW) begin
                        current_state <= INPUT;
                        morse_active <= 0;
                        I <= 8'b0;
                        $display("Time %t: Ending Morse code display", $time);
                    end
                    else if (hal_sec[0]) begin
                        if (I >= 8'd139) begin
                            I <= 8'b0;
                        end else begin
                            I <= I + 1'b1;
                        end
                    end
                end
            endcase
        end
    end

    // Morse code conversion function (unchanged)
    function [13:0] morse_code;
        input [4:0] letter;
        begin
            case(letter)
            0 : data[13:0] = 14'b1011_1100_0000_00;//A

   1 : data[13:0] = 14'b1110_1010_1000_00;//B

   2 : data[13:0] = 14'b1110_1011_1010_00;//C

   3 : data[13:0] = 14'b1110_1010_0000_00;//D

   4 : data[13:0] = 14'b0100_0000_0000_00;//E

   5 : data[13:0] = 14'b1010_1110_1000_00;//F

   6 : data[13:0] = 14'b1110_1110_1000_00;//G

   7 : data[13:0] = 14'b1010_1010_0000_00;//H

   8 : data[13:0] = 14'b1010_0000_0000_00;//I

   9 : data[13:0] = 14'b1011_1011_0110_00;//J

   10 : data[13:0] = 14'b1110_1011_1000_00;//K

   11 : data[13:0] = 14'b1011_1010_1000_00;//L

   12 : data[13:0] = 14'b1110_1110_0000_00;//M

   13 : data[13:0] = 14'b1110_1000_0000_00;//N

   14 : data[13:0] = 14'b1110_1110_1110_00;//O

   15 : data[13:0] = 14'b1011_1011_1010_00;//P

   16 : data[13:0] = 14'b1101_1010_1110_00;//Q

   17 : data[13:0] = 14'b1011_1010_0000_00;//R

   18 : data[13:0] = 14'b0101_0100_0000_00;//S

   19 : data[13:0] = 14'b0111_0000_0000_00;//T

   20 : data[13:0] = 14'b1010_1110_0000_00;//U

   21 : data[13:0] = 14'b1010_1011_1100_00;//V

   22 : data[13:0] = 14'b1011_1011_1000_00;//W

   23 : data[13:0] = 14'b1110_1010_1110_00;//X

   24 : data[13:0] = 14'b1101_0110_1110_00;//Y

   25 : data[13:0] = 14'b1110_1110_1010_00;//Z

   default : data[13:0] = 14'b0000_0000_0000_00;
                
            endcase
        end
    endfunction

    // Output assignments
    assign wflick = (current_state == INPUT) ? counter : 5'b11111;
    assign wcount = count;
    assign wLEDG = (current_state == DISPLAY && morse_active && data[139 - I]) ? 1'b1 : 1'b0;

endmodule
