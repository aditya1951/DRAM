
module DRAM(
  input [9:0] row,
  input [9:0] col,
  input [31:0] data_in,
  input read,
  input write,
  output reg [31:0] data_out,
  input refresh,
  input clk
);
  parameter INTIALIZARTION = 0,IDLE = 1,READ = 2,WRITE = 3,REFRESH = 4;
  reg [3:0] state;
  reg [31:0] memory[0:1023][0:1023];
  reg [31:0] d;
  reg parity;
  reg error_detected;
  integer i,j;
  initial begin
    data_out<=32'bz;
    state<=INTIALIZARTION;
    for(i=0;i<=1023;i=i+1)begin
      for(j=0;j<=1023;j=j+1)begin
        memory[i][j]<=0;
      end
    end
  end

  always @(posedge clk) begin
    data_out<=32'bz;
    if(refresh)begin
      state<=REFRESH;
      for(i=0;i<=1023;i=i+1)begin
          for(j=0;j<=1023;j=j+1)begin
            memory[i][j]<=memory[i][j];
          end
        end
      state<=IDLE;
    end else if(write) begin
      state<=WRITE;
      error_detected=^data_in; // parity check
      if(~error_detected)begin
        memory[row][col]<=data_in;
      end else begin
        $display("Error detected in the input");
        $display("Error is fixed by complementing  the parity bit");
        memory[row][col]<={~data_in[31],data_in[30:0]};
      end
      state<=IDLE;
    end else if(read)begin
      state<=READ;
      d<=memory[row][col];
      error_detected=^d; // parity check
      if(~error_detected)begin
        data_out<=d;
      end else begin
        $display("Error detected in the output");
        $display("Error is fixed by complementing  the parity bit");
        data_out<={~d[31],d[30:0]};
      end
      state<=IDLE;
    end else begin
      state<=IDLE;
    end
  end
endmodule