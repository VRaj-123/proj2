library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_update_pipeline_reg is

end tb_update_pipeline_reg;


architecture tb of tb_update_pipeline_reg is

-- ======================

-- Clock / Reset

-- ======================



signal iCLK : std_logic := '0';



signal iRST : std_logic := '1';



constant C_CLK_PERIOD : time := 10 ns;



-- ======================



-- Constants

-- ======================



constant C_ZERO32 : std_logic_vector(31 downto 0) := (others => '0');



constant C_ZERO5 : std_logic_vector(4 downto 0) := (others => '0');



constant C_ZERO3 : std_logic_vector(2 downto 0) := (others => '0');



constant C_ZERO7 : std_logic_vector(6 downto 0) := (others => '0');



constant C_ZERO2 : std_logic_vector(1 downto 0) := (others => '0');



constant C_NOP : std_logic_vector(31 downto 0) := x"00000013";



-- ========================



-- IF stage stimulus



-- ========================



signal s_PC_IF : std_logic_vector(31 downto 0) := (others => '0');



signal s_Inst_IF : std_logic_vector(31 downto 0) := C_NOP;



-- =========================



-- Pipeline control per reg



-- =========================



signal s_Stall_IFID : std_logic := '0';



signal s_Flush_IFID : std_logic := '0';



signal s_Stall_IDEX : std_logic := '0';



signal s_Flush_IDEX : std_logic := '0';



signal s_Stall_EXMEM : std_logic := '0';



signal s_Flush_EXMEM : std_logic := '0';



signal s_Stall_MEMWB : std_logic := '0';



signal s_Flush_MEMWB : std_logic := '0';



-- ======================



-- IF/ID outputs



-- ======================



signal s_PC_ID : std_logic_vector(31 downto 0);



signal s_Inst_ID : std_logic_vector(31 downto 0);



-- ======================



-- ID stage dummy signals -> drive ID/EX inputs



-- ======================



signal s_ReadData1_ID : std_logic_vector(31 downto 0) := (others => '0');



signal s_ReadData2_ID : std_logic_vector(31 downto 0) := (others => '0');



signal s_Imm_ID : std_logic_vector(31 downto 0) := (others => '0');



signal s_Funct3_ID : std_logic_vector(2 downto 0) := (others => '0');



signal s_Funct7_ID : std_logic_vector(6 downto 0) := (others => '0');



signal s_Rd_ID : std_logic_vector(4 downto 0) := (others => '0');



signal s_Rs1_ID : std_logic_vector(4 downto 0) := (others => '0');



signal s_Rs2_ID : std_logic_vector(4 downto 0) := (others => '0');



-- control (ID)



signal s_ALUSrcA_ID : std_logic := '0';



signal s_ALUSrcB_ID : std_logic := '0';



signal s_ALUOp_ID : std_logic_vector(1 downto 0) := (others => '0');



signal s_MemRead_ID : std_logic := '0';



signal s_MemWrite_ID : std_logic := '0';



signal s_RegWrite_ID : std_logic := '0';



signal s_MemtoReg_ID : std_logic_vector(1 downto 0) := (others => '0');



signal s_Branch_ID : std_logic := '0';



signal s_Jump_ID : std_logic_vector(1 downto 0) := (others => '0');



signal s_Halt_ID : std_logic := '0';



-- ======================



-- ID/EX outputs



-- ======================



signal s_PC_EX : std_logic_vector(31 downto 0);



signal s_ReadData1_EX : std_logic_vector(31 downto 0);



signal s_ReadData2_EX : std_logic_vector(31 downto 0);



signal s_Imm_EX : std_logic_vector(31 downto 0);



signal s_Funct3_EX : std_logic_vector(2 downto 0);



signal s_Funct7_EX : std_logic_vector(6 downto 0);



signal s_Rd_EX : std_logic_vector(4 downto 0);



signal s_Rs1_EX : std_logic_vector(4 downto 0);



signal s_Rs2_EX : std_logic_vector(4 downto 0);



signal s_ALUSrcA_EX : std_logic;



signal s_ALUSrcB_EX : std_logic;



signal s_ALUOp_EX : std_logic_vector(1 downto 0);



signal s_MemRead_EX : std_logic;



signal s_MemWrite_EX : std_logic;



signal s_RegWrite_EX : std_logic;



signal s_MemtoReg_EX : std_logic_vector(1 downto 0);



signal s_Branch_EX : std_logic;



signal s_Jump_EX : std_logic_vector(1 downto 0);



signal s_Halt_EX : std_logic;



-- ======================



-- EX/MEM outputs



-- ======================



signal s_PC_MEM : std_logic_vector(31 downto 0);



signal s_ALUResult_MEM : std_logic_vector(31 downto 0);



signal s_ReadData2_MEM : std_logic_vector(31 downto 0);



signal s_Imm_MEM : std_logic_vector(31 downto 0);



signal s_Funct3_MEM : std_logic_vector(2 downto 0);



signal s_Rd_MEM : std_logic_vector(4 downto 0);



signal s_MemRead_MEM : std_logic;



signal s_MemWrite_MEM : std_logic;



signal s_RegWrite_MEM : std_logic;



signal s_MemtoReg_MEM : std_logic_vector(1 downto 0);



signal s_Halt_MEM : std_logic;



-- ======================



-- MEM/WB outputs



-- ======================



signal s_PC_WB : std_logic_vector(31 downto 0);



signal s_ALUResult_WB : std_logic_vector(31 downto 0);



signal s_LoadData_WB : std_logic_vector(31 downto 0);



signal s_Imm_WB : std_logic_vector(31 downto 0);



signal s_Rd_WB : std_logic_vector(4 downto 0);



signal s_RegWrite_WB : std_logic;



signal s_MemtoReg_WB : std_logic_vector(1 downto 0);



signal s_Halt_WB : std_logic;



-- fake datapath producers



signal s_ALUResult_EX_fake : std_logic_vector(31 downto 0) := (others => '0');



signal s_LoadData_MEM_fake : std_logic_vector(31 downto 0) := (others => '0');



begin



-- ======================



-- Clock



-- ======================



 p_clk : process



begin



 iCLK <= '0';



wait for C_CLK_PERIOD/2;



 iCLK <= '1';



wait for C_CLK_PERIOD/2;



end process;



-- ======================



-- DUT instances



-- ======================



 U_IF_ID : entity work.fs_if_id_reg



port map(



 i_CLK => iCLK,



 i_RST => iRST,



 i_Stall => s_Stall_IFID,



 i_Flush => s_Flush_IFID,



 i_PC => s_PC_IF,



 i_Inst => s_Inst_IF,



 o_PC => s_PC_ID,



 o_Inst => s_Inst_ID



 );



 U_ID_EX : entity work.fs_id_ex_reg



port map(



 i_CLK => iCLK,



 i_RST => iRST,



 i_Stall => s_Stall_IDEX,



 i_Flush => s_Flush_IDEX,



 i_PC => s_PC_ID,



 i_ReadData1 => s_ReadData1_ID,



 i_ReadData2 => s_ReadData2_ID,



 i_Imm => s_Imm_ID,



 i_Funct3 => s_Funct3_ID,



 i_Funct7 => s_Funct7_ID,



 i_Rd => s_Rd_ID,



 i_ALUSrcA => s_ALUSrcA_ID,



 i_ALUSrcB => s_ALUSrcB_ID,



 i_ALUOp => s_ALUOp_ID,



 i_MemRead => s_MemRead_ID,



 i_MemWrite => s_MemWrite_ID,



 i_RegWrite => s_RegWrite_ID,



 i_MemtoReg => s_MemtoReg_ID,



 i_Branch => s_Branch_ID,



 i_Jump => s_Jump_ID,



 i_Halt => s_Halt_ID,



 i_Rs1Addr => s_Rs1_ID,



 i_Rs2Addr => s_Rs2_ID,



 o_PC => s_PC_EX,



 o_ReadData1 => s_ReadData1_EX,



 o_ReadData2 => s_ReadData2_EX,



 o_Imm => s_Imm_EX,



 o_Funct3 => s_Funct3_EX,



 o_Funct7 => s_Funct7_EX,



 o_Rd => s_Rd_EX,



 o_ALUSrcA => s_ALUSrcA_EX,



 o_ALUSrcB => s_ALUSrcB_EX,



 o_ALUOp => s_ALUOp_EX,



 o_MemRead => s_MemRead_EX,



 o_MemWrite => s_MemWrite_EX,



 o_RegWrite => s_RegWrite_EX,



 o_MemtoReg => s_MemtoReg_EX,



 o_Branch => s_Branch_EX,



 o_Jump => s_Jump_EX,



 o_Halt => s_Halt_EX,



 o_Rs1Addr => s_Rs1_EX,



 o_Rs2Addr => s_Rs2_EX



 );



 U_EX_MEM : entity work.fs_ex_mem_reg



port map(



 i_CLK => iCLK,



 i_RST => iRST,



 i_Stall => s_Stall_EXMEM,



 i_Flush => s_Flush_EXMEM,



 i_PC => s_PC_EX,



 i_ALUResult => s_ALUResult_EX_fake,



 i_ReadData2 => s_ReadData2_EX,



 i_Imm => s_Imm_EX,



 i_Funct3 => s_Funct3_EX,



 i_Rd => s_Rd_EX,



 i_MemRead => s_MemRead_EX,



 i_MemWrite => s_MemWrite_EX,



 i_RegWrite => s_RegWrite_EX,



 i_MemtoReg => s_MemtoReg_EX,



 i_Halt => s_Halt_EX,



 o_PC => s_PC_MEM,



 o_ALUResult => s_ALUResult_MEM,



 o_ReadData2 => s_ReadData2_MEM,



 o_Imm => s_Imm_MEM,



 o_Funct3 => s_Funct3_MEM,



 o_Rd => s_Rd_MEM,



 o_MemRead => s_MemRead_MEM,



 o_MemWrite => s_MemWrite_MEM,



 o_RegWrite => s_RegWrite_MEM,



 o_MemtoReg => s_MemtoReg_MEM,



 o_Halt => s_Halt_MEM



 );



 U_MEM_WB : entity work.fs_mem_wb_reg



port map(



 i_CLK => iCLK,



 i_RST => iRST,



 i_Stall => s_Stall_MEMWB,



 i_Flush => s_Flush_MEMWB,



 i_PC => s_PC_MEM,



 i_ALUResult => s_ALUResult_MEM,



 i_LoadData => s_LoadData_MEM_fake,



 i_Imm => s_Imm_MEM,



 i_Rd => s_Rd_MEM,



 i_Halt => s_Halt_MEM,



 i_RegWrite => s_RegWrite_MEM,



 i_MemtoReg => s_MemtoReg_MEM,



 o_PC => s_PC_WB,



 o_ALUResult => s_ALUResult_WB,



 o_LoadData => s_LoadData_WB,



 o_Imm => s_Imm_WB,



 o_Rd => s_Rd_WB,



 o_RegWrite => s_RegWrite_WB,



 o_MemtoReg => s_MemtoReg_WB,



 o_Halt => s_Halt_WB



 );



-- ======================



-- Driver: set inputs on FALLING edge



-- ======================



 p_driver : process



variable cyc : integer := 0;



begin



iRST <= '1';



-- hold reset for a few cycles



wait for 30 ns;



wait until falling_edge(iCLK);



 iRST <= '0';



while cyc < 30 loop



wait until falling_edge(iCLK);



-- default controls



 s_Stall_IFID <= '0'; s_Flush_IFID <= '0';



 s_Stall_IDEX <= '0'; s_Flush_IDEX <= '0';



 s_Stall_EXMEM <= '0'; s_Flush_EXMEM <= '0';



 s_Stall_MEMWB <= '0'; s_Flush_MEMWB <= '0';



-- schedule individual tests



-- (these will be sampled at NEXT rising edge)



if cyc = 6 then



 s_Stall_IFID <= '1';



elsif cyc = 8 then



 s_Flush_IDEX <= '1';



elsif cyc = 10 then



 s_Stall_EXMEM <= '1';



elsif cyc = 12 then



 s_Flush_MEMWB <= '1';



end if;



-- IF values (tagged)



 s_PC_IF <= std_logic_vector(to_unsigned(cyc * 4, 32));



 s_Inst_IF <= std_logic_vector(to_unsigned(16#A000# + cyc, 32));



-- ID dummy datapath



 s_ReadData1_ID <= std_logic_vector(to_unsigned(16#1000# + cyc, 32));



 s_ReadData2_ID <= std_logic_vector(to_unsigned(16#2000# + cyc, 32));



 s_Imm_ID <= std_logic_vector(to_unsigned(16#3000# + cyc, 32));



 s_Funct3_ID <= std_logic_vector(to_unsigned(cyc mod 8, 3));



 s_Funct7_ID <= std_logic_vector(to_unsigned(cyc mod 128, 7));



 s_Rd_ID <= std_logic_vector(to_unsigned((cyc mod 31) + 1, 5));



 s_Rs1_ID <= std_logic_vector(to_unsigned((cyc mod 31) + 1, 5));



 s_Rs2_ID <= std_logic_vector(to_unsigned(((cyc+1) mod 31) + 1, 5));



-- ID dummy control



 s_ALUSrcA_ID <= '0';



 s_ALUSrcB_ID <= '1';



 s_ALUOp_ID <= "10";



 s_MemRead_ID <= '0';



 s_MemWrite_ID <= '0';



 s_RegWrite_ID <= '1';



 s_MemtoReg_ID <= "00";



 s_Branch_ID <= '0';



 s_Jump_ID <= "00";



 s_Halt_ID <= '0';



-- fake EX/MEM & MEM load tags



 s_ALUResult_EX_fake <= std_logic_vector(to_unsigned(16#4000# + cyc, 32));



 s_LoadData_MEM_fake <= std_logic_vector(to_unsigned(16#5000# + cyc, 32));



 cyc := cyc + 1;



end loop;



wait;



end process;



-- ======================



-- Monitor with simple reference model



-- ======================



 p_monitor : process



-- expected IF/ID



variable e_ifid_pc : std_logic_vector(31 downto 0) := (others => '0');



variable e_ifid_inst : std_logic_vector(31 downto 0) := C_NOP;



-- expected ID/EX (subset)



variable e_idex_pc : std_logic_vector(31 downto 0) := (others => '0');



variable e_idex_rd : std_logic_vector(4 downto 0) := (others => '0');



variable e_idex_rs1 : std_logic_vector(4 downto 0) := (others => '0');



variable e_idex_rs2 : std_logic_vector(4 downto 0) := (others => '0');



variable e_idex_regwrite : std_logic := '0';



variable e_idex_memread : std_logic := '0';



variable e_idex_memwrite : std_logic := '0';



-- expected EX/MEM



variable e_exmem_pc : std_logic_vector(31 downto 0) := (others => '0');



variable e_exmem_alures : std_logic_vector(31 downto 0) := (others => '0');



variable e_exmem_rd : std_logic_vector(4 downto 0) := (others => '0');



variable e_exmem_regwrite : std_logic := '0';



-- expected MEM/WB



variable e_memwb_pc : std_logic_vector(31 downto 0) := (others => '0');



variable e_memwb_alures : std_logic_vector(31 downto 0) := (others => '0');



variable e_memwb_rd : std_logic_vector(4 downto 0) := (others => '0');



variable e_memwb_regwrite : std_logic := '0';



begin



wait until rising_edge(iCLK);

wait for 1 ns;



if iRST = '1' then



-- reset expectations



 e_ifid_pc := (others => '0');



 e_ifid_inst := C_NOP;



 e_idex_pc := (others => '0');



 e_idex_rd := (others => '0');



 e_idex_rs1 := (others => '0');



 e_idex_rs2 := (others => '0');



 e_idex_regwrite := '0';



 e_idex_memread := '0';



 e_idex_memwrite := '0';



 e_exmem_pc := (others => '0');



 e_exmem_alures := (others => '0');



 e_exmem_rd := (others => '0');



 e_exmem_regwrite := '0';



 e_memwb_pc := (others => '0');



 e_memwb_alures := (others => '0');



 e_memwb_rd := (others => '0');



 e_memwb_regwrite := '0';



else



-- ================= IF/ID expected update



if s_Flush_IFID = '1' then



 e_ifid_pc := (others => '0');



 e_ifid_inst := C_NOP;



elsif s_Stall_IFID = '1' then



-- hold



null;



else



 e_ifid_pc := s_PC_IF;



 e_ifid_inst := s_Inst_IF;



end if;



-- ================= ID/EX expected update (subset check)



if s_Flush_IDEX = '1' then



 e_idex_pc := (others => '0');



 e_idex_rd := (others => '0');



 e_idex_rs1 := (others => '0');



 e_idex_rs2 := (others => '0');



 e_idex_regwrite := '0';



 e_idex_memread := '0';



 e_idex_memwrite := '0';



elsif s_Stall_IDEX = '1' then



null;



else



 e_idex_pc := e_ifid_pc; -- ID uses IF/ID output



 e_idex_rd := s_Rd_ID;



 e_idex_rs1 := s_Rs1_ID;



 e_idex_rs2 := s_Rs2_ID;



 e_idex_regwrite := s_RegWrite_ID;



 e_idex_memread := s_MemRead_ID;



 e_idex_memwrite := s_MemWrite_ID;



end if;



-- ================= EX/MEM expected update



if s_Flush_EXMEM = '1' then



 e_exmem_pc := (others => '0');



 e_exmem_alures := (others => '0');



 e_exmem_rd := (others => '0');



 e_exmem_regwrite := '0';



elsif s_Stall_EXMEM = '1' then



null;



else



 e_exmem_pc := e_idex_pc;



 e_exmem_alures := s_ALUResult_EX_fake;



 e_exmem_rd := e_idex_rd;



 e_exmem_regwrite := e_idex_regwrite;



end if;



-- ================= MEM/WB expected update



if s_Flush_MEMWB = '1' then



 e_memwb_pc := (others => '0');



 e_memwb_alures := (others => '0');



 e_memwb_rd := (others => '0');



 e_memwb_regwrite := '0';



elsif s_Stall_MEMWB = '1' then



null;



else



 e_memwb_pc := e_exmem_pc;



 e_memwb_alures := e_exmem_alures;



 e_memwb_rd := e_exmem_rd;



 e_memwb_regwrite := e_exmem_regwrite;



end if;



end if;



-- ======================



-- Assertions (match expected vs DUT)



-- ======================



assert s_PC_ID = e_ifid_pc



report "IF/ID PC mismatch"



severity error;



assert s_Inst_ID = e_ifid_inst



report "IF/ID Inst mismatch"



severity error;



assert s_PC_EX = e_idex_pc



report "ID/EX PC mismatch"



severity error;



assert s_Rd_EX = e_idex_rd



report "ID/EX Rd mismatch"



severity error;



assert s_Rs1_EX = e_idex_rs1



report "ID/EX Rs1Addr mismatch"



severity error;



assert s_Rs2_EX = e_idex_rs2



report "ID/EX Rs2Addr mismatch"



severity error;



assert s_RegWrite_EX = e_idex_regwrite



report "ID/EX RegWrite mismatch"



severity error;



assert s_MemRead_EX = e_idex_memread



report "ID/EX MemRead mismatch"



severity error;



assert s_MemWrite_EX = e_idex_memwrite



report "ID/EX MemWrite mismatch"



severity error;



assert s_ALUResult_MEM = e_exmem_alures



report "EX/MEM ALUResult mismatch"



severity error;



assert s_PC_WB = e_memwb_pc



report "MEM/WB PC mismatch"



severity error;



assert s_ALUResult_WB = e_memwb_alures



report "MEM/WB ALUResult mismatch"



severity error;



assert s_RegWrite_WB = e_memwb_regwrite



report "MEM/WB RegWrite mismatch"



severity error;



end process;



end tb;