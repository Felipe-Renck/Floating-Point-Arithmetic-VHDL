----------------------------------------------------------------------------------
-- Implementação de Somador e Sutrator em Ponto Flutuante de Precisão Simples
-- Apenas um exemplo comportamental, não  representa a melhor forma de 
--               implementação e controle do hardware gerado
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all; 



entity projIEEE is
    Port ( x : in  	STD_LOGIC_VECTOR (31 downto 0);
           y : in  	STD_LOGIC_VECTOR (31 downto 0);
			  t : in  	STD_LOGIC; --1-soma, 0-subtracao
           z : out  STD_LOGIC_VECTOR (31 downto 0));
end projIEEE;



architecture Behavioral of projIEEE is

begin

	process(x,y,t)
		variable x_mantissa 	: STD_LOGIC_VECTOR (31 downto 0);
		variable x_exponent 	: STD_LOGIC_VECTOR (7 downto 0);
		variable x_sign 		: STD_LOGIC;

		variable y_mantissa 	: STD_LOGIC_VECTOR (31 downto 0);
		variable y_exponent 	: STD_LOGIC_VECTOR (7 downto 0);
		variable y_sign 		: STD_LOGIC;

		variable z_mantissa 	: STD_LOGIC_VECTOR (22 downto 0);
		variable z_exponent 	: STD_LOGIC_VECTOR (7 downto 0);
		variable z_sign 		: STD_LOGIC;

		variable aux_shift 	: STD_LOGIC_VECTOR (7 downto 0);
		variable aux_cur   	: STD_LOGIC_VECTOR (7 downto 0);
		
		variable aux_mantica	: STD_LOGIC_VECTOR (31 downto 0);
   begin

		--o x será sempre o de maior expoente
		if (x(30 downto 23) < y(30 downto 23)) then
			x_mantissa 	:= '1' & y(22 downto 0) & "00000000";
			x_exponent 	:= y(30 downto 23);
			x_sign 		:= y(31);
			
			y_mantissa 	:= '1' & x(22 downto 0) & "00000000";
			y_exponent 	:= x(30 downto 23);
			y_sign 		:= x(31);
		else
			x_mantissa 	:= '1' & x(22 downto 0) & "00000000";
			x_exponent 	:= x(30 downto 23);
			x_sign 		:= x(31);
			
			y_mantissa 	:= '1' & y(22 downto 0) & "00000000";
			y_exponent 	:= y(30 downto 23);
			y_sign 		:= y(31);
		end if;


		--faz shift no número menor
		aux_cur := (others => '0');
		aux_shift := x_exponent - y_exponent;
		while (aux_cur < aux_shift) loop
			y_mantissa := '0' & y_mantissa(31 downto 1);
			aux_cur := aux_cur + 1;
		end loop;

		
		--calcula a manticia
		aux_mantica := (others => '0');
		
		
		if (t = '1') then --soma
			--se forem iguais soma (para soma)
			if (x_sign = y_sign) then
				aux_mantica := (x_mantissa + y_mantissa);
			else --se não, subtrair
				aux_mantica := (x_mantissa - y_mantissa);
			end if;
		else --subtracao
			if (x_sign = y_sign) then
				aux_mantica := (x_mantissa - y_mantissa);
			else
				aux_mantica := (x_mantissa + y_mantissa);
			end if;
		end if;
		
		
		--coloca o sinal da maior no retorno
		z_sign := x_sign;
		
		
		--coloca o expoente do maior no retorno
		z_exponent := x_exponent;
		
		
		--normaliza o resultado
		for i in 0 to 31 loop
			if not (aux_mantica(31) = '1') then
				aux_mantica := aux_mantica(30 downto 0) & '0';
				z_exponent  := z_exponent - 1;
			end if;
		end loop;
		z_mantissa := aux_mantica(31 downto 9);
		
		
		
		
		--coloca os resultados na saida
		z(22 downto 0)  <= z_mantissa;
		z(30 downto 23) <= z_exponent;
		z(31)				 <= z_sign;

   end process;
	
end Behavioral;