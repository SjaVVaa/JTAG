module JTAG_M 
	(
		input TDI, CLK,
		output reg TCK, TDO, TMS		
	);
integer i_len;
assign TCK = CLK;

/*
EXAMPLE WRITE COMMAND (for DATA use COMM_START_DR())
RESET();
COMM_RES(); state is IDLE
COMM_START_IR(); state is SHIFT_IR
COMM_SHIFT(xxx, yyyy); state is EXIT1_IR
		for finish command								for pause									for start new command
COMM_EXIT(); state is IDLE							COMM_PAUSE(xxx); state is EXIT2_IR					COMM_PAUSE(xxx);
													COMM_EXIT();  state is IDLE							COMM_NEW();
																										COMM_SHIFT(xxx, yyyy);



*/
task RESET();
	begin
		TDO = 1'bz;
		TMS = 1'b1;
	end
endtask

task COMM_RES();
	begin
		TDO = 1'bz;
		TMS = 1'b1;
		@(negedge CLK);
		@(negedge CLK);
		@(negedge CLK);
		@(negedge CLK);
		@(negedge CLK);
		@(negedge CLK);
		TMS = 1'b0;
	end
endtask

task COMM_START_IR();
	begin
		TDO = 1'bz;
		@(negedge CLK);
		TMS = 1'b1;
		@(negedge CLK);
		@(negedge CLK);
		TMS = 1'b0;
		@(negedge CLK);
	end
endtask

task COMM_START_DR();
	begin
		TDO = 1'bz;
		@(negedge CLK);
		TMS = 1'b1;
		@(negedge CLK);
		TMS = 1'b0;
		@(negedge CLK);
	end
endtask

task COMM_SHIFT();
	input [7:0] LEN; //it is variable set count bit in command message
	input [15:0] COMM; // it is variable set command
	begin
		for (i_len = LEN; i_len > 0; i_len = i_len -1)
			begin
				@(negedge CLK);
				TMS = 1'b0;
				TDO = COMM[i_len];
			end
		@(negedge CLK);
		TMS = 1'b1;
		TDO = COMM[0];
	end
endtask

task COMM_EXIT();
	begin
		@(negedge CLK);
		TMS = 1'b1;
		TDO = 1'bz;
		@(negedge CLK);
		TMS = 1'b0;
	end
endtask

task COMM_NEW();
	begin
		@(negedge CLK);
		TMS = 1'b0;
		TDO = 1'bz;
	end
endtask

task COMM_PAUSE();
	input [7:0] LEN; //it is variable set count bit in pause
	begin
		for (i_len = 0; i_len <LEN; i_len =i_len +1)
			begin
				@(negedge CLK);
				TMS = 1'b0;
				TDO = 1'bz;
			end
		
	end
endtask


endmodule