library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity idelay_ctrl is
	port (
    rst              : in std_logic;
    ref_clk_i        : in std_logic
	);
end idelay_ctrl;

architecture arch_imp of idelay_ctrl is

  
begin

  idelayctrl_inst : IDELAYCTRL
  port map (
     rdy    => open,      
     refclk => ref_clk_i,
     rst    => rst       
  );

end arch_imp;
