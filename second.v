module second(
    input wire rst,          // Active low reset
    input wire clk,          // 100MHz clock input
    output wire [3:0] sec,   // Second counter output
    output wire [3:0] half_sec // Half second counter output
);

    // For 100MHz clock, need 100,000,000 counts for 1 second
    // 100,000,000 = 0x5F5_E100
    reg [26:0] reg0;        // Counter for 1 second
    reg [3:0] reg1;         // Second counter
    reg [3:0] reg2;         // Half second counter
    
    wire [6:0] HEX0;
    wire en1, en2;

    // 1 second enable
    assign en1 = (reg0 == 27'd99999999);
    // 0.5 second enable
    assign en2 = (reg0 == 27'd49999999);

    // 1 second counter
    always @(posedge clk) begin
        if (~rst) begin
            reg0 <= 27'd0;
        end
        else if (reg0 >= 27'd99999999) begin
            reg0 <= 27'd0;
        end
        else begin
            reg0 <= reg0 + 27'd1;
        end
    end

    // Second counter
    always @(posedge clk) begin
        if (~rst) begin
            reg1 <= 4'd0;
        end
        else if (en1) begin
            if (reg1 >= 4'd9)
                reg1 <= 4'd0;
            else
                reg1 <= reg1 + 4'd1;
        end
    end

    // Half second counter
    always @(posedge clk) begin
        if (~rst) begin
            reg2 <= 4'd0;
        end
        else if (en2) begin
            if (reg2 >= 4'd9)
                reg2 <= 4'd0;
            else
                reg2 <= reg2 + 4'd1;
        end
    end

    // Seven segment decoder instantiation
    seg7alp U1(
        .in(reg1),
        .out(HEX0)
    );

    // Output assignments
    assign sec = reg1;
    assign half_sec = reg2;

endmodule
