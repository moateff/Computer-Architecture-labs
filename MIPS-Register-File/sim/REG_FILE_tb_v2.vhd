library IEEE; 
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.env.ALL;  -- Required for std.env.stop

entity REG_FILE_tb is
end REG_FILE_tb;

architecture Sim of REG_FILE_tb is
    constant CLK_PERIOD : time := 10 ns;

    signal tb_clk       : std_logic := '0';   
    signal tb_wr_en     : std_logic := '0';   
    signal tb_rd_addr1  : std_logic_vector(4 downto 0) := (others => '0');   
    signal tb_rd_addr2  : std_logic_vector(4 downto 0) := (others => '0');   
    signal tb_wr_addr   : std_logic_vector(4 downto 0) := (others => '0');   
    signal tb_wr_data   : std_logic_vector(31 downto 0) := (others => '0');  
    signal tb_rd_data1  : std_logic_vector(31 downto 0);  
    signal tb_rd_data2  : std_logic_vector(31 downto 0);  

    component REG_FILE is
        Port (
            clk      : in  STD_LOGIC;
            wr_en    : in  STD_LOGIC;                      
            wr_addr  : in  STD_LOGIC_VECTOR (4 downto 0);  
            wr_data  : in  STD_LOGIC_VECTOR (31 downto 0); 
            rd_addr1 : in  STD_LOGIC_VECTOR (4 downto 0);  
            rd_addr2 : in  STD_LOGIC_VECTOR (4 downto 0);  
            rd_data1 : out STD_LOGIC_VECTOR (31 downto 0); 
            rd_data2 : out STD_LOGIC_VECTOR (31 downto 0)  
        );
    end component;

begin
    -- Instantiate DUT (Device Under Test)
    DUT: REG_FILE
    port map (
        clk      => tb_clk,
        wr_en    => tb_wr_en,
        wr_addr  => tb_wr_addr,
        wr_data  => tb_wr_data,
        rd_addr1 => tb_rd_addr1,
        rd_addr2 => tb_rd_addr2,
        rd_data1 => tb_rd_data1,
        rd_data2 => tb_rd_data2
    );

    -- Infinite Clock Process
    clk_proc: process
    begin
        while true loop
            tb_clk <= '1';
            wait for CLK_PERIOD / 2;
            tb_clk <= '0';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;
    
    tb_proc: process
        -- Procedure to write data to a register
        procedure write_register (
            addr : in std_logic_vector(4 downto 0); 
            data : in std_logic_vector(31 downto 0)
        ) is
        begin
            wait until rising_edge(tb_clk);
            tb_wr_en  <= '1';
            tb_wr_addr <= addr;
            tb_wr_data <= data;
            wait until rising_edge(tb_clk);
            tb_wr_en  <= '0';
        end procedure;
    
        -- Procedure to read data from a register
        procedure read_register (
            addr : in std_logic_vector(4 downto 0); 
            data_out : out std_logic_vector(31 downto 0)
        ) is
        begin
            tb_rd_addr1 <= addr;
            wait for 1 ns;
            data_out := tb_rd_data1;
        end procedure;
                
        -- Procedure to check if read data matches expected value (placed inside process)
        procedure check_register(
            expected_data : in std_logic_vector(31 downto 0);
            actual_data   : in std_logic_vector(31 downto 0)
        ) is
        begin
            assert actual_data = expected_data
                report "Check failed: Expected " & integer'image(to_integer(unsigned(expected_data))) & 
                       ", but got " & integer'image(to_integer(unsigned(actual_data)))
                severity error;
        end procedure;
    
        variable write_value : std_logic_vector(31 downto 0);
        variable read_value  : std_logic_vector(31 downto 0);
    begin
        wait for CLK_PERIOD;
        
        -- Test Cases
        write_value := x"00000005";
        write_register("00010", write_value);
        read_register("00010", read_value);
        check_register(write_value, read_value);
        
        write_value := x"00000007";
        write_register("00001", write_value);
        read_register("00001", read_value);
        check_register(write_value, read_value);
            
        -- Verify Zero Register Always Reads as Zero
        write_value := x"00000009";
        write_register("00000", write_value);
        read_register("00000", read_value);
        check_register(x"00000000", read_value);
 
        report "All test cases passed successfully!" severity note;
        std.env.stop;
    end process;

end Sim;
