//////////////////////////////////////////////////////////////////////////////////
// Engineer:      Robert Riordan
// Target Device: XC7A100T-csg324 on Digilent Nexys 4 board
// Description:   Dislpay Interface
//                Converts 16 bits value to 4 7-segment display outputs
//                Cycles through 4 ouput digits, displaying 1 at a time
// Created:       08 November 2018
//////////////////////////////////////////////////////////////////////////////////

module DisplayInterface(
    input clock,            // Clock
    input reset,            // Asynchronous reset
    input [15:0] value,     // Hexadecimal value to display 
    output [7:0] digit,     // Digit to display
    output [7:0] segment    // Illumination of segments for a given digit
    );
    
    reg enable;                             // Enable to slow down clock speed
    reg [3:0] CurrentDigit, NextDigit;
    localparam [3:0]    DISP1 = 4'b1110,    // Rightmost Display
                        DISP2 = 4'b1101,    // Next Digit to left of above
                        DISP3 = 4'b1011,    // Next Digit to left of above
                        DISP4 = 4'b0111,    // Next Digit to left of above
                        OFF = 4'b1111;
 
    // Select digit to display
    always@(posedge clock, posedge reset)           
        if(reset) CurrentDigit <= DISP1;            
        else if (enable) CurrentDigit <= NextDigit; // Move to next digit if enabled
        else CurrentDigit <= CurrentDigit;
       
    // Slow down clock speed to the display
    reg [10:0] count, nextCount;
    localparam [10:0] MAX_COUNT = 11'b11111111111;  // Slow down by a factor of 2048
    always @ (count)
        begin
            nextCount = count + 1'b1;
            if (nextCount == MAX_COUNT) enable = 1'b1;
            else enable = 1'b0;
        end

    // Reset and count value
    always @ (posedge clock) 
        count <= nextCount;

    // Select digit to display on FPGA
    always@(CurrentDigit)
        case(CurrentDigit[3:0])
            DISP1: NextDigit = DISP2;
            DISP2: NextDigit = DISP3;
            DISP3: NextDigit = DISP4;
            DISP4: NextDigit = DISP1;
            
            default NextDigit = DISP1;
        endcase
        
    assign digit = {OFF, CurrentDigit}; // Digit to display
    reg [3:0] number;                   // Value of digit on currint display
    
    wire [6:0] sevenSeg;                // Segment so light up based on number
    assign segment = {sevenSeg, 1'b1};  // Keep point off
    hex2seg h2s(.number(number), .pattern(sevenSeg));
    
    // Split 16-bit input into 4 4-bit numbers
    reg [3:0] digit1, digit2, digit3, digit4;
    always@(CurrentDigit, value)
    begin
        {digit4, digit3, digit2, digit1} = value;
        case(CurrentDigit[3:0])
            DISP1: number = digit1;
            DISP2: number = digit2;
            DISP3: number = digit3;
            DISP4: number = digit4;
            
            default: number = 1'h0;
        endcase
    end
endmodule