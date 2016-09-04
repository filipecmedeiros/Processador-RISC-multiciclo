module StoreBox(input [31:0]entrada, input [31:0]entrada2, input store, output logic [31:0]saida);

	always@(*) begin		
	if (store == 1'b0) begin 				// Store Byte
		saida[31:8] <= entrada2[31:8]; 		// Preenche os 24 bits da saída com os 24 bits menos significativos da memória
		saida[7:0] <= entrada[7:0]; 		// Copia os 8 bits mais significativos da entrada para a saída
											
	end 
	if (store == 1'b1) begin				// Store Halfword
		saida[31:16] <= entrada2[31:16];	// Preenche os 16 bits da saída com os 16 bits menos significativos da memória
		saida[15:0] <= entrada[15:0];		// Copia os 16 bits mais significativos da entrada para a saída
	end
	end	

endmodule