library IEEE;
use IEEE.std_logic_1164.all;

entity alu_control is
    port(
        i_ALUOp  : in  std_logic_vector(1 downto 0);
        i_Funct3 : in  std_logic_vector(2 downto 0);
        i_Funct7 : in  std_logic_vector(6 downto 0);
        o_ALUCtrl: out std_logic_vector(3 downto 0)
    );
end alu_control;

architecture behavior of alu_control is
begin
    process(i_ALUOp, i_Funct3, i_Funct7)
    begin
        case i_ALUOp is

            -- 00: Load/Store/AUIPC
            when "00" =>
                o_ALUCtrl <= "0010";  -- ADD

            -- 01: Branch
            when "01" =>
                o_ALUCtrl <= "0110";  -- SUB (branch compare)

            -- 10: R-type
            when "10" =>
                case i_Funct3 is
                    when "000" => -- ADD/SUB
                        if i_Funct7 = "0100000" then
                            o_ALUCtrl <= "0110"; -- SUB
                        else
                            o_ALUCtrl <= "0010"; -- ADD
                        end if;

                    when "001" => o_ALUCtrl <= "1001"; -- SLL
                    when "010" => o_ALUCtrl <= "0111"; -- SLT
                    when "011" => o_ALUCtrl <= "1100"; -- SLTU
                    when "100" => o_ALUCtrl <= "0100"; -- XOR

                    when "101" => -- SRL/SRA
                        if i_Funct7 = "0100000" then
                            o_ALUCtrl <= "1010"; -- SRA
                        else
                            o_ALUCtrl <= "1000"; -- SRL
                        end if;

                    when "110" => o_ALUCtrl <= "0001"; -- OR
                    when "111" => o_ALUCtrl <= "0000"; -- AND
                    when others => o_ALUCtrl <= "0000";
                end case;

            -- 11: I-type ALU  ★ 핵심
            when "11" =>
                case i_Funct3 is
                    when "000" => o_ALUCtrl <= "0010"; -- ADDI 무조건 ADD
                    when "001" => o_ALUCtrl <= "1001"; -- SLLI
                    when "010" => o_ALUCtrl <= "0111"; -- SLTI
                    when "011" => o_ALUCtrl <= "1100"; -- SLTIU
                    when "100" => o_ALUCtrl <= "0100"; -- XORI
                    when "110" => o_ALUCtrl <= "0001"; -- ORI
                    when "111" => o_ALUCtrl <= "0000"; -- ANDI

                    when "101" =>  -- SRLI/SRAI
                        -- I-type shift는 funct7(5)만 구분해도 충분
                        if i_Funct7(5) = '1' then
                            o_ALUCtrl <= "1010"; -- SRAI
                        else
                            o_ALUCtrl <= "1000"; -- SRLI
                        end if;

                    when others => o_ALUCtrl <= "0000";
                end case;

            when others =>
                o_ALUCtrl <= "0000";

        end case;
    end process;
end behavior;