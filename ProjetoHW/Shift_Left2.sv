module Shift_Left2(input [31:0]entrada1, output logic [31:0]saida);

	always@(*) begin
	
		saida[31:0] <= entrada1 << 2; 		// Dá um shift para a esquerda...
	// saida recebe entrada1 rodada 2 vezes
	end	

endmodule
