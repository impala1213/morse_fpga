`timescale 1ns / 1ps

module RX(
    input wire wiCLK,        
    input wire [3:0] wKEY,   
    input wire wSW,          
    input wire [1:0] wMenu,  
    input wire wrst,         
    output wire [19:0] wcount, 
    output wire [3:0] ccount,  
    output wire [2:0] countled 
);

    reg [2:0] count;
    reg [4:0] ocount;    
    reg [3:0] stack;
    wire [3:0] hal_sec;
    reg [14:0] out;
    wire [3:0] sec;
    reg [3:0] button_stable_0;
    reg [3:0] button_stable_1;
    reg [3:0] button_stable_2;
    reg [3:0] button_stable_3;
    reg [3:0] button_valid;
    reg [3:0] prev_button_valid;

    // 디바운싱 및 버튼 유효성 검사
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

    // 버튼 입력 처리
    always @(posedge wiCLK or negedge wrst) begin
        if (~wrst) begin
            stack <= 4'b0000;
            count <= 3'b000;
            out <= 15'b100011011111111;
            ocount <= 5'b11111;
            prev_button_valid <= 4'b0000;
        end else begin
            prev_button_valid <= button_valid;

            if (button_valid[0] && !prev_button_valid[0]) begin
                stack <= {stack[2:0], 1'b0};
                count <= count + 1'b1;
                $display("Time %t: Dot pressed. Stack: %b, Count: %d", $time, {stack[2:0], 1'b0}, count + 1);
            end
            else if (button_valid[1] && !prev_button_valid[1]) begin
                stack <= {stack[2:0], 1'b1};
                count <= count + 1'b1;
                $display("Time %t: Dash pressed. Stack: %b, Count: %d", $time, {stack[2:0], 1'b1}, count + 1);
            end
            else if (button_valid[2] && !prev_button_valid[2]) begin
                stack <= 4'b0;
                count <= 3'b0;
                $display("Time %t: Reset pressed. Stack and Count cleared.", $time);
            end
            else if (wSW) begin
                out <= 15'b111111111111111;
                ocount <= 5'b11111;
                
            end
            else if (button_valid[3] && !prev_button_valid[3]) begin
         case (count)
                    3'b001: begin
                        case (stack[0])
                            1'b0: begin ocount <= 5'b00100; $display("Time %t: Letter decoded: E", $time); end
                            1'b1: begin ocount <= 5'b10011; $display("Time %t: Letter decoded: T", $time); end
                            default: begin ocount <= 5'b00000; $display("Time %t: Invalid input", $time); end
                        endcase
                    end
                    3'b010: begin
                        case (stack[1:0])
                            2'b00: begin ocount <= 5'b01000; $display("Time %t: Letter decoded: I", $time); end
                            2'b01: begin ocount <= 5'b00000; $display("Time %t: Letter decoded: A", $time); end
                            2'b10: begin ocount <= 5'b01101; $display("Time %t: Letter decoded: N", $time); end
                            2'b11: begin ocount <= 5'b01100; $display("Time %t: Letter decoded: M", $time); end
                            default: begin ocount <= 5'b00000; $display("Time %t: Invalid input", $time); end
                        endcase
                    end
                    3'b011: begin
                        case (stack[2:0])
                            3'b000: begin ocount <= 5'b10010; $display("Time %t: Letter decoded: S", $time); end
                            3'b001: begin ocount <= 5'b10100; $display("Time %t: Letter decoded: U", $time); end
                            3'b010: begin ocount <= 5'b10001; $display("Time %t: Letter decoded: R", $time); end
                            3'b011: begin ocount <= 5'b10110; $display("Time %t: Letter decoded: W", $time); end
                            3'b100: begin ocount <= 5'b00011; $display("Time %t: Letter decoded: D", $time); end
                            3'b101: begin ocount <= 5'b01010; $display("Time %t: Letter decoded: K", $time); end
                            3'b110: begin ocount <= 5'b00110; $display("Time %t: Letter decoded: G", $time); end
                            3'b111: begin ocount <= 5'b01110; $display("Time %t: Letter decoded: O", $time); end
                            default: begin ocount <= 5'b00000; $display("Time %t: Invalid input", $time); end
                        endcase
                    end
                    3'b100: begin
                        case (stack[3:0])
                            4'b0000: begin ocount <= 5'b00111; $display("Time %t: Letter decoded: H", $time); end
                            4'b0001: begin ocount <= 5'b10101; $display("Time %t: Letter decoded: V", $time); end
                            4'b0010: begin ocount <= 5'b00101; $display("Time %t: Letter decoded: F", $time); end
                            4'b0100: begin ocount <= 5'b01011; $display("Time %t: Letter decoded: L", $time); end
                            4'b0110: begin ocount <= 5'b01111; $display("Time %t: Letter decoded: P", $time); end
                            4'b0111: begin ocount <= 5'b01001; $display("Time %t: Letter decoded: J", $time); end
                            4'b1000: begin ocount <= 5'b00001; $display("Time %t: Letter decoded: B", $time); end
                            4'b1001: begin ocount <= 5'b10111; $display("Time %t: Letter decoded: X", $time); end
                            4'b1010: begin ocount <= 5'b00010; $display("Time %t: Letter decoded: C", $time); end
                            4'b1011: begin ocount <= 5'b11000; $display("Time %t: Letter decoded: Y", $time); end
                            4'b1100: begin ocount <= 5'b11001; $display("Time %t: Letter decoded: Z", $time); end
                            4'b1101: begin ocount <= 5'b10000; $display("Time %t: Letter decoded: Q", $time); end
                            default: begin ocount <= 5'b11111; $display("Time %t: Invalid input", $time); end
                                        endcase
                    end
                    default: begin 
                        ocount <= 5'b11111; 
                        $display("Time %t: Invalid count", $time);
                    end
                endcase
                out <= {out[9:0], ocount};
                
                stack <= 4'b0;
                count <= 3'b0;
                $display("Time %t: Letter confirmed. Output updated.", $time);
            end
        end
    end

    // Output assignments
    assign countled = count;
    assign ccount = stack;
    assign wcount = {out, ocount};

endmodule
