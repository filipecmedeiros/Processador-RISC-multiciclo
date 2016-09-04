module Shift_Left2_26to28(input [25:0]entrada1, output logic [27:0]saida);

	always_comb
	begin
		saida[27:2] <= entrada1[25:0]; 		// Copia a entrada para os primeiros 26 bits da saida
		saida[1:0] <= 2'b00; 				// e completa os dois bits restantes com 0
	end	

endmodule