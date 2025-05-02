`define waiting      4'b0000 
`define read_state_1 4'b0001 
`define read_state_2 4'b0010 
`define read_state_3 4'b0011 
`define compare_1    4'b0100 
`define compare_2    4'b0101 
`define finish       4'b0110
`define compare_3    4'b0111 
`define addressPlus  4'b1000    // Since We only have 32 letters, 
`define Idle1        4'b1001 
`define size_check   4'b1010 
`define Finalcheck   4'b1011 
`define Idle2        4'b1100 
`define Idle3        4'b1101 
`define Idle4        4'b1110 
`define Finalcheck_wrong        4'b1111 


module  CapitalLetter(input logic[7:0] data, 
output logic [7:0] address,
output logic finishcheck,
input logic start,
input logic clk,
output logic wrong_message,
output logic yes_message,
output logic Capital_progress,
output logic Inhere,
output logic LED_wrong);     

        logic [4:0] counter = 5'b00000; 
        logic [3:0] state  = 4'b0000;
        logic [7:0] databackup;
        logic [23:0] secret_key;


        always_ff@(posedge clk)
              case(state) 
                  `waiting: if(start == 1'b1)
                                begin 
                                //write_enable <= 1'b0;
                                address <= counter;
                                finishcheck <= 1'b0;
                                state <= `read_state_1;
                                Capital_progress <= 1'b1;
                                Inhere <= 1'b1;
                                end 

                                else 
                                begin 
                                //write_enable <= 1'b0;
                                address <= address;
                                finishcheck <= 1'b0;
                                state <= `waiting;
                                Capital_progress <= 1'b0;
                                end 

                `read_state_1: begin 
                               //write_enable <= 1'b0;
                               address <= counter;
                               finishcheck <= 1'b0;
                               databackup <= data;
                               state <= `read_state_2;
                end 

                `read_state_2: begin 
                               //write_enable <= 1'b0;
                               address <= counter;
                               finishcheck <= 1'b0;
                               databackup <= data;
                               state <= `read_state_3;
                end 

                `read_state_3:  begin 
                               //write_enable <= 1'b0;
                               address <= counter;
                               finishcheck <= 1'b0;
                               databackup <= data;
                               state <= `compare_1;
                end 

                `compare_1: if(databackup == 8'b00100000)
                                 state <= `finish;
                                 else 
                                 state <= `compare_2;
                
                `compare_2: if(databackup >= 8'b01100001)
                                  begin 
                                  state <= `compare_3;
                                  end 

                                  else 
                                  begin 
                                  state <= `finish;
                                  wrong_message <= 1'b1;
                                  end 
                
                `compare_3: if(databackup <= 8'b01111010)
                                  begin 
                                  state <= `finish;
                                  end 

                                  else 
                                  begin 
                                  state <= `finish;
                                  wrong_message <= 1'b1;
                                  end 

                `finish:    if(wrong_message == 1'b1)
                                 begin 
                                 state <= `Finalcheck_wrong;
                                 wrong_message <= 1'b0;
                                 LED_wrong <= 1'b1;
                                 end 

                                 else 
                                 begin 
                                 state <= `addressPlus;
                                 end 


                `addressPlus:   begin 
                                counter <= counter + 1'b1;
                                state <= `size_check;
                end 

                `size_check:    begin 
                                    if(counter == 5'b00000)
                                        state <= `Finalcheck;
                                        else 
                                        state <= `read_state_1;
                end 
                
                `Finalcheck_wrong:   if(start == 1'b1)
                                   begin 
                                   state <= `Finalcheck_wrong;
                                   finishcheck = 1'b1; //finishcheck = 1'b1 means that the message is incorrect and the fsms need to be ran through again
                                   Capital_progress <= 1'b0;
                                   end 

                                   else 
                                   begin 
                                   state <= `Idle1;
                                   finishcheck <= 1'b1;
                                   Capital_progress <= 1'b0;
                                   wrong_message <= 1'b0;
                                   end 

                `Finalcheck: begin //This stage means the message is correct and all finished
                             state <= `Finalcheck;
                             yes_message <= 1'b1;
                             Capital_progress <= 1'b0;
                             finishcheck <= 1'b0;
                end 
                
                `Idle1:  begin 
                         finishcheck <= 1'b0;
                         state <= `Idle2;
                         wrong_message <= 1'b0;
                end 
                
                `Idle2: begin 
                         finishcheck <= 1'b1; //finishcheck = 1'b1 means that the message is incorrect and the fsms need to be ran through again
                         state <= `waiting;
                         finishcheck <= 1'b0;
                         counter <= 5'b0;
                         wrong_message <= 1'b0;

                end 
                
            

                default: state <= state;
                                
              endcase               

        

endmodule 



//This finite state machine is used for determining whether the data in decrypted message is 
//in lowercase letters. 