-------------------------------------------------------------------------
-- EX/MEM Pipeline Register
--  - Latches EX stage results and control signals into MEM stage
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ex_mem_reg is
    port(
        i_CLK       : in  std_logic;                      -- Clock
        i_RST       : in  std_logic;                      -- Reset (High Active)

        -- From EX stage (inputs)
        i_PC        : in  std_logic_vector(31 downto 0);  -- PC associated with this instruction
        i_ALUResult : in  std_logic_vector(31 downto 0);  -- ALU result (addr or arithmetic)
        i_ReadData2 : in  std_logic_vector(31 downto 0);  -- rs2 data (store value)
        i_Imm       : in  std_logic_vector(31 downto 0);  -- immediate (for LUI/AUIPC path)
        i_Funct3    : in  std_logic_vector(2 downto 0);   -- funct3 (load/store type)
        i_Rd        : in  std_logic_vector(4 downto 0);   -- destination register

        -- Control signals from EX (coming originally from ID)
        i_MemRead   : in  std_logic;                      -- data memory read
        i_MemWrite  : in  std_logic;                      -- data memory write
        i_RegWrite  : in  std_logic;                      -- writeback enable
        i_MemtoReg  : in  std_logic_vector(1 downto 0);   -- WB mux select
        i_Halt      : in  std_logic;

        -- To MEM stage (outputs)
        o_PC        : out std_logic_vector(31 downto 0);
        o_ALUResult : out std_logic_vector(31 downto 0);
        o_ReadData2 : out std_logic_vector(31 downto 0);
        o_Imm       : out std_logic_vector(31 downto 0);
        o_Funct3    : out std_logic_vector(2 downto 0);
        o_Rd        : out std_logic_vector(4 downto 0);

        o_MemRead   : out std_logic;
        o_MemWrite  : out std_logic;
        o_RegWrite  : out std_logic;
        o_MemtoReg  : out std_logic_vector(1 downto 0);
        o_Halt      : out  std_logic
    );
end ex_mem_reg;

architecture behavior of ex_mem_reg is

    -- Datapath registers
    signal s_PC_reg        : std_logic_vector(31 downto 0) := (others => '0');
    signal s_ALUResult_reg : std_logic_vector(31 downto 0) := (others => '0');
    signal s_ReadData2_reg : std_logic_vector(31 downto 0) := (others => '0');
    signal s_Imm_reg       : std_logic_vector(31 downto 0) := (others => '0');
    signal s_Funct3_reg    : std_logic_vector(2 downto 0)  := (others => '0');
    signal s_Rd_reg        : std_logic_vector(4 downto 0)  := (others => '0');

    -- Control registers
    signal s_MemRead_reg   : std_logic := '0';
    signal s_MemWrite_reg  : std_logic := '0';
    signal s_RegWrite_reg  : std_logic := '0';
    signal s_MemtoReg_reg  : std_logic_vector(1 downto 0) := (others => '0');
    signal s_Halt_reg      : std_logic := '0';

begin

    process(i_CLK, i_RST)
    begin
        if (i_RST = '1') then
            -- Reset: clear everything to a "safe NOP" state
            s_PC_reg        <= (others => '0');
            s_ALUResult_reg <= (others => '0');
            s_ReadData2_reg <= (others => '0');
            s_Imm_reg       <= (others => '0');
            s_Funct3_reg    <= (others => '0');
            s_Rd_reg        <= (others => '0');

            s_MemRead_reg   <= '0';
            s_MemWrite_reg  <= '0';
            s_RegWrite_reg  <= '0';
            s_MemtoReg_reg  <= (others => '0');
            
            s_Halt_reg      <= '0';

        elsif rising_edge(i_CLK) then
            -- Normal pipeline flow: latch EX outputs into EX/MEM register
            s_PC_reg        <= i_PC;
            s_ALUResult_reg <= i_ALUResult;
            s_ReadData2_reg <= i_ReadData2;
            s_Imm_reg       <= i_Imm;
            s_Funct3_reg    <= i_Funct3;
            s_Rd_reg        <= i_Rd;

            s_MemRead_reg   <= i_MemRead;
            s_MemWrite_reg  <= i_MemWrite;
            s_RegWrite_reg  <= i_RegWrite;
            s_MemtoReg_reg  <= i_MemtoReg;
            s_Halt_reg      <= i_Halt;
        end if;
    end process;

    -- Drive outputs to MEM stage
    o_PC        <= s_PC_reg;
    o_ALUResult <= s_ALUResult_reg;
    o_ReadData2 <= s_ReadData2_reg;
    o_Imm       <= s_Imm_reg;
    o_Funct3    <= s_Funct3_reg;
    o_Rd        <= s_Rd_reg;

    o_MemRead   <= s_MemRead_reg;
    o_MemWrite  <= s_MemWrite_reg;
    o_RegWrite  <= s_RegWrite_reg;
    o_MemtoReg  <= s_MemtoReg_reg;

    o_Halt      <= s_Halt_reg;

end behavior;