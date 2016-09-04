module LoadBox(input [31:0]entrada, input load, output [31:0]saida);

	always@(*) begin
		if (load == 0) begin 					// Load Byte
			saida[31:8] <= 24'b0; 
			saida[7:0] <= entrada[7:0]; 		// Preenche os primeiros 24 bits com 0 e o resto com os valores do dado
		end else if (load == 1) begin 			// Load Halfword
			saida[31:16] <= 16'b0;
			saida[15:0] <= entrada[15:0]; 		// Preenche os primeiros 16 bits com 0 e o resto com os valores do dado
		end 
	end
	
endmodule 