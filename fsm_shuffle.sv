`define resting 5'b00000
`define data_in_read_i_1 5'b00001 
`define data_in_read_j_1 5'b00010 
`define data_in_read_j_3 5'b00100 
`define data_in_write_SI_1 5'b00101 
`define data_in_write_SI_2 5'b00110 
`define data_in_write_SJ_1 5'b00111
`define data_in_write_SJ_2 5'b01000
`define data_in_Iplus 5'b01001 
`define data_in_read_i_2 5'b01010 
`define data_in_read_j_2 5'b01011 
`define Comparison_Idle 5'b01100 
`define state13 5'b01101 
`define J_calculation 5'b01110 
`define resting2 5'b01111 
`define Idle1 5'b10000 
`define Compare_Fin 5'b10001
`define Idle2 5'b10010 



module fsm_shuffle(
    input logic clk,
    input logic [7:0] data_in,
    input logic startnext, //1 when start shuffling
    output logic [7:0] address,
    output logic [7:0] data_out,
    input logic [23:0] secret,
    output logic finish,
    output logic write_enable,
    output logic shuffle_progress,
    output logic [7:0] I_test,
    output logic [7:0] J_test

);
    logic [4:0] state = 5'b00000;
    logic [7:0] Value_I = 8'b00000000;
    logic [7:0] Value_J = 8'b00000000;
    logic [1:0] counter3;
    logic [7:0] backup_I = 8'b00000000;
    logic [7:0] backup_J = 8'b00000000;
    logic [7:0] eight;
    
   
    always_ff@(posedge clk) begin
         case(counter3) 
            2'b00: eight = secret [23:16];
            2'b01: eight = secret [15:8];
            2'b10: eight = secret [7:0];
            default: eight <= 8'b00000000;
         endcase
    end

assign I_test = Value_I;
assign J_test = Value_J;

      assign counter3 = Value_I % 3;

    always_ff@(posedge clk) begin
           case(state)
             `resting: if(startnext == 1'b1 ) // give edge, no i
                         begin 
                         finish <= 1'b0;
                         write_enable <= 1'b0;
                         address <= Value_I;
                         shuffle_progress <= 1'b1;
                        //  backup_I <= data_in;
                         state <= `data_in_read_i_1;       
                         end 

                         else 
                         begin 
                         state <= `resting;
                         shuffle_progress <= 1'b0;
                         finish <= 1'b0;
                         end 

            `data_in_read_i_1:  begin 
		                  state <= `data_in_read_i_2;
                    //  write_enable <= 1'b0;
                    //  address <= Value_I;
                     backup_I <= data_in;
			end 
 
             `data_in_read_i_2: begin
                     state <= `J_calculation;
                     write_enable <= 1'b0;
                     address <= Value_I;
                     backup_I <= data_in;
                     

              end 
     
              `J_calculation: begin 
                        Value_J <= Value_J + eight + backup_I;
                        state <= `data_in_read_j_1;
              end 

            `data_in_read_j_1:  begin 
                     address <= Value_J;
                     write_enable <= 1'b0;
                    //  address <= Value_J;
                    //  backup_J <= data_in;
                     state <= `data_in_read_j_2;
            end 

            `data_in_read_j_2: begin 
                     write_enable <= 1'b0;
                     address <= Value_J ;
                    //  backup_J <= data_in;
                     state <= `data_in_read_j_3;
            end 

            `data_in_read_j_3: begin 
                    //  write_enable <= 1'b0;
                    //  address <= Value_J;
                     backup_J <= data_in;
                     state <= `data_in_write_SI_1;
            end 

            `data_in_write_SI_1: begin 
                     write_enable <= 1'b1;
                     address <= Value_I;
                     data_out <= backup_J;
                     state <= `data_in_write_SI_2;
            end 

            `data_in_write_SI_2: begin // s[i] = s[j]
                    //  write_enable <= 1'b1;
                    //  address <= Value_I;
                    //  data_out <= backup_J;
                     state <= `data_in_write_SJ_1;
            end 

            `data_in_write_SJ_1: begin
                     write_enable <= 1'b1;
                     address <= Value_J;
                     data_out <= backup_I;
                     state <= `data_in_write_SJ_2;
            end

            `data_in_write_SJ_2: begin //s[j]=s[i]
                    //  write_enable <= 1'b1;
                    //  address <= Value_J;
                    //  data_out <= backup_I;
                     state <= `data_in_Iplus;
            end

            
            `data_in_Iplus: begin 
                     write_enable <= 1'b0;
                    //  address <= address;
                    //  data_out <= data_out;
                     state <= `Comparison_Idle;
                     //finish1 <= 1'b1; 
                     Value_I <= Value_I + 8'b00000001;
            end 

            `Comparison_Idle: 
                   if(Value_I !=  8'b00000000)
                          state <=  `resting2;
                          else begin
                            finish <= 1'b1;
                            state <= `Idle1;
                            shuffle_progress <= 1'b0;
                          end// end 
   
            `resting2: begin 
                         finish <= 1'b0;
                         write_enable <= 1'b0;
                         address <= Value_I;
                         shuffle_progress <= 1'b1;
                        //  backup_I <= data_in;
                         state <= `data_in_read_i_1;       
                         end 

            `Idle1: begin 
                  finish <= 1'b0;
                  state <= `Idle2;
                  Value_I <= 8'b0;
                  Value_J <= 8'b0;
            end 

            `Idle2: begin 
                  finish <= 1'b0;
                  Value_J <= 8'b0;
                  state <= `Compare_Fin;
            end 

            `Compare_Fin: if(startnext == 1'b0)
                              begin 
                              state <= `resting;
                              finish <= 1'b0;
                              end 

                              else 
                              begin 
                              state <= `Compare_Fin;
                              finish <= 1'b0;
                              end 




          default: state <= state;

           endcase  
    end


endmodule 