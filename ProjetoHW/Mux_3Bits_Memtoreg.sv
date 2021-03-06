module Mux_3Bits_Memtoreg(input [31:0]entrada1, input [31:0]entrada2, input [31:0]entrada3, input [31:0]entrada4, input [31:0]entrada5, input [31:0]entrada6, input [31:0]entrada7, 
						  input [2:0]memtoreg, output logic [31:0]saida);

	always@(*) begin
		if(memtoreg == 3'b000) begin 			
			saida = entrada1;  					// saida = Registrador B
		end else if(memtoreg == 3'b001) begin 	
			saida = entrada2; 					// saida = Load
		end else if(memtoreg == 3'b010) begin
			saida = entrada3; 					// saida = ShiftBox
		end else if(memtoreg == 3'b011) begin
			saida = entrada4; 					// saida = PC
		end else if(memtoreg == 3'b100) begin
			saida = entrada5;					// saida = SignExtendLui
		end else if(memtoreg == 3'b101) begin
			saida = entrada6;					// saida = AluOut
		end else if(memtoreg == 3'b110) begin
			saida = entrada7; 					// saida = MDR
		end else if(memtoreg == 3'b111) begin
			saida = 8'b11100011;				// saida = 227
		end
	end
endmodule 