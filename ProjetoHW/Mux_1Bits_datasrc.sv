module Mux_1Bits_datasrc(input [31:0]entrada1, input [31:0]entrada2, input datasrc, output [31:0]saida);

	always@(*) begin
		if(datasrc == 1'b0) begin 			// 0 - StoreWord
			saida = entrada1; 
		end else if(datasrc == 1'b1) begin  // 1 - StoreHalf/StoreByte
			saida = entrada2; 				
		end
	end	

endmodule
