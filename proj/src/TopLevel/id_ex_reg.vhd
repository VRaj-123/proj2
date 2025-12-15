-------------------------------------------------------------------------
-- ID/EX Pipeline Register
--  - Latches control and datapath signals from ID stage to EX stage
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity id_ex_reg is
    port(
        i_CLK      : in  std_logic;                      -- Clock
        i_RST      : in  std_logic;                      -- Reset (High Active)

        -- From ID stage (inputs)
        i_PC       : in  std_logic_vector(31 downto 0);  -- PC value in ID
        i_ReadData1: in  std_logic_vector(31 downto 0);  -- rs1 data
        i_ReadData2: in  std_logic_vector(31 downto 0);  -- rs2 data
        i_Imm      : in  std_logic_vector(31 downto 0);  -- immediate
        i_Funct3   : in  std_logic_vector(2 downto 0);   -- funct3
        i_Funct7   : in  std_logic_vector(6 downto 0);   -- funct7
        i_Rd       : in  std_logic_vector(4 downto 0);   -- destination reg
    i_Rs1      : in  std_logic_vector(4 downto 0);   -- source rs1
    i_Rs2      : in  std_logic_vector(4 downto 0);   -- source rs2

        -- Control signals from ID stage
        i_ALUSrcA  : in  std_logic;                      -- 0=rs1, 1=PC
        i_ALUSrcB  : in  std_logic;                      -- 0=rs2, 1=Imm
        i_ALUOp    : in  std_logic_vector(1 downto 0);   -- to alu_control

        i_MemRead  : in  std_logic;                      -- data memory read
        i_MemWrite : in  std_logic;                      -- data memory write

        i_RegWrite : in  std_logic;                      -- writeback enable
        i_MemtoReg : in  std_logic_vector(1 downto 0);   -- WB mux select

        i_Branch   : in  std_logic;                      -- conditional branch
        i_Jump     : in  std_logic_vector(1 downto 0);   -- 00=none,01=JAL,10=JALR
        i_Halt     : in  std_logic;

        -- To EX stage (outputs)
        o_PC       : out std_logic_vector(31 downto 0);
        o_ReadData1: out std_logic_vector(31 downto 0);
        o_ReadData2: out std_logic_vector(31 downto 0);
        o_Imm      : out std_logic_vector(31 downto 0);
        o_Funct3   : out std_logic_vector(2 downto 0);
        o_Funct7   : out std_logic_vector(6 downto 0);
        o_Rd       : out std_logic_vector(4 downto 0);
    o_Rs1      : out std_logic_vector(4 downto 0);
    o_Rs2      : out std_logic_vector(4 downto 0);

        o_ALUSrcA  : out std_logic;
        o_ALUSrcB  : out std_logic;
        o_ALUOp    : out std_logic_vector(1 downto 0);

        o_MemRead  : out std_logic;
        o_MemWrite : out std_logic;

        o_RegWrite : out std_logic;
        o_MemtoReg : out std_logic_vector(1 downto 0);

        o_Branch   : out std_logic;
        o_Jump     : out std_logic_vector(1 downto 0);
        o_Halt     : out std_logic
    );
end id_ex_reg;

architecture behavior of id_ex_reg is

    -- Datapath registers
    signal s_PC_reg        : std_logic_vector(31 downto 0) := (others => '0');
    signal s_ReadData1_reg : std_logic_vector(31 downto 0) := (others => '0');
    signal s_ReadData2_reg : std_logic_vector(31 downto 0) := (others => '0');
    signal s_Imm_reg       : std_logic_vector(31 downto 0) := (others => '0');
    signal s_Funct3_reg    : std_logic_vector(2 downto 0)  := (others => '0');
    signal s_Funct7_reg    : std_logic_vector(6 downto 0)  := (others => '0');
    signal s_Rd_reg        : std_logic_vector(4 downto 0)  := (others => '0');
    signal s_Rs1_reg       : std_logic_vector(4 downto 0)  := (others => '0');
    signal s_Rs2_reg       : std_logic_vector(4 downto 0)  := (others => '0');

    -- Control registers
    signal s_ALUSrcA_reg   : std_logic := '0';
    signal s_ALUSrcB_reg   : std_logic := '0';
    signal s_ALUOp_reg     : std_logic_vector(1 downto 0) := (others => '0');

    signal s_MemRead_reg   : std_logic := '0';
    signal s_MemWrite_reg  : std_logic := '0';

    signal s_RegWrite_reg  : std_logic := '0';
    signal s_MemtoReg_reg  : std_logic_vector(1 downto 0) := (others => '0');

    signal s_Branch_reg    : std_logic := '0';
    signal s_Jump_reg      : std_logic_vector(1 downto 0) := (others => '0');
    signal s_Halt_reg      : std_logic := '0';

begin

    process(i_CLK, i_RST)
    begin
        if (i_RST = '1') then
            -- On reset: clear everything to a "safe NOP" state
            s_PC_reg        <= (others => '0');
            s_ReadData1_reg <= (others => '0');
            s_ReadData2_reg <= (others => '0');
            s_Imm_reg       <= (others => '0');
            s_Funct3_reg    <= (others => '0');
            s_Funct7_reg    <= (others => '0');
            s_Rd_reg        <= (others => '0');

            s_ALUSrcA_reg   <= '0';
            s_ALUSrcB_reg   <= '0';
            s_ALUOp_reg     <= (others => '0');

            s_MemRead_reg   <= '0';
            s_MemWrite_reg  <= '0';

            s_RegWrite_reg  <= '0';
            s_MemtoReg_reg  <= (others => '0');

            s_Branch_reg    <= '0';
            s_Jump_reg      <= (others => '0');
            s_Halt_reg      <= '0';

        elsif rising_edge(i_CLK) then
            -- Normal pipeline flow: latch ID outputs into ID/EX register
            s_PC_reg        <= i_PC;
            s_ReadData1_reg <= i_ReadData1;
            s_ReadData2_reg <= i_ReadData2;
            s_Imm_reg       <= i_Imm;
            s_Funct3_reg    <= i_Funct3;
            s_Funct7_reg    <= i_Funct7;
            s_Rd_reg        <= i_Rd;
                s_Rs1_reg       <= i_Rs1;
                s_Rs2_reg       <= i_Rs2;

            s_ALUSrcA_reg   <= i_ALUSrcA;
            s_ALUSrcB_reg   <= i_ALUSrcB;
            s_ALUOp_reg     <= i_ALUOp;

            s_MemRead_reg   <= i_MemRead;
            s_MemWrite_reg  <= i_MemWrite;

            s_RegWrite_reg  <= i_RegWrite;
            s_MemtoReg_reg  <= i_MemtoReg;

            s_Branch_reg    <= i_Branch;
            s_Jump_reg      <= i_Jump;

            s_Halt_reg      <= i_Halt;
        end if;
    end process;

    -- Drive outputs to EX stage
    o_PC        <= s_PC_reg;
    o_ReadData1 <= s_ReadData1_reg;
    o_ReadData2 <= s_ReadData2_reg;
    o_Imm       <= s_Imm_reg;
    o_Funct3    <= s_Funct3_reg;
    o_Funct7    <= s_Funct7_reg;
    o_Rd        <= s_Rd_reg;
    o_Rs1       <= s_Rs1_reg;
    o_Rs2       <= s_Rs2_reg;

    o_ALUSrcA   <= s_ALUSrcA_reg;
    o_ALUSrcB   <= s_ALUSrcB_reg;
    o_ALUOp     <= s_ALUOp_reg;

    o_MemRead   <= s_MemRead_reg;
    o_MemWrite  <= s_MemWrite_reg;

    o_RegWrite  <= s_RegWrite_reg;
    o_MemtoReg  <= s_MemtoReg_reg;

    o_Branch    <= s_Branch_reg;
    o_Jump      <= s_Jump_reg;

    o_Halt      <= s_Halt_reg;

end behavior;