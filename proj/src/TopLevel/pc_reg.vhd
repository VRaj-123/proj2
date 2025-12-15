-------------------------------------------------------------------------
-- Stores the current instruction address
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pc_reg is
    generic(N : integer := 32);
    port(
        i_CLK    : in std_logic;                      -- Clock
        i_RST    : in std_logic;                      -- Reset (High Active)
        i_WE     : in std_logic;                      -- Write Enable (항상 1)
        i_NextPC : in std_logic_vector(N-1 downto 0); -- From Fetch Logic
        o_PC     : out std_logic_vector(N-1 downto 0) -- To IMem & Fetch Logic
    );
end pc_reg;

architecture behavior of pc_reg is
    -- PC의 현재 값을 저장할 내부 신호 (초기값 0)
    signal s_PC : std_logic_vector(N-1 downto 0) := (others => '0');
begin

    process(i_CLK, i_RST)
    begin
        -- 1. 리셋 신호가 들어 오면 PC를 0으로 초기화
        -- (Lab 설정에 따라 0x00400000 등으로 바꿔야 할 수도 있음)
        if (i_RST = '1') then
            s_PC <= x"00400000"; 
            
        -- 2. 클럭이 뛸 때(Rising Edge) 값을 업데이트
        elsif rising_edge(i_CLK) then
            if (i_WE = '1') then
                s_PC <= i_NextPC;
            end if;
        end if;
    end process;

    -- 출력 연결
    o_PC <= s_PC;

end behavior;