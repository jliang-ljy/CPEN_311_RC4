`timescale 1ns/1ps

module tb7_fsm_shuffle;

    // Inputs
    reg clk;
    reg [7:0] data_in;
    reg startnext;
    reg [23:0] secret;

    // Outputs
    wire [7:0] address;
    wire [7:0] data_out;
    wire finish;
    wire write_enable;
    wire shuffle_progress;
    wire [7:0] I_test;
    wire [7:8] J_test;

    // Instantiate the Unit Under Test (UUT)
    fsm_shuffle uut (
        .clk(clk),
        .data_in(data_in),
        .startnext(startnext),
        .address(address),
        .data_out(data_out),
        .secret(secret),
        .finish(finish),
        .write_enable(write_enable),
        .shuffle_progress(shuffle_progress),
        .I_test(I_test),
        .J_test(J_test)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    initial begin
        // Initialize Inputs
        startnext = 0;
        data_in = 8'b0;
        secret = 24'hABCDEF; // Example secret value

        // Wait for the global reset
        #20;

        // Start the FSM
        startnext = 1;
        #10; // Hold startnext high for one clock cycle
        startnext = 0;

        // Wait and observe FSM progression
        wait (shuffle_progress == 1); // Wait until FSM is active

        // Wait for some cycles to let FSM process
        repeat (50) @(posedge clk);

        // Trigger second start
        startnext = 1;
        #10; // Hold startnext high for one clock cycle
        startnext = 0;

        // Wait and observe FSM progression again
        wait (shuffle_progress == 1); // Wait until FSM is active

        // Wait for some more cycles
        repeat (50) @(posedge clk);

        // Finish the simulation
        $finish;
    end

    // Monitor to observe the FSM behavior
    initial begin
        $monitor("Time: %0t, state: %b, I_test: %d, J_test: %d, address: %d, data_out: %d, finish: %b, write_enable: %b, shuffle_progress: %b",
                 $time, uut.state, I_test, J_test, address, data_out, finish, write_enable, shuffle_progress);
    end

endmodule
