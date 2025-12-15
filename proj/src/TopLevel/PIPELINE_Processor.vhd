library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

library work;
use work.RISCV_types.all;

entity RISCV_Processor is
    generic(N : integer := DATA_WIDTH);
    port(
        iCLK      : in std_logic;
        iRST      : in std_logic;
        iInstLd   : in std_logic;
        iInstAddr : in std_logic_vector(N-1 downto 0);
        iInstExt  : in std_logic_vector(N-1 downto 0);
        oALUOut   : out std_logic_vector(N-1 downto 0)
    );
end RISCV_Processor;

architecture structure of RISCV_Processor is

    ---------------------------------------------------------------------
    -- Signals
    ---------------------------------------------------------------------
    -- [1] Data memory
    signal s_DMemWr   : std_logic;
    signal s_DMemAddr : std_logic_vector(N-1 downto 0);
    signal s_DMemData : std_logic_vector(N-1 downto 0);
    signal s_DMemOut  : std_logic_vector(N-1 downto 0);

    -- [2] Register file / writeback
    signal s_RegWr     : std_logic;
    signal s_RegWrAddr : std_logic_vector(4 downto 0);
    signal s_RegWrData : std_logic_vector(N-1 downto 0);
    signal s_ReadData1_byp : std_logic_vector(31 downto 0);
    signal s_ReadData2_byp : std_logic_vector(31 downto 0);

    -- [3] Instruction memory
    signal s_IMemAddr     : std_logic_vector(N-1 downto 0);
    signal s_NextInstAddr : std_logic_vector(N-1 downto 0);
    signal s_Inst         : std_logic_vector(N-1 downto 0);

    -- IF/ID
    signal s_PC_ID       : std_logic_vector(31 downto 0);
    signal s_Inst_ID     : std_logic_vector(N-1 downto 0);
    signal s_RegWrite_ID : std_logic;
    signal s_Rd_ID       : std_logic_vector(4 downto 0);
    signal s_MemWrite_ID : std_logic;

    -- Halt / overflow
    signal s_Halt : std_logic;
    signal s_Ovfl : std_logic;

    -- Internal control & datapath
    signal s_CurrentPC : std_logic_vector(31 downto 0);
    signal s_Funct3    : std_logic_vector(2 downto 0);
    signal s_Funct7    : std_logic_vector(6 downto 0);

    signal s_MemRead   : std_logic;
    signal s_Branch    : std_logic;
    signal s_Jump      : std_logic_vector(1 downto 0);

    signal s_ALUSrcA   : std_logic;
    signal s_ALUSrcB   : std_logic;
    signal s_MemtoReg  : std_logic_vector(1 downto 0);
    signal s_ALUOp     : std_logic_vector(1 downto 0);
    signal s_ImmType   : std_logic_vector(2 downto 0);

    signal s_ReadData1 : std_logic_vector(31 downto 0);
    signal s_Imm       : std_logic_vector(31 downto 0);
    signal s_ALUCtrl   : std_logic_vector(3 downto 0);

    signal s_ALUInputA : std_logic_vector(31 downto 0);
    signal s_ALUInputB : std_logic_vector(31 downto 0);
    signal s_ALUResult : std_logic_vector(31 downto 0);
    signal s_Zero      : std_logic;
    signal s_Sign      : std_logic;
    signal s_Cout      : std_logic;

    -- ID/EX
    signal s_ReadData2 : std_logic_vector(31 downto 0);
    signal s_LoadData  : std_logic_vector(31 downto 0);

    signal s_PC_EX        : std_logic_vector(31 downto 0);
    signal s_ReadData1_EX : std_logic_vector(31 downto 0);
    signal s_ReadData2_EX : std_logic_vector(31 downto 0);
    signal s_Imm_EX       : std_logic_vector(31 downto 0);
    signal s_Funct3_EX    : std_logic_vector(2 downto 0);
    signal s_Funct7_EX    : std_logic_vector(6 downto 0);
    signal s_Rd_EX        : std_logic_vector(4 downto 0);
    signal s_Rs1_EX       : std_logic_vector(4 downto 0);
    signal s_Rs2_EX       : std_logic_vector(4 downto 0);

    signal s_MemRead_EX   : std_logic;
    signal s_MemWrite_EX  : std_logic;
    signal s_RegWrite_EX  : std_logic;
    signal s_MemtoReg_EX  : std_logic_vector(1 downto 0);
    signal s_ALUSrcA_EX   : std_logic;
    signal s_ALUSrcB_EX   : std_logic;
    signal s_ALUOp_EX     : std_logic_vector(1 downto 0);
    signal s_Branch_EX    : std_logic;
    signal s_Jump_EX      : std_logic_vector(1 downto 0);

    -- EX/MEM
    signal s_PC_MEM        : std_logic_vector(31 downto 0);
    signal s_ALUResult_MEM : std_logic_vector(31 downto 0);
    signal s_ReadData2_MEM : std_logic_vector(31 downto 0);
    signal s_Funct3_MEM    : std_logic_vector(2 downto 0);
    signal s_Rd_MEM        : std_logic_vector(4 downto 0);

    signal s_MemRead_MEM   : std_logic;
    signal s_MemWrite_MEM  : std_logic;
    signal s_RegWrite_MEM  : std_logic;
    signal s_MemtoReg_MEM  : std_logic_vector(1 downto 0);
    signal s_Branch_MEM    : std_logic;

    -- MEM/WB
    signal s_PC_WB        : std_logic_vector(31 downto 0);
    signal s_ALUResult_WB : std_logic_vector(31 downto 0);
    signal s_LoadData_WB  : std_logic_vector(31 downto 0);
    signal s_Imm_MEM      : std_logic_vector(31 downto 0);
    signal s_Imm_WB       : std_logic_vector(31 downto 0);
    signal s_Rd_WB        : std_logic_vector(4 downto 0);

    signal s_RegWrite_WB  : std_logic;
    signal s_MemtoReg_WB  : std_logic_vector(1 downto 0);

    -- Halt flags
    signal s_Halt_ID  : std_logic;
    signal s_Halt_EX  : std_logic;
    signal s_Halt_MEM : std_logic;
    signal s_Halt_WB  : std_logic;

begin

    -----------------------------------------------------------------
    -- Instruction memory interface
    -----------------------------------------------------------------
    with iInstLd select
        s_IMemAddr <= s_CurrentPC when '0',
                      iInstAddr      when others;

    IMem: entity work.mem
        generic map(
            ADDR_WIDTH => ADDR_WIDTH,
            DATA_WIDTH => N
        )
        port map(
            clk  => iCLK,
            addr => s_IMemAddr(ADDR_WIDTH+1 downto 2),
            data => iInstExt,
            we   => iInstLd,
            q    => s_Inst
        );

    -----------------------------------------------------------------
    -- Data memory interface
    -----------------------------------------------------------------
    DMem: entity work.mem
        generic map(
            ADDR_WIDTH => ADDR_WIDTH,
            DATA_WIDTH => N
        )
        port map(
            clk  => iCLK,
            addr => s_ALUResult_MEM(ADDR_WIDTH+1 downto 2),
            data => s_ReadData2_MEM,
            we   => s_MemWrite_MEM,
            q    => s_DMemOut
        );

    oALUOut <= s_DMemAddr;

    -----------------------------------------------------------------
    -- IF/ID pipeline register
    -----------------------------------------------------------------
    U_IF_ID : entity work.if_id_reg
        port map(
            i_CLK  => iCLK,
            i_RST  => iRST,
            i_PC   => s_CurrentPC,
            i_Inst => s_Inst(31 downto 0),
            o_PC   => s_PC_ID,
            o_Inst => s_Inst_ID
        );

    -----------------------------------------------------------------
    -- Control Unit (ID)
    -----------------------------------------------------------------
    s_Funct3 <= s_Inst_ID(14 downto 12);
    s_Funct7 <= s_Inst_ID(31 downto 25);
    s_Halt_ID <= '1' when s_Inst_ID(6 downto 0) = "0000000" else '0';

    U_CONTROL : entity work.control_unit
        port map(
            i_Opcode   => s_Inst_ID(6 downto 0),
            o_ALUSrc   => s_ALUSrcB,
            o_MemtoReg => s_MemtoReg,
            o_RegWrite => s_RegWrite_ID,
            o_MemRead  => s_MemRead,
            o_MemWrite => s_MemWrite_ID,
            o_Branch   => s_Branch,
            o_Jump     => s_Jump,
            o_ALUOp    => s_ALUOp,
            o_ImmType  => s_ImmType,
            o_AUIPCSrc => s_ALUSrcA
        );

    s_Rd_ID <= s_Inst_ID(11 downto 7);

    -----------------------------------------------------------------
    -- PC & Fetch logic
    -----------------------------------------------------------------
    U_PC : entity work.pc_reg
        port map(
            i_CLK    => iCLK,
            i_RST    => iRST,
            i_WE     => '1',
            i_NextPC => s_NextInstAddr,
            o_PC     => s_CurrentPC
        );

    U_FETCH : entity work.fetch_logic
        port map(
            i_PC_IF   => s_CurrentPC,
            i_PC_EX   => s_PC_EX,
            i_Imm     => s_Imm_EX,
            i_RS1     => s_ReadData1_EX,
            i_Branch  => s_Branch_EX,
            i_Jump    => s_Jump_EX,
            i_Funct3  => s_Funct3_EX,
            i_ALUZero => s_Zero,
            i_ALUSign => s_Sign,
            i_ALUCout => s_Cout,
            o_NextPC  => s_NextInstAddr
        );

    -----------------------------------------------------------------
    -- Register file (ID)
    -----------------------------------------------------------------
    U_REGFILE : entity work.reg_file
        port map(
            i_CLK    => iCLK,
            i_RST    => iRST,
            i_WE     => s_RegWr,
            i_WADDR  => s_Rd_WB,
            i_WDATA  => s_RegWrData,
            i_RADDR1 => s_Inst_ID(19 downto 15),
            i_RADDR2 => s_Inst_ID(24 downto 20),
            o_RDATA1 => s_ReadData1,
            o_RDATA2 => s_ReadData2
        );

    s_RegWrAddr <= s_Rd_WB;

    -----------------------------------------------------------------
    -- WB->ID bypass (per-source independent)
    -----------------------------------------------------------------
    wb_id_bypass: process(s_ReadData1, s_ReadData2, s_RegWrData,
                          s_RegWrite_WB, s_Rd_WB, s_MemtoReg_WB,
                          s_ALUResult_WB, s_LoadData_WB, s_PC_WB, s_Imm_WB,
                          s_Inst_ID, s_RegWrite_MEM, s_Rd_MEM, s_MemtoReg_MEM,
                          s_ALUResult_MEM, s_LoadData, s_PC_MEM, s_Imm_MEM)
        variable rs1 : std_logic_vector(4 downto 0);
        variable rs2 : std_logic_vector(4 downto 0);
        variable mem_wr_data : std_logic_vector(31 downto 0);
    begin
        rs1 := s_Inst_ID(19 downto 15);
        rs2 := s_Inst_ID(24 downto 20);

        -- defaults
        s_ReadData1_byp <= s_ReadData1;
        s_ReadData2_byp <= s_ReadData2;

        -- compute what MEM stage would write
        case s_MemtoReg_MEM is
            when "00" => mem_wr_data := s_ALUResult_MEM;
            when "01" => mem_wr_data := s_LoadData;
            when "10" => mem_wr_data := std_logic_vector(unsigned(s_PC_MEM) + 4);
            when "11" => mem_wr_data := s_Imm_MEM;
            when others => mem_wr_data := s_ALUResult_MEM;
        end case;

    report ("WB_ID_BYPASS: rs1=" & integer'image(to_integer(unsigned(rs1))) &
        " rs2=" & integer'image(to_integer(unsigned(rs2))) &
        " Rd_MEM=" & integer'image(to_integer(unsigned(s_Rd_MEM))) &
        " RegWrite_MEM=" & std_logic'image(s_RegWrite_MEM) &
        " Rd_WB=" & integer'image(to_integer(unsigned(s_Rd_WB))) &
        " RegWrite_WB=" & std_logic'image(s_RegWrite_WB)) severity note;
    report ("WB_ID_BYPASS: mem_wr_data=0x" & integer'image(to_integer(unsigned(mem_wr_data))) &
        " RegWrData=0x" & integer'image(to_integer(unsigned(s_RegWrData)))) severity note;

        -- rs1 forwarding: EX/MEM has priority, then MEM/WB
        if (s_RegWrite_MEM = '1' and s_Rd_MEM /= "00000" and s_Rd_MEM = rs1) then
            s_ReadData1_byp <= mem_wr_data;
        elsif (s_RegWrite_WB = '1' and s_Rd_WB /= "00000" and s_Rd_WB = rs1) then
            s_ReadData1_byp <= s_RegWrData;
        end if;

        -- rs2 forwarding
        if (s_RegWrite_MEM = '1' and s_Rd_MEM /= "00000" and s_Rd_MEM = rs2) then
            s_ReadData2_byp <= mem_wr_data;
        elsif (s_RegWrite_WB = '1' and s_Rd_WB /= "00000" and s_Rd_WB = rs2) then
            s_ReadData2_byp <= s_RegWrData;
        end if;
    end process wb_id_bypass;

    -----------------------------------------------------------------
    -- Immediate generator
    -----------------------------------------------------------------
    U_IMM_GEN : entity work.imm_gen
        port map(
            i_Inst    => s_Inst_ID,
            i_ImmType => s_ImmType,
            o_Imm     => s_Imm
        );

    -----------------------------------------------------------------
    -- ID/EX pipeline register
    -----------------------------------------------------------------
    U_ID_EX : entity work.id_ex_reg
        port map(
            i_CLK       => iCLK,
            i_RST       => iRST,
            i_PC        => s_PC_ID,
            i_ReadData1 => s_ReadData1_byp,
            i_ReadData2 => s_ReadData2_byp,
            i_Imm       => s_Imm,
            i_Funct3    => s_Funct3,
            i_Funct7    => s_Funct7,
            i_Rd        => s_Rd_ID,
            i_Rs1       => s_Inst_ID(19 downto 15),
            i_Rs2       => s_Inst_ID(24 downto 20),
            i_MemRead   => s_MemRead,
            i_MemWrite  => s_MemWrite_ID,
            i_RegWrite  => s_RegWrite_ID,
            i_MemtoReg  => s_MemtoReg,
            i_ALUSrcA   => s_ALUSrcA,
            i_ALUSrcB   => s_ALUSrcB,
            i_ALUOp     => s_ALUOp,
            i_Branch    => s_Branch,
            i_Jump      => s_Jump,
            i_Halt      => s_Halt_ID,
            o_PC        => s_PC_EX,
            o_ReadData1 => s_ReadData1_EX,
            o_ReadData2 => s_ReadData2_EX,
            o_Imm       => s_Imm_EX,
            o_Funct3    => s_Funct3_EX,
            o_Funct7    => s_Funct7_EX,
            o_Rd        => s_Rd_EX,
            o_Rs1       => s_Rs1_EX,
            o_Rs2       => s_Rs2_EX,
            o_MemRead   => s_MemRead_EX,
            o_MemWrite  => s_MemWrite_EX,
            o_RegWrite  => s_RegWrite_EX,
            o_MemtoReg  => s_MemtoReg_EX,
            o_ALUSrcA   => s_ALUSrcA_EX,
            o_ALUSrcB   => s_ALUSrcB_EX,
            o_ALUOp     => s_ALUOp_EX,
            o_Branch    => s_Branch_EX,
            o_Jump      => s_Jump_EX,
            o_Halt      => s_Halt_EX
        );

    -----------------------------------------------------------------
    -- EX stage forwarding
    -----------------------------------------------------------------
    ex_forward_a: process(s_ALUSrcA_EX, s_ReadData1_EX, s_PC_EX,
                          s_RegWrite_MEM, s_Rd_MEM, s_ALUResult_MEM,
                          s_RegWrite_WB, s_Rd_WB, s_RegWrData, s_Rs1_EX)
    begin
        if (s_ALUSrcA_EX = '1') then
            s_ALUInputA <= s_PC_EX;
        else
            if (s_RegWrite_MEM = '1' and s_Rd_MEM /= "00000" and s_Rd_MEM = s_Rs1_EX) then
                s_ALUInputA <= s_ALUResult_MEM;
            elsif (s_RegWrite_WB = '1' and s_Rd_WB /= "00000" and s_Rd_WB = s_Rs1_EX) then
                s_ALUInputA <= s_RegWrData;
            else
                s_ALUInputA <= s_ReadData1_EX;
            end if;
        end if;
    end process ex_forward_a;

    ex_forward_b: process(s_ALUSrcB_EX, s_ReadData2_EX, s_Imm_EX,
                          s_RegWrite_MEM, s_Rd_MEM, s_ALUResult_MEM,
                          s_RegWrite_WB, s_Rd_WB, s_RegWrData, s_Rs2_EX)
    begin
        if (s_ALUSrcB_EX = '1') then
            s_ALUInputB <= s_Imm_EX;
        else
            if (s_RegWrite_MEM = '1' and s_Rd_MEM /= "00000" and s_Rd_MEM = s_Rs2_EX) then
                s_ALUInputB <= s_ALUResult_MEM;
            elsif (s_RegWrite_WB = '1' and s_Rd_WB /= "00000" and s_Rd_WB = s_Rs2_EX) then
                s_ALUInputB <= s_RegWrData;
            else
                s_ALUInputB <= s_ReadData2_EX;
            end if;
        end if;
    end process ex_forward_b;

    U_ALUCTRL : entity work.alu_control
        port map(
            i_ALUOp   => s_ALUOp_EX,
            i_Funct3  => s_Funct3_EX,
            i_Funct7  => s_Funct7_EX,
            o_ALUCtrl => s_ALUCtrl
        );

    U_ALU : entity work.alu
        port map(
            i_A       => s_ALUInputA,
            i_B       => s_ALUInputB,
            i_ALUCtrl => s_ALUCtrl,
            o_Result  => s_ALUResult,
            o_Zero    => s_Zero,
            o_Sign    => s_Sign,
            o_Cout    => s_Cout
        );

    -----------------------------------------------------------------
    -- EX/MEM register
    -----------------------------------------------------------------
    U_EX_MEM : entity work.ex_mem_reg
        port map(
            i_CLK       => iCLK,
            i_RST       => iRST,
            i_PC        => s_PC_EX,
            i_ALUResult => s_ALUResult,
            i_ReadData2 => s_ReadData2_EX,
            i_Funct3    => s_Funct3_EX,
            i_Rd        => s_Rd_EX,
            i_Imm       => s_Imm_EX,
            i_Halt      => s_Halt_EX,
            i_MemRead   => s_MemRead_EX,
            i_MemWrite  => s_MemWrite_EX,
            i_RegWrite  => s_RegWrite_EX,
            i_MemtoReg  => s_MemtoReg_EX,
            o_PC        => s_PC_MEM,
            o_ALUResult => s_ALUResult_MEM,
            o_ReadData2 => s_ReadData2_MEM,
            o_Funct3    => s_Funct3_MEM,
            o_Rd        => s_Rd_MEM,
            o_Imm       => s_Imm_MEM,
            o_MemRead   => s_MemRead_MEM,
            o_MemWrite  => s_MemWrite_MEM,
            o_RegWrite  => s_RegWrite_MEM,
            o_MemtoReg  => s_MemtoReg_MEM,
            o_Halt      => s_Halt_MEM
        );

    s_DMemAddr <= s_ALUResult_MEM;

    U_LOADEXT : entity work.load_extender
        port map(
            i_DMemOut  => s_DMemOut,
            i_Funct3   => s_Funct3_MEM,
            i_AddrLSB  => s_ALUResult_MEM(1 downto 0),
            o_ReadData => s_LoadData
        );

    -----------------------------------------------------------------
    -- MEM/WB register
    -----------------------------------------------------------------
    U_MEM_WB : entity work.mem_wb_reg
        port map(
            i_CLK      => iCLK,
            i_RST      => iRST,
            i_PC        => s_PC_MEM,
            i_ALUResult => s_ALUResult_MEM,
            i_LoadData  => s_LoadData,
            i_Imm       => s_Imm_MEM,
            i_Rd        => s_Rd_MEM,
            i_Halt      => s_Halt_MEM,
            i_RegWrite  => s_RegWrite_MEM,
            i_MemtoReg  => s_MemtoReg_MEM,
            o_PC        => s_PC_WB,
            o_ALUResult => s_ALUResult_WB,
            o_LoadData  => s_LoadData_WB,
            o_Imm       => s_Imm_WB,
            o_Rd        => s_Rd_WB,
            o_RegWrite  => s_RegWrite_WB,
            o_MemtoReg  => s_MemtoReg_WB,
            o_Halt      => s_Halt_WB
        );

    -----------------------------------------------------------------
    -- Writeback MUX
    -----------------------------------------------------------------
    with s_MemtoReg_WB select
        s_RegWrData <= s_ALUResult_WB                                 when "00",
                       s_LoadData_WB                                  when "01",
                       std_logic_vector(unsigned(s_PC_WB) + 4)        when "10",
                       s_Imm_WB                                       when "11",
                       (others => '0')                                when others;

    -----------------------------------------------------------------
    -- Testbench signals / enables
    -----------------------------------------------------------------
    s_RegWr <= s_RegWrite_WB when (s_Rd_WB /= "00000" and s_Halt_WB = '0') else '0';

    s_DMemWr <= s_MemWrite_MEM when s_Halt_MEM = '0' else '0';

    s_RegWrAddr <= s_Rd_WB;

    s_Ovfl <= '0';
    s_Halt <= s_Halt_WB;

    s_DMemData <= s_ReadData2_MEM;

    -----------------------------------------------------------------
    -- Simulation instrumentation (lightweight)
    -----------------------------------------------------------------
    sim_report_proc: process
        variable cycle_count : integer := 0;
    begin
        wait until rising_edge(iCLK);
        cycle_count := cycle_count + 1;
        report ("C=" & integer'image(cycle_count)) severity warning;
        report ("PC_ID=0x" & integer'image(to_integer(unsigned(s_PC_ID)))) severity warning;
        report ("Inst_ID(opcode)=0x" & integer'image(to_integer(unsigned(s_Inst_ID(6 downto 0))))) severity warning;
        report ("Rd_WB=" & integer'image(to_integer(unsigned(s_Rd_WB)))) severity warning;
        report ("RegWrite_WB=" & std_logic'image(s_RegWrite_WB)) severity warning;
        report ("MemtoReg_WB=" & integer'image(to_integer(unsigned(s_MemtoReg_WB)))) severity warning;
        report ("RegWrData=0x" & integer'image(to_integer(unsigned(s_RegWrData)))) severity warning;
        report ("LoadData_WB=0x" & integer'image(to_integer(unsigned(s_LoadData_WB)))) severity warning;
        report ("Rd_MEM=" & integer'image(to_integer(unsigned(s_Rd_MEM)))) severity warning;
        report ("RegWrite_MEM=" & std_logic'image(s_RegWrite_MEM)) severity warning;
        report ("MemtoReg_MEM=" & integer'image(to_integer(unsigned(s_MemtoReg_MEM)))) severity warning;
        report ("ALUResult_MEM=0x" & integer'image(to_integer(unsigned(s_ALUResult_MEM)))) severity warning;
        report ("LoadData_MEM=0x" & integer'image(to_integer(unsigned(s_LoadData)))) severity warning;
        report ("RD1_EX=0x" & integer'image(to_integer(unsigned(s_ReadData1_EX)))) severity warning;
        report ("RD2_EX=0x" & integer'image(to_integer(unsigned(s_ReadData2_EX)))) severity warning;
    end process sim_report_proc;

end structure;