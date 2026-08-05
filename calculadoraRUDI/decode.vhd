-- Arquitetura e Organizacao de Computadores
-- Autor: Roberto de Matos
-- Decodificador do processador didático Rudi.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decode is
  port (
    opcode          : in std_logic_vector (1 downto 0);
    sel, wr_acc, op : out std_logic
  );
end entity;

architecture struct of decode is
begin	

	process(opcode)
	begin
		-- valores padrão
		sel 	 <= 'X';
		wr_acc <= 'X';
		op 	 <= 'X';
	
		-- case para alterar valores dos sinais
		case opcode is
			when "00" => wr_acc <= '0';
			when "01" => sel 	  <= '0';
							 wr_acc <= '1';
			when "10" => sel    <= '1';
							 wr_acc <= '1';
							 op	  <= '0';
			when "11" => sel    <= '1';
							 wr_acc <= '1';
							 op	  <= '1';
	   end case;
	end process;
								
					  
end architecture;
