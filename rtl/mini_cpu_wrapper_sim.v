`timescale 1ns / 1ps

module mini_cpu_wrapper_sim(
    
    input wire clk,
    input wire rst,
    input wire en,
    
    //IMEM init ports
    input wire        imem_we,
    input wire [7:0]  imem_addr,
    input wire [15:0] imem_wdata,
    
    //Regfile init port
    input wire 		  rf_we,
	  input wire [1:0]  rf_addr,
	  input wire [7:0]  rf_wdata,
	
	  //Outputs
    output wire [7:0] PC,
	  output wire       halt,
	  output wire [7:0] dbg_r0, 
	  output wire [7:0] dbg_r1, 
	  output wire [7:0] dbg_r2, 
	  output wire [7:0] dbg_r3,
	  output wire [2:0] dbg_state
    );

mini_cpu dut (
        .clk(clk),
			  .rst(rst),
			  .en(en),
			  
			  .PC(PC),
			  .halt(halt),
			  
			  .dbg_r0(dbg_r0),
			  .dbg_r1(dbg_r1),
			  .dbg_r2(dbg_r2),
  			.dbg_r3(dbg_r3),
			  .dbg_state(dbg_state),
              
        .imem_we(imem_we),
        .imem_addr(imem_addr),
        .imem_wdata(imem_wdata),
              
        .rf_we(rf_we),
			  .rf_addr(rf_addr),
        .rf_wdata(rf_wdata)     
			  );

endmodule
