`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2020 13:20:56
// Design Name: 
// Module Name: sortCore
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sortCore(

input clock, 
input reset,
input start,  // signal indicating the start of algorithm
input [31:0] WrData, // array for input data
input WrEn, // write enable signal to start making inputs
input ReEn, // read endable signal to indicate output on output array
output [31:0] SortedData, // output array
output reg done // signal indicating that process is finished
);

reg [31:0] n = 0; // number to indicate the number of elements in input array
reg [3:0] state;  // state of FSM
reg [31:0] memory[1023:0]; // array that contains elements of RAM
reg [31:0] m=0; // number to indicate the number of elements in output array
reg [31:0] t; // temporary number
integer i; // for loop 
integer j; // for loop 
integer minimum; //constant to hold index of minimum number
reg [31:0] SortData; // register to hold output data
reg [31:0] a=0; // address of input data

localparam  IDLE = 'd0,  //states of FSM
            SORT = 'd1, 
            WRITE = 'd2,
            DONE = 'd3;
            
always @(posedge clock)
begin
    if(reset)
    begin
        state <=IDLE;
        done = 0;
    end
    else 
    begin
        case(state) //description of all given states
            IDLE:begin
                if(WrEn)
                begin
                    memory[a] = WrData;
                    a = a+1;
                    n = n+1;
                end            
                else if(start)
                begin
                   state <= SORT;
                end
            end
            SORT:begin
                if(!WrEn)
                begin
                     j=0;
                     i=0;
                     for (i = 0; i < n - 1; i = i+1) // that's where sorting is done
                     begin
                        minimum = i;
                        for (j = i+1; j < n; j = j+1)
                        begin
                            if(memory[j] < memory[minimum])
                            minimum = j;
                        end
                     t = memory[minimum];
                     memory[minimum] = memory[i];
                     memory[i] = t; 
                     end
                state <= WRITE;
                end
            end
            WRITE:begin
                if(ReEn)  
                begin
                    SortData <= memory[m]; 
                    m = m + 1;
                    if(m == n)
                    state <= DONE;
                end                 
            end
            DONE:begin
                done <= 1'b1;
                if(!start)
                begin
                    done <= 1'b0;
                    state <= IDLE;
                end
            end
        endcase
    end
end
 
sortRam arrayR (
  .clka(clock),    // input wire clka
  .ena(WrEn),      // input wire ena
  .wea(WrEn),      // input wire [0 : 0] wea
  .addra(a),  // input wire [9 : 0] addra
  .dina(WrData),    // input wire [31 : 0] dina
  .douta(),  // output wire [31 : 0] douta
  .clkb(clock),    // input wire clkb
  .rstb(reset),    // input wire rstb
  .enb(ReEn),      // input wire enb
  .web(ReEn),      // input wire [0 : 0] web
  .addrb(m),  // input wire [9 : 0] addrb
  .dinb(SortData),    // input wire [31 : 0] dinb
  .doutb(SortedData)  // output wire [31 : 0] doutb
);
endmodule
