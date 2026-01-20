// Mini CPU Demo TB:
//Load a small program that increments R2 N times while decrementing R0 to Zero.
// Expected: R0 = 0; R2 = N; halt = 1;


`timescale 1ns/1ps
`default_nettype none

module mini_cpu_demo_TB();

reg clk = 1'b0;
reg rst = 1'b1;
reg en 	= 1'b0;

reg 	   	  imem_we;
reg [7:0]  	imem_addr;
reg [15:0] 	imem_wdata;

reg 		    rf_we;
reg [1:0] 	rf_addr;
reg [7:0] 	rf_wdata;

wire [7:0]	PC;
wire 		    halt;

wire [7:0]  dbg_r0, dbg_r1, dbg_r2, dbg_r3;
wire [2:0]	dbg_state;


// Demo Parameters
integer N   		    = 5;
integer cycle_cnt 	= 0;
integer MAX_CYCLES 	= 200;

// Opcodes (ISA)
localparam [3:0] OP_ADDI = 4'hB;
localparam [3:0] OP_SUB  = 4'hC;
localparam [3:0] OP_BNE  = 4'h9;
localparam [3:0] OP_HALT = 4'hF;

// DUT instance 
mini_cpu_wrapper_sim dut(

				              .clk(clk),
                      .rst(rst),
				              .en(en),
				
                      .imem_we(imem_we),
                      .imem_addr(imem_addr),
                      .imem_wdata(imem_wdata),
				
                      .rf_wdata(rf_wdata),
                      .rf_addr(rf_addr),
                      .rf_we(rf_we),
				
				              .PC(PC),
				              .halt(halt),
				
				              .dbg_r0(dbg_r0),
				              .dbg_r1(dbg_r1),
				              .dbg_r2(dbg_r2),
				              .dbg_r3(dbg_r3),
			              	.dbg_state(dbg_state)
			              	);

// 100MHz Clock Signal
always #5 clk = ~clk;

// Tasks
task automatic imem_write(input [7:0] addr, input [15:0] data);
	  begin
	  	imem_we 	= 1'b1;
		  imem_addr	= addr;
		  imem_wdata	= data;
	  	@(posedge clk);
	  	imem_we 	= 1'b0;
		  @(posedge clk);
  	end
endtask

task automatic rf_write(input [1:0] addr, input [7:0] data);
	  begin
	  	rf_we 	= 1'b1;
	  	rf_addr	= addr;
	  	rf_wdata	= data;
	  	@(posedge clk);
	  	rf_we 	= 1'b0;
	  	@(posedge clk);
  	end
endtask

task automatic print_summary(input reg pass);
	  begin
		  $display("====================================");
		  $display(" Mini CPU Demo - Execution Summary");
	  	$display("------------------------------------");
	  	$display(" Result 				= %s", pass ? "PASS" :  "FAIL");
	  	$display(" Initial N 			= %0d", N);
		  $display(" Cycles until HALT 	= %0d", cycle_cnt);
	  	$display(" Final PC 			= %0d", PC);
	  	$display(" Final R0 			= %0d (expected 0)", dbg_r0);
	  	$display(" Final R2 			= %0d(expected %0d)", dbg_r2, N);
	  	$display("====================================");
	  end
endtask

	
initial begin

	rst = 1'b1;
	en  = 1'b0;
	
	imem_we = 1'b0;
	imem_addr = 8'b0;
	imem_wdata = 16'b0;
	
	rf_we = 1'b0;
	rf_addr = 2'b0;
	rf_wdata = 8'b0;
	
	// Holding rst for few cycles
	repeat (4) @(posedge clk);
	
	// Load program while CPU disabled (en = 0)
	// Program:
	// 0: ADDI R2, +1
	// 1: SUB R0, R1
	// 2: BNE R0, R3, -3 (imm8 = 0xFD)
	// 3: HALT
	
	imem_write(8'd0, {OP_ADDI, 2'b10, 2'b00, 8'd1});
	imem_write(8'd1, {OP_SUB, 2'b00, 2'b01, 8'd0});
	imem_write(8'd2, {OP_BNE, 2'b00, 2'b11, 8'hFD});
	imem_write(8'd3, {OP_HALT, 2'b00, 2'b00, 8'd0});
	
	rst = 1'b0;
	repeat (2) @(posedge clk);
	
	// R0 = N, R1 = 1, R2 = 0, R3 = 0
	rf_write(2'b00, N[7:0]);
	rf_write(2'b01, 8'd1);
	rf_write(2'b10, 8'd0);
	rf_write(2'b11, 8'd0);
	
	
	
	// CPU Start here:
	en = 1'b1;
	
  $display("Starting CPU demo: N = %0d", N);
	
end
	
// Monitor: HALT + Timeout + Cycle count
always @(posedge clk)
    begin
	    if (!rst && en && !halt)
		    cycle_cnt = cycle_cnt + 1;
	
	    if (halt)
		      begin
			        repeat (2) @(posedge clk);
			
			        if ((dbg_r0 == 8'd0) && (dbg_r2 == N[7:0]))
				          begin	
					            $display("PASS: HALT reached with correct results (R0 = 0, R2 = %0d).", N);
					            print_summary(1'd1);
				          end
			        else
				          begin
					            $display("FAIL: HALT reached but result are wrong.");
					            $display(" R0 =%0d (exp 0), R2 = %0d (exp %0d)", dbg_r0, dbg_r2, N);
					            print_summary(1'd0);
				          end
				
			            $finish;
		      end
	
	    //Timeout
	    else if (cycle_cnt >= MAX_CYCLES)
		      begin
			        $display("FAIL: Timeout - CPU did not halt within %0d cycles.", MAX_CYCLES);
			        print_summary(1'd0);
			        $finish;
		      end
  end

endmodule
	
`default_nettype wire
