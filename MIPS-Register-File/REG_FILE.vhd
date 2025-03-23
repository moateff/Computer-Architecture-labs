----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/23/2025 04:08:59 AM
-- Design Name: 
-- Module Name: REG_FILE - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity REG_FILE is
    Port ( 
        clk       : in  STD_LOGIC;                      -- Clock signal
        wr_en     : in  STD_LOGIC;                      -- Write enable signal
        wr_addr   : in  STD_LOGIC_VECTOR (4 downto 0);  -- Write address (5-bit)
        wr_data   : in  STD_LOGIC_VECTOR (31 downto 0); -- Write data (32-bit)
        rd_addr1  : in  STD_LOGIC_VECTOR (4 downto 0);  -- Read address 1 (5-bit)
        rd_addr2  : in  STD_LOGIC_VECTOR (4 downto 0);  -- Read address 2 (5-bit)
        rd_data1  : out STD_LOGIC_VECTOR (31 downto 0); -- Read data 1 (32-bit)
        rd_data2  : out STD_LOGIC_VECTOR (31 downto 0)  -- Read data 2 (32-bit)
    );
end REG_FILE;

architecture Behavioral of REG_FILE is
    type reg_array is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal reg_memory : reg_array := (others => (others => '0')); -- Initialize to zeros

begin

    -- Read logic: Outputs data from register memory
    rd_data1 <= reg_memory(to_integer(unsigned(rd_addr1))) when rd_addr1 /= "00000" else (others => '0');
    rd_data2 <= reg_memory(to_integer(unsigned(rd_addr2))) when rd_addr2 /= "00000" else (others => '0');

    -- Write logic: Updates register memory on rising edge of clk
    process (clk)
    begin
        if rising_edge(clk) then
            if wr_en = '1' then
                reg_memory(to_integer(unsigned(wr_addr))) <= wr_data;
            end if;
        end if;
    end process;

end Behavioral;
