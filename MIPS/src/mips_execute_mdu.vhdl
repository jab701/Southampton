library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library MIPS_Common;
use MIPS_Common.ALL;

entity pipeline_execute_mdu is
  port (clk   : in std_logic;
        rst_n : in std_logic;

        op1 : in std_logic_vector(31 downto 0); -- Multiplier/Dividend
        op2 : in std_logic_vector(31 downto 0); -- Multiplicand/Divisor

        mode       : in std_logic;
        signedmode : in std_logic;

        start  : in std_logic;
        stop   : in std_logic;

        idle : out std_logic;

        resulthi : out std_logic_vector (31 downto 0);
        resultlo : out std_logic_vector (31 downto 0));
end entity pipeline_execute_mdu;

architecture rtl of pipeline_execute_mdu is

signal Result_D, Result_Q : std_logic_vector(63 downto 0);
signal Counter_D, Counter_Q : std_logic_vector(7 downto 0);

signal Adder_Output : std_logic_vector(31 downto 0);
signal Adder_Carry : std_logic;

type STATES is (state_idle, state_mult, state_div);

signal result_d : std_logic_vector(63 downto 0);
signal result_q : std_logic_vector(63 downto 0);

signal counter_d : std_logic_vector(7 downto 0);
signal counter_q : std_logic_vector(7 downto 0);

signal state_d : STATES;
signal state_q : STATES;

signal op1_l : std_logic_vector(31 downto 0);
signal op2_l : std_logic_vector(31 downto 0);

signal op2_d : std_logic_vector(31 downto 0);
signal op2_q : std_logic_vector(31 downto 0);

signal op1msb_d : std_logic;
signal op1msb_q : std_logic;

signal op2msb_d : std_logic;
signal op2msb_q : std_logic;

signal mode_d : std_logic;
signal mode_q : std_logic;

signal signedmode_d : std_logic;
signal signedmode_q : std_logic;
begin

   p_twoscomp_in: process(op1, op2, signedmode)
      variable op1_inv : std_logic_vector(31 downto 0);
      variable op2_inv : std_logic_vector(31 downto 0);
   begin
      op1_inv := NOT(op1);
      op2_inv := NOT(op2);

      if (signedmode = '1' and op1(31) = '1') then
         op1_l <= op1_inv + 1;
      else
         op1_l <= op1;
      end if;

      if (signedmode = '1' and op2(31) = '1') then
         op2_l <= op2_inv + 1;
      else
         op2_l <= op2;
      end if;
   end process p_twoscomp_in;

   p_twoscomp_out: process(result_q, mode_q, signedmode_q, op1msb_q, op2msb_q)
      variable mult_inv  : std_logic_vector(63 downto 0);
      variable mult_2cmp : std_logic_vector(63 downto 0);
      variable divq_inv  : std_logic_vector(31 downto 0);
      variable divr_inv  : std_logic_vector(31 downto 0);
   begin
      mult_inv  := NOT(result_q);
      mult_2cmp := mult_inv + 1;

      divq_inv := NOT(result_q(31 downto 0));
      divr_inv := "0" & NOT(result_q(63 downto 33));

      if (mode_q = '0') -- Multiply
         if (signedmode AND (op1msb_q XOR op2msb_q)) = '1' then
            resulthi <= mult_2cmp(63 downto 32);
            resultlo <= mult_2cmp(31 downto 0);
         else
            resulthi <= result_q(63 downto 32);
            resultlo <= result_q(31 downto 0);
         end if;
      else -- divide
         -- Quotant
         if (signedmode AND (op1msb_q XOR op2msb_q)) = '1' then
            resultlo <= divq_inv + 1;
         else
            resultlo <= result_q(31 downto 0);
         end if;
         -- Remainder
         if (signedmode AND op1msb_q) = '1' then
            resulthi <= divr_inv + 1;
         else
            resulthi <= "0" & result_q(63 downto 33);
         end if;
      end if
   end process p_twocomp_out;

adder: entity MIPS_Common.Adder32b
       port map(a => Result_Q(63 downto 32),
                b => b_nosign,
                sub => mode,
                q => Adder_Output,
                carry_out => Adder_Carry);

seq: process (Clock) is
begin
  if rising_edge(Clock) then
    if (nReset = '0') then
      Result_Q <= (others => '0');
      Counter_Q <= (others => '0');
      State_Q <= Idle;
    elsif (CKE = '1') then
      Result_Q <= Result_D;
      Counter_Q <= Counter_D;
      State_Q <= State_D;
    end if;
  end if;
end process seq;

com: Process (mode, State_Q, Start, Counter_Q, Result_Q, a_nosign, Adder_Output, Adder_Carry) is
   variable op2_2cmp : std_logic_vector(31 downto 0);

   variable alu_op1 : std_logic_vector(32 downto 0);
   variable alu_op2 : std_logic_vector(32 downto 0);
   variable alu_res : std_logic_vector(32 downto 0);
begin
  op2_2cmp := not(op2_l) + 1;

  -- ALU
  alu_op1 := result_q(63) & result_q(63 downto 32);
  alu_op2 := op2_q(31) & op2_q;
  alu_res := alu_op1 + alu_op2;

  case State_Q is
  when Idle =>
    Running <= '0';
    Counter_D <= (others => '0');
    Result_D <= Result_Q;

    if (Start = '1') then
      State_D <= Load;
    else
      State_D <= Idle;
    end if;

  when Load =>
    Running <= '1';
    Counter_D <= (others => '0');

    if (Mode = '0') then
      -- Multiply
      Result_D(63 downto 32) <= (others => '0');
      Result_D(31 downto 0) <= a_nosign;
    else
      -- Divide
      Result_D(63 downto 33) <= (others => '0');
      Result_D(32 downto 1) <= a_nosign;
      Result_D(0) <= '0';
    end if;

    State_D <= Active;

  when Active =>
    Running <= '1';
    Counter_D <= Counter_Q + 1;

    if (mode = '0') then
      -- Multiply
      if (Result_Q(0) = '1') then
        Result_D(63) <= Adder_Carry;
        Result_D(62 downto 31) <= Adder_Output;
      else
        Result_D(63) <= '0';
        Result_D(62 downto 31) <= Result_Q(63 downto 32);
      end if;

      Result_D(30 downto 0) <= Result_Q(31 downto 1);
    else
      -- Divide
      if (Adder_Output(31) = '0') then
        Result_D(63 downto 33) <= Adder_Output(30 downto 0);
        Result_D(32 downto 1)  <= Result_Q(31 downto 0);
        Result_D(0) <= '1';
      else
        Result_D(63 downto 1) <= Result_Q(62 downto 0);
        Result_D(0) <= '0';
      end if;
    end if;

    if (Counter_Q = x"1F") then
      State_D <= Done;
    else
      State_D <= Active;
    end if;

  when Done =>
    Running <= '0';
    Counter_D <= (others => '0');
    Result_D <= Result_Q;
    State_D <= Idle;

  end case;

end process com;
end architecture rtl;