module Mux_2Bits_RegDST(input [4:0]entrada1, input [4:0]entrada2, input [1:0]RegDST, output logic [4:0]saida);

	always@(*) begin
		if(RegDST == 2'b00) begin 			
			saida = entrada1;  					// saida = RS
		end else if(RegDST == 2'b01) begin 	
			saida = 5'b11111; 					// saida = 31
		end else if(RegDST == 2'b10) begin
			saida = 5'b11101; 					// saida = 29
		end else if(RegDST == 2'b11) begin
			saida = entrada2; 					// saida = RT
		end
	end	

endmodule 