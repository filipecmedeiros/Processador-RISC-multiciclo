module Shiftbox(input [31:0]entrada1, input [31:0]entrada2, input [4:0]shamt, input [2:0]shift, output logic [31:0]saida);

	always@(*) begin								// >>> - Shift Aritmético >> - Shift Lógico
		if(shift == 3'b000)	begin					// 0
			saida <= entrada1 << shamt; 			// SLL 	rd = rt << shamt
		end	
		else if (shift == 3'b001) begin				// 1
			saida <= entrada1 << entrada2; 			// SLLV rd = rt << rs
		end 
		else if (shift == 3'b010) begin				// 2
			saida <= entrada1 >>> shamt; 			// SRA 	rd = rt >>> shamt
		end 
		else if (shift == 3'b011) begin				// 3
			saida <= entrada1 >>> entrada2; 		// SRAV rd = rt >>> rs
		end 											
		else if (shift == 3'b100) begin				// 4
			saida <= entrada1 >> shamt;				// SRL  rd = rt >> shamt
		end
	end
endmodule