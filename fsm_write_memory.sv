`define state0 4'b0000 
`define state1 4'b0001 
`define state2 4'b0010 
`define state3 4'b0011 
`define state4 4'b0100 
`define state5 4'b0101 
`define state6 4'b0111 
`define state7 4'b1000 
`define state8 4'b1001 
`define state9 4'b1010 
`define state10 4'b1011 
`define state11 4'b1100 


module fsm_write_memory(
     input logic inclk,
     input logic start,
     output logic [7:0] counter_value,
     output logic [7:0] address,
     output logic finish,
     output logic write_enable,
     output logic startnext,
     output logic fsm_progress,
     input logic second_start
);

    logic [3:0] state = 4'b0000;
    logic [7:0] counter_i = 8'b00000000;
    assign address = counter_i;
    //assign finish = 1'b0;
    assign counter_value = counter_i;


    always_ff @ (posedge inclk) begin
        case(state)
           `state0: if(start == 1'b1)
                       begin 
                        finish <= 1'b0;
                       state <= `state1;
                       write_enable <= 1'b0;
                       startnext <= 1'b0;
                       counter_i <= counter_i;
                       fsm_progress <= 1'b1;
                       end 

                       else 
                       begin 
                       state <= `state0;
                       write_enable <= 1'b0;
                       startnext <= 1'b0;
                       counter_i <= counter_i;
                       fsm_progress <= 1'b0;
                       end 
           
           
           `state1: if(startnext == 1'b0)
                       begin 
                       counter_i <= counter_i;
                       write_enable <= 1'b1;
                       startnext <= 1'b0;
                       state <= `state2;
                       end 

                       else 
                       begin 
                        counter_i <= counter_i;
                        write_enable <= 1'b0;
                        startnext <= 1'b1;
                        state <= `state1;
                       end 

            `state2: begin 
                     counter_i <= counter_i;
                     write_enable <= 1'b1;
                     startnext <= 1'b0;
                     state <= `state3;
            end 

            `state3: begin 
                     counter_i <= counter_i;
                     write_enable <= 1'b1;
                     startnext <= 1'b0;
                     state <= `state4;
            end 

            `state4: begin 
                      counter_i <= counter_i;
                     write_enable <= 1'b0;
                     startnext <= 1'b0;
                     state <= `state5;
            end 
   
            `state5: begin 
                     counter_i <= counter_i + 8'b00000001;
                     state <= `state6;
            end 
            
            `state6: if(counter_i == 8'b00000000)
                        begin 
                        startnext <= 1'b1;
                        state <= `state7;
                        fsm_progress <= 1'b0;
                        end 
                        else 
                        begin 
                        startnext <= 1'b0;
                        state <= `state1;
                        end 
                        
            `state7: begin 
                   state <= `state8;
                   startnext <= 1'b1;
            end 

            `state8: begin 
                    state <= `state9;
                    startnext <= 1'b1;
            end 

            `state10: begin 
                     state <= `state11;
                     finish <= 1'b1;
                     startnext <= 1'b1;
            end 

            `state11: begin 
                      state <= `state9;
                      finish <= 1'b1;
                      startnext <= 1'b1;
            end 
                     
                    
                     
            `state9:  begin
                      if(second_start == 1'b1)
                      begin 
                       state <= `state1; // changed from state1 to state0
                       write_enable <= 1'b0;
                       startnext <= 1'b0;
                       finish <= 1'b1;
                       fsm_progress <= 1'b1;
                       counter_i <= 8'b0;
                       end 

                       else 
                       begin 
                       state <= `state9;
                       write_enable <= 1'b0;
                       startnext <= 1'b0;
                       finish <= 1'b1;
                       fsm_progress <= 1'b0;
                       counter_i <= 8'b0;
                       end
            end
            
           default: begin 
                     state <= state;
           end
           

        endcase 
    end                
                     
                     










endmodule 