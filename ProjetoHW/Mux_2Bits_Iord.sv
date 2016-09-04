module Mux_2Bits_Iord(input [31:0]pc, input [31:0]aluout, input [1:0]Iord, output logic [31:0]saida);

	always@(*) begin
		if(Iord == 2'b00) begin 			
			saida = pc;  					// saida = PC
		end else if(Iord == 2'b01) begin 	
			saida = {24'b0,8'b11111110}; 		// saida = 254
		end else if(Iord == 2'b10) begin
			saida = {24'b0,8'b11111111}; 		// saida = 255
		end else if(Iord == 2'b11) begin
			saida = aluout; 					// saida = AluOut
		end
	end	

endmodule 