module Mux_2Bits_ALUsrcB(input [31:0]entrada1, input [31:0]entrada2, input [31:0]entrada3, input [1:0]ALUsrcB, output logic [31:0]saida);

	always@(*) begin
		if(ALUsrcB == 2'b00) begin 				// 00 - Registrador B
			saida = entrada1; 
		end else if(ALUsrcB == 2'b01) begin  	// 01 - 4 para somar ao PC
			saida = {29'b0,3'b100}; 	 			// 29 bits com 0 e 3 bits com 100			
		end else if(ALUsrcB == 2'b10) begin  	// 10 - Sign Extend
			saida = entrada2;
		end else if(ALUsrcB == 2'b11) begin 	// 11 - Shift Left 2
			saida = entrada3;
	end	
	end
endmodule