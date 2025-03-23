----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/23/2025 02:19:18 PM
-- Design Name: 
-- Module Name: REG_FILE_tb - Behavioral
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
use std.textio.all;

entity REG_FILE_TB is
end REG_FILE_TB;

architecture testbench of REG_FILE_TB is

    -- DUT signals
    signal clk      : std_logic := '0';
    signal wr_en    : std_logic := '0';
    signal wr_addr  : std_logic_vector(4 downto 0) := (others => '0');
    signal wr_data  : std_logic_vector(31 downto 0) := (others => '0');
    signal rd_addr1 : std_logic_vector(4 downto 0) := (others => '0');
    signal rd_addr2 : std_logic_vector(4 downto 0) := (others => '0');
    signal rd_data1 : std_logic_vector(31 downto 0);
    signal rd_data2 : std_logic_vector(31 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate the Register File DUT
    DUT: entity work.REG_FILE
        port map (
            clk      => clk,
            wr_en    => wr_en,
            wr_addr  => wr_addr,
            wr_data  => wr_data,
            rd_addr1 => rd_addr1,
            rd_addr2 => rd_addr2,
            rd_data1 => rd_data1,
            rd_data2 => rd_data2
        );

    -- Clock process
    clk_process: process
    begin
        while now < 500 ns loop  -- Limit simulation time
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stimulus_process: process
    begin
        report "Starting REG_FILE Testbench...";
        
        -- Test Case 1: Write and Read from Register
        wr_en   <= '1';
        wr_addr <= "00001";
        wr_data <= x"DEADBEEF";
        wait for CLK_PERIOD / 2;
        wait for CLK_PERIOD;
        wr_en   <= '0';

        -- Read back the value
        rd_addr1 <= "00001";
        wait for CLK_PERIOD;
        assert rd_data1 = x"DEADBEEF"
            report "Error: Incorrect data read from register!" severity error;
        
        -- Test Case 2: Writing to Register 0 (Should Remain Zero)
        wr_en   <= '1';
        wr_addr <= "00000";
        wr_data <= x"FFFFFFFF";
        wait for CLK_PERIOD;
        wr_en   <= '0';
        
        rd_addr1 <= "00000";
        wait for CLK_PERIOD;
        assert rd_data1 = x"00000000"
            report "Error: Register 0 should always be zero!" severity error;
        
        -- Test Case 3: Multiple Writes and Reads
        wr_en   <= '1';
        wr_addr <= "00010";
        wr_data <= x"12345678";
        wait for CLK_PERIOD;
        
        wr_addr <= "00011";
        wr_data <= x"ABCDEF12";
        wait for CLK_PERIOD;
        wr_en   <= '0';
        
        rd_addr1 <= "00010";
        rd_addr2 <= "00011";
        wait for CLK_PERIOD;
        
        assert rd_data1 = x"12345678"
            report "Error: Incorrect data read from register 2!" severity error;
        assert rd_data2 = x"ABCDEF12"
            report "Error: Incorrect data read from register 3!" severity error;
        
        -- Test Case 4: Write and Read in the Same Clock Cycle
        wr_en   <= '1';
        wr_addr <= "00100";
        wr_data <= x"A5A5A5A5";
        rd_addr1 <= "00100";
        wait for CLK_PERIOD;
        wr_en   <= '0';
        
        assert rd_data1 = x"A5A5A5A5"
            report "Error: Failed to read and write in the same cycle!" severity error;
        
        -- Test Case 5: RegWrite Disabled (wr_en = 0)
        wr_en   <= '0';
        wr_addr <= "00101";
        wr_data <= x"BEEFCAFE";
        wait for CLK_PERIOD;
        
        rd_addr1 <= "00101";
        wait for CLK_PERIOD;
        assert rd_data1 = x"00000000"
            report "Error: Data should not be written when wr_en is '0'!" severity error;
        
        report "Testbench Completed Successfully." severity note;
        wait;
    end process;

end testbench;

