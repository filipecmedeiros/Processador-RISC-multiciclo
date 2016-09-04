module cpu (
  output logic [2:0] ALUop, 			// Sinal de controle ALU
  output logic WriteALUout, 			// Sinal Registrador ALUOUT
  output logic ALUsrcA, 				// Sinal Mux Registrador A 
  output logic [1:0] ALUsrcB, 			// Sinal Mux Registrador B
  output logic WriteA,					// Sinal Registrador A
  output logic WriteB,					// Sinal Registrador B
  output logic Reset,					// Sinal de Reset					
  output logic EPC_Write, 				// Sinal Registrador EPC
  output logic IRWrite, 				// Sinal de controle Instruções
  output logic WriteMDR,				// Sinal de controle MDR
  output logic Mem,						// Sinal de controle Memória
  output logic [1:0] IorD, 				// Sinal Mux Memória
  output logic DataDST,					// Sinal Mux Memória
  output logic [2:0] MemtoReg,			// Sinal Mux Registradores
  output logic [2:0] Shift,				// Sinal de controle Shift
  output logic Store, 					// Sinal de controle Store
  output logic Load,					// Sinal de controle Load
  output logic [2:0] PCSource, 			// Sinal Mux PC
  output logic [1:0] RegDST, 			// Sinal Mux Registradores
  output logic RegWrite, 				// Sinal de controle Banco Registradores
  output logic PCWriteCond, 			// Sinal de escrita no PC
  output logic PCWrite,					// Sinal de escrita no PC
//  output logic [5:0] Estado, 			// Estado
//  input logic [4:0] SHAMT, ------------ Inutil
//  input logic BZero, 		 ------------ Mais Inutil
  input logic [5:0] OP,
  input logic [5:0] FUNCT,
  input logic [5:0] VetorFlags,
  input logic clk 
);
  
					// Declaração dos Estados
  enum logic [5:0] {
    Inicial	       	= 6'b000000, // Reset 
    EscrevePilha   	= 6'b000001, // Escrever no Reg. 29
    Busca	      	= 6'b000010, // Calculo do valor do PC
    EstadoIRWrite  	= 6'b000011, // IRWrite
    Decodifica     	= 6'b000100, // Descodifica a instrução
    CalculoEnd     	= 6'b000101, // Calcula Endereço
    BuscaMem	   	= 6'b000110, // Primeiro Estado Load
    FirstSBSH      	= 6'b000111, // Primeiro Estado Store B/H
    LoadW			= 6'b001000, // Estado Load Word
    LoadH			= 6'b001001, // Estado Load Half
    LoadB		  	= 6'b001010, // Estado Load Byte
    StoreB       	= 6'b001011, // Estado Store Byte
    StoreH          = 6'b001100, // Estado Store Half 
    WriteMem	   	= 6'b001101, // Escrita na memória depois dos Store
    StoreW         	= 6'b001110, // Estado Store Word
    TipoRALU        = 6'b001111, // Estado Calculo Tipo R
    WriteRegALU 	= 6'b010000, // Escreve no Registrador PósALU
    TipoIALU        = 6'b010001, // Estado Calculo Tipo I
    Rotacao        	= 6'b010010, // Estado SHIFTS
    WriteRegShift  	= 6'b010011, // Escrita Registrador PósShift
    EstadoLUI      	= 6'b010100, // Estado do Lui
    BeqBne      	= 6'b010101, // Estado do BEQ/BNE
    JumpReg      	= 6'b010110, // JR
    EstadoJal		= 6'b010111, // JAL
    EstadoJump      = 6'b011000, // Jump
    EstadoRte      	= 6'b011001, // Rte
    Except   	    = 6'b011010, // Estado principal Exceção
    ExceptOpcode	= 6'b011011, // Opcode Inexistente
    ExceptOver     	= 6'b011100, // Overflow
    WritePCExcept   = 6'b011101, // Escreve no PC depois da Exceção
    Espera 			= 6'b011110, // NOP
    LoopBreak 		= 6'b011111, // LoopBreak
    EsperaI			= 6'b100000
  } state, nextstate;

  // OP 
  parameter [11:0] //parametros para OPFUNCT
//TIPO R 		  xxxxxxooooo 6 bits Funct - 6 Bits Shant
	ADD		= 12'b000000100000, //0X20
	ADDU	= 12'b000000100001, //0X21
	AND		= 12'b000000100100, //0X24
	JR		= 12'b000000001000, //0X8
	SLL		= 12'b000000000000, //0X0
	SLLV	= 12'b000000000100, //0X4
	SLT		= 12'b000000101010, //0X2A
	SRA		= 12'b000000000011, //0X3
	SRAV	= 12'b000000000111, //0X7
	SRL		= 12'b000000000010, //0X2
	SUB		= 12'b000000100010, //0X22
	SUBU	= 12'b000000100011, //0X23
	XOR		= 12'b000000100110, //0X26
	BREAK	= 12'b000000001101, //0XD
	NOP		= 12'b000000000000, //0X0
	RTE		= 12'b010000010000; //0X10
	

//TIPO I/J
  parameter [5:0] // parametros para OP
	ADDI	= 6'b001000, //0x8
	ADDIU	= 6'b001001, //0x9
	ANDI	= 6'b001100, //0xc
	BEQ		= 6'b000100, //0x4
	BNE		= 6'b000101, //0x5
	LB		= 6'b100000, //0x20
	LH		= 6'b100001, //0x21
	LUI		= 6'b001111, //0xf
	LW		= 6'b100011, //0x23
	SB		= 6'b101000, //0x28
	SH		= 6'b101001, //0x29
	SLTI	= 6'b001010, //0xa
	SW		= 6'b101011, //0xb
	XORI	= 6'b001110, //0xe
	J		= 6'b000010, //0x2
	JAL		= 6'b000011; //0x3

parameter [2:0] // Parametros para a ALU
	ULA_ADD 	= 3'b001,
	ULA_SUB		= 3'b010,
	ULA_AND		= 3'b011,
	ULA_INC		= 3'b100,
	ULA_NOT		= 3'b101,
	ULA_XOR		= 3'b110,
	ULA_CMP		= 3'b111,
	ULA_MOV		= 3'b000;
	
parameter [2:0] // Declaração dos Shifts
	ShiftLeft  	= 3'b000,
	ShiftLeftV 	= 3'b001,
	ShiftRightA	= 3'b010,
	ShiftRightAV= 3'b011,
	ShiftRightL = 3'b100;
	
  logic [11:0] OPFUNCT; 		// 12 bits

//--------------------------------------------------------------------------- |
// O bloco síncrono do código é responsável pela troca de estados. Tendo de   |
// no bloco que segue abaixo. Sempre com alterações na subida do clock. 	  |
//--------------------------------------------------------------------------- |

	always_ff @(posedge clk)
	begin
	state <= Inicial;
	nextstate <= EscrevePilha;
	// OOOOOOFFFFFF
	OPFUNCT[11:6] = OP;
	OPFUNCT[5:0] = FUNCT;
    case(state)
    
	  Inicial		: begin // Estado de Reset
		begin
		  nextstate <= EscrevePilha;
		end
	  end
	  
      EscrevePilha         : begin //Segundo a executar
        begin
          nextstate <= EsperaI;
        end
      end
      
      EsperaI     : begin // PC + 4
        begin
          nextstate <= Busca;
        end
      end

      Busca         : begin
        begin
          nextstate <= EstadoIRWrite;
        end
      end

      EstadoIRWrite    : begin // Estado Inicial das operações, depois de decodificar a instrução
        begin
          nextstate <= Decodifica ;
        end
      end

	//A decodificação de cada instrução acontece a partir daqui. 
	
      Decodifica    : begin
       	// Loads/Stores
		if ((OP == LW) || 
			(OP == LH) || 
			(OP == LB) || 
			(OP == SW) || 
			(OP == SH) || 
			(OP == SB)) begin
		  nextstate <= CalculoEnd;
		end
	
		// Operações tipo R
		else if ((OPFUNCT == ADD) || 
				(OPFUNCT == SUB) || 
				(OPFUNCT == XOR) || 
				(OPFUNCT == AND) || 
				(OPFUNCT == ADDU) || 
				(OPFUNCT == SUBU) || 
				(OPFUNCT == SLT))
		begin
			  nextstate <= TipoRALU;
		end

		// Operações tipo I
		else if ((OP == ADDIU) || 
				(OP == ANDI) || 
				(OP == XORI) ||
				(OP == ADDI) || 
				(OP == SLTI)) 
		begin
			nextstate <= TipoIALU;
		end
		
		// LUI
		else if (OP == LUI) begin
		  nextstate <= EstadoLUI;
		end
		
		// NOP
		else if ((OPFUNCT == NOP)) begin
		  nextstate <= Busca;
		end
				
		// BeqBne
		else if ((OP == BEQ) || 
				 (OP == BNE)) begin
		  nextstate <= BeqBne;
		end
		
		// RTE
		else if (OPFUNCT == RTE) begin
		  nextstate <= EstadoRte;
		end
		
		// Shifts
		else if ((OPFUNCT == SRL) || 
				 (OPFUNCT == SRA) || 
				 (OPFUNCT == SLL) || 
				 (OPFUNCT == SLLV) || 
				 (OPFUNCT == SRAV)) begin
		  nextstate <= Rotacao;
		end
		
		// Jump Register
		else if (OPFUNCT == JR) begin
		nextstate <= JumpReg;
		end
		
		// Jal
		else if (OP == JAL) begin
		  nextstate <= EstadoJal;
		end

		// Loop/Break
		else if (OPFUNCT == BREAK) begin
		  nextstate <= LoopBreak;
		end
		
		//Jump
		else if (OP == J) begin
		  nextstate <= EstadoJump;
		end
		
		// Deu merda no OPCODE
		else begin
		  nextstate <= Except;
		end
      end
      
		CalculoEnd	: begin
			if((OP == LW) || (OP == LH) || (OP == LB))
				begin
					nextstate <= BuscaMem;
				end
			else if((OP == SB) || (OP == SH))
				begin 
					nextstate <= FirstSBSH;
				end
			else
				begin
					nextstate <= StoreW;
				end
			end
			
		BuscaMem	: begin
				nextstate <= Espera;
			end
			
		FirstSBSH	: begin
				nextstate <= Espera;
			end
			
		Espera		: begin
			if(OP == LW)
				begin
					nextstate <= LoadW;
				end
			else if (OP == LH)
				begin
					nextstate <= LoadH;
				end
			else if (OP == LB)
				begin
					nextstate <= LoadB;
				end
			else if (OP == SB)
				begin 
					nextstate <= StoreB;
				end
			else if (OP == SH)
				begin
					nextstate <= StoreH;
				end
			end
		StoreB		: begin
			begin
				nextstate <= WriteMem;
			end
		end
		
		StoreH		: begin
				nextstate <= WriteMem;
		end
		
		// Operações tipo R
		TipoRALU 	: begin
				if(VetorFlags[1] == 0) begin // Não foi dessa vez
					nextstate <= WriteRegALU;
				end
				else if(VetorFlags[1] == 1) begin
					nextstate <= Except;
				end
			end

		// Operações tipo I
		TipoIALU		: begin
			//ALUop[2:0] = 3'b001;
			if (VetorFlags[1] == 0) begin 	// Caso não role Overflow, só escreve normalmente
					nextstate <= WriteRegALU;
			end
				else if (VetorFlags[1] == 1) begin 
					nextstate <= Except; // Se deu merda, vai pra tratamento
				end
			end
		
		// Bloco de Exceções
		Except		: begin
			if(VetorFlags[0] == 1) begin
				nextstate <= ExceptOpcode;
			end
			else if(VetorFlags[1] == 1) begin
				nextstate <= ExceptOver;
			end
		end
		
		ExceptOpcode	: begin
				nextstate <= WritePCExcept;
			end
			
		ExceptOver	: begin
				nextstate <= WritePCExcept;
			end
			
		Rotacao		: begin
				nextstate <= WriteRegShift;
		end
		// Estado Final do JAL
		EstadoJal 		: begin
			begin
				nextstate <= EstadoJump;
			end
		end
    endcase
    state <= nextstate;
end	

/*--------------------------------------------------------------------------|
 O bloco combinacional deve setar os sinais de saida da unidade de controle |
 de acordo com o estado atual. Dessa forma, a partir daqui isso acontece.	|
----------------------------------------------------------------------------|*/
/*
	always_comb begin
	  state = nextstate;
	end
	*/
	always_comb
	begin					// RESET
	WriteALUout = 0; 
	ALUsrcA = 1; 
	ALUsrcB[1:0] = 2'b00; 
	RegDST[1:0] = 2'b00; 
	MemtoReg[2:0] = 3'b000;
	PCSource[2:0] = 3'b000; 
	Shift[2:0] = 3'b000;
	IorD[1:0] = 2'b00; 
	WriteA = 0;
	WriteB = 0; 
	Reset = 0; 
	EPC_Write = 0; 
	IRWrite = 0; 
	Mem = 0;
	DataDST = 0;
	Store = 0;
	Load = 0;
	WriteMDR = 0; 
	PCWrite = 0; 
	PCWriteCond = 0;
	RegWrite = 0;
	ALUop [2:0] = 3'b000; 

	case (nextstate)

	EscrevePilha         : begin
		RegDST[1:0] 	= 2'b10;
		MemtoReg[2:0]	= 3'b111; 
		RegWrite 		= 1'b1;	
	end

	Busca		: begin
		IorD[1:0] 		= 2'b00;
		Mem		 		= 0;
		ALUsrcA 		= 0;
		ALUsrcB[1:0] 	= 2'b01;
		ALUop[2:0] 		= 3'b001;
		PCSource[2:0] 	= 3'b010;
		PCWrite 		= 1;
	end

	EsperaI 	: begin 			// Faz nada
		end
		
	EstadoIRWrite		: begin
		IRWrite 	= 1;
	end

	Decodifica    : begin
		WriteA 			= 1;
		WriteB 			= 1;
		WriteALUout 	= 1;
		ALUop[2:0] 		= 3'b001;
		ALUsrcA 		= 0;
		ALUsrcB[2:0] 	= 2'b11;
	end

	EstadoJump		: begin
		PCSource[2:0] 	= 3'b000;
		PCWrite 		= 1;
	end

	EstadoRte    	: begin
		PCSource[2:0] 	= 3'b100;
		PCWrite 		= 1;
	end

	EstadoJal		: begin
		RegDST[1:0] 	= 2'b01;
		MemtoReg[2:0] 	= 3'b011;
		RegWrite 		= 1;
	end
	
	JumpReg 		: begin	
		PCSource[2:0] 	= 3'b011;
		PCWrite 		= 1;
	end
	
	BeqBne 			: begin
		ALUsrcA 		= 1;
		ALUsrcB[1:0] 	= 2'b00;
		ALUop[2:0] 		= 3'b010;
		PCSource[2:0] 	= 3'b001;
		PCWriteCond 	= 1;
	end
	
	EstadoLUI    : begin
		RegDST[1:0] 		= 2'b00;
		MemtoReg[2:0]		= 3'b100;
		RegWrite			= 1;
	end
	
	Rotacao        : begin
		MemtoReg[2:0] 	= 3'b010;
		RegDST[1:0] 	= 2'b11;
		if(OPFUNCT == SLL) begin
			Shift[2:0] 	= ShiftLeft;
		end else if(OPFUNCT == SRA) begin
			Shift[2:0] 	= ShiftRightA;
		end else if(OPFUNCT == SRL) begin
			Shift[2:0] 	= ShiftRightL;
		end else if(OPFUNCT == SLLV) begin
			Shift[2:0] 	= ShiftLeftV;
		end else if(OPFUNCT == SRAV) begin
			Shift[2:0] 	= ShiftRightAV;
		end
	end
	
	WriteRegShift	: begin
		RegWrite	= 1;
	end
	
	TipoRALU		: begin
		ALUsrcA 			= 1;
		ALUsrcB[1:0] 		= 2'b00;
		WriteALUout 		= 1;
		if(OPFUNCT == ADD) begin
			ALUop 			= ULA_ADD;
		end else if(OPFUNCT == SUB) begin
			ALUop 			= ULA_SUB;
		end else if(OPFUNCT == AND) begin
			ALUop 			= ULA_AND;
		end else if(OPFUNCT == XOR) begin
			ALUop 			= ULA_XOR;
		end
	end
	
	TipoIALU		: begin
		ALUsrcA 			= 1;
		ALUsrcB[1:0] 		= 2'b10;
		WriteALUout 		= 1;
		if((OP == ADDI)||(OP == ADDIU)) begin
			ALUop 			= ULA_ADD;
		end else if(OPFUNCT == ANDI) begin
			ALUop 			= ULA_AND;
		end else if(OPFUNCT == XORI) begin
			ALUop 			= ULA_XOR;
		end else if(OPFUNCT == SLTI) begin
			ALUop 			= ULA_CMP;
		end
	end
	
	WriteRegALU		: begin
		MemtoReg[2:0] 	= 3'b101;
		RegDST[1:0]		= 2'b11;
		RegWrite		= 1;
	end
	
	Except		: begin
		ALUsrcA		= 0;
		ALUsrcB 	= 2'b01;
		ALUop[2:0]	= 3'b010;
		EPC_Write	= 1;
	end
	
	ExceptOpcode	: begin
		IorD[1:0] 	= 2'b01;
		Mem			= 0;
		WriteMDR 	= 1;
	end
	
	ExceptOver 	: begin
		IorD[1:0] 	= 2'b10;
		Mem		 	= 0;
		WriteMDR 	= 1;
	end
	
	WritePCExcept 	: begin
		PCSource[2:0]	= 3'b100;
		PCWrite			= 1;
	end
	
	CalculoEnd 		: begin
		ALUsrcA 		= 1;
		ALUsrcB[1:0]	= 2'b11;
		ALUop[2:0] 		= 3'b001;
		WriteALUout		= 1;
	end 
	
	BuscaMem		: begin
		IorD[1:0]	= 2'b11;
		Mem		 	= 0;	
		WriteMDR	= 1;
	end
	
	LoadW 		: begin
		MemtoReg[2:0] 	= 3'b110;
		RegWrite 		= 1;
		RegDST[1:0] 	= 2'b00;
	end
	
	LoadH		: begin
		Load 			= 1;
		RegDST[1:0] 	= 2'b00;
		MemtoReg[2:0]	= 3'b001;
	end
	
	LoadB 		: begin
		Load 			= 0;
		RegDST[1:0] 	= 2'b00;
		MemtoReg[2:0]	= 3'b001;
	end
	
	FirstSBSH 		: begin
		IorD[1:0] 	= 2'b11;
		Mem		 	= 0;
	end
	
	StoreB		: begin
		WriteMDR 	= 1;
		Store 	 	= 0;
	end
	
	StoreH		: begin
		WriteMDR 	= 1;
		Store		= 1;
	end
	
	WriteMem 	: begin
		DataDST 	= 1;
		Mem		 	= 1;
	end
	
	endcase
end
endmodule
