module Extensor_LUI_16to32(input [15:0]entrada, output logic [31:0]extendido);

	always_comb							// Combinacional
	begin
		if(entrada[15] == 0) 			// Verifica se é negativo, se não for, preenche com 0
			extendido[31:16] <= 16'b0000000000000000; 	// Entrada de 16 bits
		else 
			extendido[31:16] <= 16'b1111111111111111; 	// Caso seja negativo, preenche com 1
			
		extendido[15:0] <= entrada[15:0]; // Os 16 bits da saida recebem os 16 bits mais significativos da entrada
	end	

endmodule