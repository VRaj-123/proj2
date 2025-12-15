-------------------------------------------------------------------------
-- IF/ID Pipeline Register
--  - Latches PC (s_CurrentPC) and Instruction (s_Inst)
--    from IF stage to ID stage
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity if_id_reg is
    port(
        i_CLK   : in  std_logic;                      -- Clock
        i_RST   : in  std_logic;                      -- Reset (High Active)

        -- From IF stage (connect these to s_CurrentPC, s_Inst)
        i_PC    : in  std_logic_vector(31 downto 0);  -- Current PC in IF
        i_Inst  : in  std_logic_vector(31 downto 0);  -- Instruction fetched in IF

        -- To ID stage (you will use these instead of s_CurrentPC/s_Inst in ID)
        o_PC    : out std_logic_vector(31 downto 0);  -- PC seen by ID
        o_Inst  : out std_logic_vector(31 downto 0)   -- Instruction seen by ID
    );
end if_id_reg;

architecture behavior of if_id_reg is

    signal s_PC_reg   : std_logic_vector(31 downto 0) := (others => '0');
    signal s_Inst_reg : std_logic_vector(31 downto 0) := (others => '0');

    -- RV32I NOP: addi x0, x0, 0 = 0x00000013
    constant C_NOP : std_logic_vector(31 downto 0) := x"00000013";

begin

    process(i_CLK, i_RST)
    begin
        if (i_RST = '1') then
            -- Reset: clear PC and insert a safe NOP (not HALT)
            s_PC_reg   <= (others => '0');
            s_Inst_reg <= C_NOP;

        elsif rising_edge(i_CLK) then
            -- Normal pipeline flow: latch IF outputs into IF/ID register
            s_PC_reg   <= i_PC;
            s_Inst_reg <= i_Inst;
        end if;
    end process;

    -- Drive outputs to ID stage
    o_PC   <= s_PC_reg;
    o_Inst <= s_Inst_reg;

end behavior;