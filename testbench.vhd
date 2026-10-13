library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity testbench is
end testbench;
 
architecture prueba of testbench is
 
   component FSM is
      port
      (
         SW  : in  std_logic_vector (2 downto 0);
         CLK : in  std_logic;
         KEY : in  std_logic_vector (1 downto 0);
         Led : out std_logic
      );
   end component;
 
   constant T_CLK : time := 20 ns;   
 
   signal SW  : std_logic_vector(2 downto 0) := "000";
   signal CLK : std_logic := '0';
   signal KEY : std_logic_vector(1 downto 0) := "11";   
   signal Led : std_logic;
   signal fin : std_logic := '0';                      
 
begin
 

   uut : FSM
      port map (SW => SW, CLK => CLK, KEY => KEY, Led => Led);
 

   process
   begin
      while fin = '0' loop
         CLK <= '0';
         wait for T_CLK / 2;
         CLK <= '1';
         wait for T_CLK / 2;
      end loop;
      wait;
   end process;
 

   process
   begin
    
      KEY <= "10";
      wait for 3 * T_CLK;
      KEY <= "11";
      wait for 3 * T_CLK;
 
      
      for i in 0 to 7 loop
         SW <= std_logic_vector(to_unsigned(i, 3));
         wait for 2 * T_CLK;
 
         KEY(1) <= '0';               
         wait for 5 * T_CLK;
         KEY(1) <= '1';               
 
         wait for 1500 ns;            
      end loop;
 
      
      SW <= "001";
      wait for 2 * T_CLK;
      KEY(1) <= '0';
      wait for 5 * T_CLK;
      KEY(1) <= '1';
      wait for 300 ns;                
      wait for 7 ns;                  
      KEY(0) <= '0';
      wait for 3 * T_CLK;
      KEY(0) <= '1';
      wait for 500 ns;                 
      fin <= '1';                     
      wait;
   end process;
 
end prueba;