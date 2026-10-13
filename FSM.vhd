library ieee;
use ieee.std_logic_1164.all;
 
entity FSM is
   port
   (
      SW  : in  std_logic_vector (2 downto 0);  
      CLK : in  std_logic;                      
      KEY : in  std_logic_vector (1 downto 0);  
      Led : out std_logic                       
   );
end FSM;
 
 
architecture arch_FSM of FSM is
 
   type estados is (inicio, punto, dash, espacio);
   signal estado    : estados;
   signal reset     : std_logic;
 
   constant T_PUNTO : natural := 25_000_000 - 1;   
   constant T_DASH  : natural := 75_000_000 - 1;   
 
   signal cuenta    : natural range 0 to T_DASH;
   signal idx       : natural range 0 to 3;        
   signal letra     : std_logic_vector(2 downto 0);
   signal key1_prev : std_logic;
	
   function patron (l : std_logic_vector(2 downto 0)) return std_logic_vector is
   begin
      case l is
         when "000"  => return "0100"; --A
         when "001"  => return "1000"; --B
         when "010"  => return "1010"; --C
         when "011"  => return "1000"; --D
         when "100"  => return "0000"; --E
         when "101"  => return "0010"; --F
         when "110"  => return "1100"; --G 
         when others => return  "0000"; --H
      end case;
   end function;
   function largo (l : std_logic_vector(2 downto 0)) return natural is
   begin
      case l is
         when "000"  => return 2;  -- A
         when "001"  => return 4;  -- B
         when "010"  => return 4;  -- C
         when "011"  => return 3;  -- D
         when "100"  => return 1;  -- E
         when "101"  => return 4;  -- F
         when "110"  => return 3;  -- G
         when others  => return 4;  -- H
      end case;
   end function;
 
begin
 
   reset <= not KEY(0);   
	
   process (CLK, reset)
   begin
      if reset = '1' then
         estado    <= inicio;
         cuenta    <= 0;
         idx       <= 0;
         letra     <= "000";
         key1_prev <= '1';
 
      elsif rising_edge(CLK) then
         key1_prev <= KEY(1);
 
         case estado is
 
            when inicio =>
               cuenta <= 0;
               idx    <= 0;
               if key1_prev = '1' and KEY(1) = '0' then   
                  letra <= SW;                            
                  if patron(SW)(3) = '1' then
                     estado <= dash;
                  else
                     estado <= punto;
                  end if;
               end if;
 
            when punto =>
               if cuenta = T_PUNTO then
                  cuenta <= 0;
                  if idx = largo(letra) - 1 then
                     estado <= inicio;     
                  else
                     estado <= espacio;
                  end if;
               else
                  cuenta <= cuenta + 1;
               end if;
 
            when dash =>
               if cuenta = T_DASH then
                  cuenta <= 0;
                  if idx = largo(letra) - 1 then
                     estado <= inicio;
                  else
                     estado <= espacio;
                  end if;
               else
                  cuenta <= cuenta + 1;
               end if;
 
            when espacio =>                
               if cuenta = T_PUNTO then
                  cuenta <= 0;
                  idx    <= idx + 1;
                  if patron(letra)(3 - (idx + 1)) = '1' then
                     estado <= dash;
                  else
                     estado <= punto;
                  end if;
               else
                  cuenta <= cuenta + 1;
               end if;
 
         end case;
      end if;
   end process;
 
   Led <= '1' when (estado = punto or estado = dash) else '0';
 
end arch_FSM;