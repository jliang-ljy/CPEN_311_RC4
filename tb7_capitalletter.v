`timescale 1ns/1ps

module tb7_CapitalLetter;

    // Inputs
    reg [7:0] data;
    reg start;
    reg clk;

    // Outputs
    wire [7:0] address;
    wire finishcheck;
    wire wrong_message;
    wire yes_message;
    wire Capital_progress;
    wire Inhere;
    wire LED_wrong;

    // Instantiate the Unit Under Test (UUT)
    CapitalLetter uut (
        .data(data),
        .address(address),
        .finishcheck(finishcheck),
        .start(start),
        .clk(clk),
        .wrong_message(wrong_message),
        .yes_message(yes_message),
        .Capital_progress(Capital_progress),
        .Inhere(Inhere),
        .LED_wrong(LED_wrong)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    initial begin
        // Initialize Inputs
        start = 0;
        data = 8'b0;

        // Wait for the global reset
        #20;

        // Provide a sequence of test inputs
        test_input(8'b01100001); // Test with 'a'
        test_input(8'b01000001); // Test with 'A'
        test_input(8'b01111010); // Test with 'z'
        test_input(8'b01011010); // Test with 'Z'
        test_input(8'b00100000); // Test with space
        test_input(8'b01100100); // Test with 'd'

        // Finish the simulation
        $finish;
    end

    // Task to apply test input and start FSM
    task test_input(input [7:0] test_data);
    begin
        // Initialize Inputs
        start = 0;
        data = test_data;

        // Wait for the global reset
        #20;

        // Start the FSM
        start = 1;
        #10; // Hold start high for one clock cycle
        start = 0;

        // Wait and observe FSM progression
        wait (Capital_progress == 1); // Wait until FSM is active

        // Wait for some cycles to let FSM process
        repeat (100) @(posedge clk);

        // Wait and observe FSM progression again
        wait (finishcheck == 1); // Wait until FSM finishes

        // Check results
        if (wrong_message == 1) begin
            $display("Test with data %b: wrong_message is high", test_data);
        end else if (yes_message == 1) begin
            $display("Test with data %b: yes_message is high", test_data);
        end else begin
            $display("Test with data %b: No result", test_data);
        end

        // Reset for next test
        start = 0;
        data = 8'b0;
        #20;
    end
    endtask

    // Monitor to observe the FSM behavior
    initial begin
        $monitor("Time: %0t, state: %b, address: %d, data: %d, finishcheck: %b, wrong_message: %b, yes_message: %b, Capital_progress: %b, Inhere: %b, LED_wrong: %b",
                 $time, uut.state, address, data, finishcheck, wrong_message, yes_message, Capital_progress, Inhere, LED_wrong);
    end

endmodule
