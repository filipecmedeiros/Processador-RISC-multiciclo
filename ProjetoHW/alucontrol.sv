module alucontrol(input [5:0]funct, input [2:0] opalu, output [2:0]op);

	always_ff @(funct) 
	begin
		if (opalu == 3'b000) begin
			op[2:0] = 3'b001;
		end
		else if (opalu == 3'b001) begin
			op[2:0] = 3'b010;
		end
		else begin
			if((funct == 6'b100010)||(funct == 6'b001100)) begin
				op[2:0] = 3'b011; 						// AND, ANDI
			end else if((funct == 6'b100110)||(funct == 6'b001110)) begin
				op[2:0] = 3'b110; 						// XOR, XORI
			end else if((funct == 6'b101010)||(funct == 6'b001010)) begin
				op[2:0] = 3'b111; 						// SLT, SLTI
			end
		end
		/* SEGUNDO A ESPECIFICAÇÃO, FALTAM O NOT E O INCREMENTO */
	end
endmodule
