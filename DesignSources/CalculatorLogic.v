`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:      Robert Riordan
// Target Device: XC7A100T-csg324 on Digilent Nexys 4 board
// Description:   Calculator Logic
//                Sets the ouput bits based on keypad input from user
// Created:       08 November 2018
//////////////////////////////////////////////////////////////////////////////////

module CalculatorLogic(
    input newKey,           // High for one cycle for each NewKey press           
    input [4:0] keycode,    // Code to represent key - valid during NewKey
    input clock,
    input reset,
    output [15:0] value
    );
    
    localparam [2:0]    CLEAR = 3'b001,     // Clear registers
                        PLUS = 3'b010,      // Sum X and Y, put to Y
                        MUL = 3'b011,       // Multiply X and Y, put to Y
                        EQUALS = 3'b100,     // Output Y
                        NOTHING = 3'b000;   // Output X
    
    localparam [15:0]   ZERO = 16'b0000000000000000;
    
// ------------------------------------------------------------------------- //

    reg [15:0]  x,  // X value
                y;  // Y value
    
    reg [2:0]   op; // Current operation

    // Registers
    // Only changes value with new key entered
    always@(negedge newKey)
        if (reset)
            begin
                x <= ZERO;
                y <= ZERO;
                op <= NOTHING;
                next_x <= ZERO;
                next_y <= ZERO;
                next_op <= NOTHING;
            end
        else
            begin
                x <= next_x;
                y <= next_y;
                op <= next_op;
            end
        
 // ------------------------------------------------------------------------- //
    
    // X-register logic
    reg [15:0] next_x;
    
    // 
    always@(posedge newKey)
        // AC button
        if(clear)
            next_x = ZERO;
        // Not a number entered
        else if (!num)
            next_x = x;
        // Number entered
        else
            next_x = {x, data};
    
// ------------------------------------------------------------------------- //
    
    // Y-register
    reg [15:0] next_y;
    always@(newKey)
        if (clear)
            next_y = ZERO;
        else if (!newKey || !num)
            next_y = y;
        else
            next_y = x;
    
 // ------------------------------------------------------------------------- //
    
    // Operation register
    wire num;               // 1 if the input is a number
    wire [3:0] data;        // Rest of the input
    reg [4:0] next_op;      // Next operation
    assign {num, data} = keycode;
    
    always@(newKey)
        if(clear)
            next_op = NOTHING;          // Clear value
        else if (!newKey || num)
            next_op = op;               // Keep value
        else
            next_op = data;             // 4 bits going to 3 bits. Check getting 3 LSB
    
// ------------------------------------------------------------------------- //
    
    // Output logic
    reg [15:0] display;
    assign value = display;
    wire [2:0] key = data;
    
    always@(newKey)
        case(key)
            CLEAR:      display = ZERO;
            PLUS:       display = x;
                        
            MUL:        display = x;
            EQUALS:     display = y;
            default:    display = x;
        endcase

// ------------------------------------------------------------------------- //

    // Clear registers
    assign clear = (keycode == 5'b00001) ? 1'b1 : 1'b0;        

endmodule
