--------------------------------------------------------------------------------
-- Title		: Registrador de Deslocamento
-- Project		: CPU Multi-ciclo
--------------------------------------------------------------------------------
-- File			: RegDesloc.vhd
-- Author		: Emannuel Gomes Macêdo <egm@cin.ufpe.br>
--				  Fernando Raposo Camara da Silva <frcs@cin.ufpe.br>
--				  Pedro Machado Manhães de Castro <pmmc@cin.ufpe.br>
--				  Rodrigo Alves Costa <rac2@cin.ufpe.br>
-- Organization : Universidade Federal de Pernambuco
-- Created		: 10/07/2002
-- Last update	: 26/11/2002
-- Plataform	: Flex10K
-- Simulators	: Altera Max+plus II
-- Synthesizers	: 
-- Targets		: 
-- Dependency	: 
--------------------------------------------------------------------------------
-- Description	: Entidade responsável pelo deslocamento de um vetor de 32 
--                bits para a direita e para a esquerda. 
--				  Entradas:
--				  	* N: vetor de 3 bits que indica a quantidade de 
--					deslocamentos   
--				  	* Shift: vetor de 3 bits que indica a função a ser 
--					realizada pelo registrador   
--				  Abaixo seguem os valores referentes à entrada shift e as 
--                respectivas funções do registrador: 
--				  
--				  Shift					FUNÇÃO DO REGISTRADOR
--				  000					faz nada
--				  001					carrega vetor (sem deslocamentos)
--				  010					deslocamento à esquerda n vezes
--				  011					deslocamento à direita lógico n vezes
--				  100					deslocamento à direita aritmético n vezes
--				  101					rotação à direita n vezes
--				  110					rotação à esquerda n vezes
--------------------------------------------------------------------------------
-- Copyright (c) notice
--		Universidade Federal de Pernambuco (UFPE).
--		CIn - Centro de Informatica.
--		Developed by computer science undergraduate students.
--		This code may be used for educational and non-educational purposes as 
--		long as its copyright notice remains unchanged. 
--------------------------------------------------------------------------------
-- Revisions		: 2
-- Revision Number	: 2.0
-- Version			: 1.2
-- Date				: 26/11/2002
-- Modifier			: Marcus Vinicius Lima e Machado <mvlm@cin.ufpe.br>
--				  	  Paulo Roberto Santana Oliveira Filho <prsof@cin.ufpe.br>
--					  Viviane Cristina Oliveira Aureliano <vcoa@cin.ufpe.br>
-- Description		:
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Revisions		: 3
-- Revision Number	: 1.2
-- Version			: 1.3
-- Date				: 08/08/2008
-- Modifier			: João Paulo Fernandes Barbosa (jpfb@cin.ufpe.br)
-- Description		: Os sinais de entrada e saída passam a ser do tipo std_logic.
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


-- Short name: desl
ENTITY RegDesloc IS
		PORT(
			Clk		: IN	STD_LOGIC;	-- Clock do sistema
		 	Reset	: IN	STD_LOGIC;	-- Reset
			Shift 	: IN	STD_LOGIC_vector (2 downto 0);	-- Função a ser realizada pelo registrador 
			N		: IN	STD_LOGIC_vector (2 downto 0);	-- Quantidade de deslocamentos
			Entrada : IN	STD_LOGIC_vector (31 downto 0);	-- Vetor a ser deslocado
			Saida	: OUT	STD_LOGIC_vector (31 downto 0)	-- Vetor deslocado
		);
END RegDesloc;

-- Arquitetura que define o comportamento do registrador de deslocamento
-- Simulation
ARCHITECTURE behavioral_arch OF RegDesloc IS
	
	signal temp		: STD_LOGIC_vector (31 downto 0);	-- Vetor temporário
	
	begin

	-- Clocked process
	process (Clk, Reset)
		begin
			if(Reset = '1') then
				temp <= "00000000000000000000000000000000";

			elsif (Clk = '1' and Clk'event) then
				case Shift is
					when "000" => 						-- Faz nada
						temp <= temp;
					when "001" => 						-- Carrega vetor de entrada, não faz deslocamentos
						temp <= Entrada;
					when "010" =>						-- Deslocamento à esquerda N vezes
						case N is
							when "000" =>				-- Deslocamento à esquerda nenhuma vez
								temp <= temp;
							when "001" =>				-- Deslocamento à esquerda 1 vez
								temp(0) <= '0';
								temp(31 downto 1) <= temp(30 downto 0);
							when "010" =>				-- Deslocamento à esquerda 2 vezes
								temp(1 downto 0) <= "00";
								temp(31 downto 2) <= temp(29 downto 0);
							when "011" =>				-- Deslocamento à esquerda 3 vezes
								temp(2 downto 0) <= "000";
								temp(31 downto 3) <= temp(28 downto 0);
							when "100" =>				-- Deslocamento à esquerda 4 vezes
								temp(3 downto 0) <= "0000";
								temp(31 downto 4) <= temp(27 downto 0);
							when "101" =>				-- Deslocamento à esquerda 5 vezes
								temp(4 downto 0) <= "00000";
								temp(31 downto 5) <= temp(26 downto 0);
							when "110" =>				-- Deslocamento à esquerda 6 vezes
								temp(5 downto 0) <= "000000";
								temp(31 downto 6) <= temp(25 downto 0);
							when "111" =>				-- Deslocamento à esquerda 7 vezes
								temp(6 downto 0) <= "0000000";
								temp(31 downto 7) <= temp(24 downto 0);
						end case;

					-- Deslocamento à direita lógico N vezes
					when "011" =>						
						case n is
							when "000" =>				-- Deslocamento à direita lógico nenhuma vez
								temp <= temp;
							when "001" =>				-- Deslocamento à direita lógico 1 vez
								temp(30 downto 0) <= temp(31 downto 1);
								temp(31) <= '0';
							when "010" =>				-- Deslocamento à direita lógico 2 vezes
								temp(29 downto 0) <= temp(31 downto 2);
								temp(31 downto 30) <= "00";
							when "011" =>				-- Deslocamento à direita lógico 3 vezes
								temp(28 downto 0) <= temp(31 downto 3);
								temp(31 downto 29) <= "000";
							when "100" =>				-- Deslocamento à direita lógico 4 vezes
								temp(27 downto 0) <= temp(31 downto 4);
								temp(31 downto 28) <= "0000";
							when "101" =>				-- Deslocamento à direita lógico 5 vezes
								temp(26 downto 0) <= temp(31 downto 5);
								temp(31 downto 27) <= "00000";
							when "110" =>				-- Deslocamento à direita lógico 6 vezes
								temp(25 downto 0) <= temp(31 downto 6);
								temp(31 downto 26) <= "000000";
							when "111" =>				-- Deslocamento à direita lógico 7 vezes
								temp(24 downto 0) <= temp(31 downto 7);
								temp(31 downto 25) <= "0000000";
						end case;

					-- Deslocamento à direita aritmético N vezes
					when "100" =>						
						case n is
							when "000" =>				-- Deslocamento à direita aritmético nenhuma vez
								temp <= temp;
							when "001" =>				-- Deslocamento à direita aritmético 1 vezes
								temp(30 downto 0) <= temp(31 downto 1);
								temp(31) <= temp(31);
							when "010" =>				-- Deslocamento à direita aritmético 2 vezes
								temp(29 downto 0) <= temp(31 downto 2);
								temp(30) <= temp(31);
								temp(31) <= temp(31);
							when "011" =>				-- Deslocamento à direita aritmético 3 vezes
								temp(28 downto 0) <= temp(31 downto 3);
								temp(29) <= temp(31);
								temp(30) <= temp(31);
								temp(31) <= temp(31);
							when "100" =>				-- Deslocamento à direita aritmético 4 vezes
								temp(27 downto 0) <= temp(31 downto 4);
								temp(28) <= temp(31);
								temp(29) <= temp(31);
								temp(30) <= temp(31);
								temp(31) <= temp(31);
							when "101" =>				-- Deslocamento à direita aritmético 5 vezes
								temp(26 downto 0) <= temp(31 downto 5);
								temp(27) <= temp(31);
								temp(28) <= temp(31);
								temp(29) <= temp(31);
								temp(30) <= temp(31);
								temp(31) <= temp(31);
							when "110" =>				-- Deslocamento à direita aritmético 6 vezes
								temp(25 downto 0) <= temp(31 downto 6);
								temp(26) <= temp(31);
								temp(27) <= temp(31);
								temp(28) <= temp(31);
								temp(29) <= temp(31);
								temp(30) <= temp(31);
								temp(31) <= temp(31);
							when "111" =>				-- Deslocamento à direita aritmético 7 vezes
								temp(24 downto 0) <= temp(31 downto 7);
								temp(25) <= temp(31);
								temp(26) <= temp(31);
								temp(27) <= temp(31);
								temp(28) <= temp(31);
								temp(29) <= temp(31);
								temp(30) <= temp(31);
								temp(31) <= temp(31);
						end case;

					-- Rotação à direita N vezes
					when "101" =>						
						case n is
							when "000" =>				-- Rotação à direita nenhuma vez
								temp <= temp;
							when "001" =>				-- Rotação à direita 1 vez
								temp(30 downto 0) <= temp(31 downto 1);
								temp(31) <= temp(0);
							when "010" =>				-- Rotação à direita 2 vezes
								temp(29 downto 0) <= temp(31 downto 2);
								temp(31 downto 30) <= temp(1 downto 0);
							when "011" =>				-- Rotação à direita 3 vezes
								temp(28 downto 0) <= temp(31 downto 3);
								temp(31 downto 29) <= temp(2 downto 0);
							when "100" =>				-- Rotação à direita 4 vezes
								temp(27 downto 0) <= temp(31 downto 4);
								temp(31 downto 28) <= temp(3 downto 0);
							when "101" =>				-- Rotação à direita 5 vezes
								temp(26 downto 0) <= temp(31 downto 5);
								temp(31 downto 27) <= temp(4 downto 0);
							when "110" =>				-- Rotação à direita 6 vezes
								temp(25 downto 0) <= temp(31 downto 6);
								temp(31 downto 26) <= temp(5 downto 0);
							when "111" =>				-- Rotação à direita 7 vezes
								temp(24 downto 0) <= temp(31 downto 7);
								temp(31 downto 25) <= temp(6 downto 0);
						end case;

					-- Rotação à esquerda N vezes
					when "110" =>						
						case n is
							when "000" =>				-- Rotação à esquerda nenhuma vez
								temp <= temp;
							when "001" =>				-- Rotação à esquerda 1 vez
								temp(0) <= temp(31);
								temp(31 downto 1) <= temp(30 downto 0);
							when "010" =>				-- Rotação à esquerda 2 vezes
								temp(1 downto 0) <= temp(31 downto 30);
								temp(31 downto 2) <= temp(29 downto 0);
							when "011" =>				-- Rotação à esquerda 3 vezes
								temp(2 downto 0) <= temp(31 downto 29);
								temp(31 downto 3) <= temp(28 downto 0);
							when "100" =>				-- Rotação à esquerda 4 vezes
								temp(3 downto 0) <= temp(31 downto 28);
								temp(31 downto 4) <= temp(27 downto 0);
							when "101" =>				-- Rotação à esquerda 5 vezes
								temp(4 downto 0) <= temp(31 downto 27);
								temp(31 downto 5) <= temp(26 downto 0);
							when "110" =>				-- Rotação à esquerda 6 vezes
								temp(5 downto 0) <= temp(31 downto 26);
								temp(31 downto 6) <= temp(25 downto 0);
							when "111" =>				-- Rotação à esquerda 7 vezes
								temp(6 downto 0) <= temp(31 downto 25);
								temp(31 downto 7) <= temp(24 downto 0);
						end case;

					-- Funcionalidade não definida
					when others =>
					-- Faz nada					
				end case;
			end if;
			Saida <= temp;	
	end process;
END behavioral_arch;

