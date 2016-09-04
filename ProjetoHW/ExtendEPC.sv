module ExtendEPC(input [31:0]entrada, output [31:0]saida);

	always_comb
	begin
		saida[31:8] = 24'b0;			// Extende o tratamento da exceção para ser o novo valor de PC
		saida[7:0] = entrada[7:0]; 		// Preenche a saida com 24 zeros, para eliminar o lixo lido.
	end
	
endmodule 