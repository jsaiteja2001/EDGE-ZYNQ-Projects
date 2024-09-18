--------------------------------------------------------------------------------
--
--   FileName:         gesture.vhd
--   Dependencies:     i2c_master.vhd (Version 2.2)
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 07/31/2019 Scott Larson
--     Initial Public Release
-- 
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY gesture1 IS
  GENERIC(
    sys_clk_freq     : INTEGER := 50_000_000;                      --input clock speed from user logic in Hz                             --desired resolution of temperature data in bits
    sensor_addr : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1110011"); --I2C address of the temp sensor pmod
  PORT(
    clk         : IN    STD_LOGIC;                                 --system clock
    reset_n     : IN    STD_LOGIC;                                 --asynchronous active-low reset
    scl         : INOUT STD_LOGIC;                                 --I2C serial clock
    sda         : INOUT STD_LOGIC;  
    gesture 	    : out  STD_LOGIC_VECTOR(3 downto 0)  
   );   
END gesture1;

ARCHITECTURE behavior OF gesture1 IS
  TYPE machine IS(start,bank_address,read_data,output_result,bank0_select,init_state,bank0_select_new,gesture_init,gesture_reg,read_data1,gesture_data,gesture_delay); --needed states
      type t_matrix is array (0 to 50, 0 to 1) of std_logic_vector(7 downto 0);
  
  signal initRegisterArray  : t_matrix :=(
  (X"EF",X"00"),
    (X"37",X"07"),
    (X"38",X"17"),
    (X"39",X"06"),
    (X"41",X"00"),
    (X"42",X"00"),
    (X"46",X"2D"),
    (X"47",X"0F"),
    (X"48",X"3C"),
    (X"49",X"00"),
    (X"4A",X"1E"),
    (X"4C",X"20"),
    (X"51",X"10"),
    (X"5E",X"10"),
    (X"60",X"27"),
    (X"80",X"42"),
    (X"81",X"44"),
    (X"82",X"04"),
    (X"8B",X"01"),
    (X"90",X"06"),
    (X"95",X"0A"),
    (X"96",X"0C"),
    (X"97",X"05"),
    (X"9A",X"14"),
    (X"9C",X"3F"),
    (X"A5",X"19"),
    (X"CC",X"19"),
    (X"CD",X"0B"),
    (X"CE",X"13"),
    (X"CF",X"64"),
    (X"D0",X"21"),
    (X"EF",X"01"),
    (X"02",X"0F"),
    (X"03",X"10"),
    (X"04",X"02"),
    (X"25",X"01"),
    (X"27",X"39"),
    (X"28",X"7F"),
    (X"29",X"08"),
    (X"3E",X"FF"),
    (X"5E",X"3D"),
    (X"65",X"96"),
    (X"67",X"97"),
    (X"69",X"CD"),
    (X"6A",X"01"),
    (X"6D",X"2C"),
    (X"6E",X"01"),
    (X"72",X"01"),
    (X"73",X"35"),
    (X"74",X"00"),
    (X"77",X"01")
);
type t_matrix1 is array (0 to 29, 0 to 1) of std_logic_vector(7 downto 0);
  
  signal initGestureArray  : t_matrix1 :=(
  (X"EF",X"00"),
  (X"41",X"00"),
  (X"42",X"00"),
  (X"EF",X"00"),
  (X"48",X"3C"),
  (X"49",X"00"),
  (X"51",X"10"),
  (X"83",X"20"),
  (X"9F",X"F9"),
  (X"EF",X"01"),
  (X"01",X"1E"),
  (X"02",X"0F"),
  (X"03",X"10"),
  (X"04",X"02"),
  (X"41",X"40"),
  (X"43",X"30"),
  (X"65",X"96"),
  (X"66",X"00"),
  (X"67",X"97"),
  (X"68",X"01"),
  (X"69",X"CD"),
  (X"6A",X"01"),
  (X"6B",X"B0"),
  (X"6C",X"04"),
  (X"6D",X"2C"),
  (X"6E",X"01"),
  (X"74",X"00"),
  (X"EF",X"00"),
  (X"41",X"FF"),
  (X"42",X"01")
  );

  SIGNAL state       : machine;                       --state machine
  SIGNAL config      : STD_LOGIC_VECTOR(7 DOWNTO 0);  --value to set the Sensor Configuration Register
  SIGNAL i2c_ena     : STD_LOGIC;                     --i2c enable signal
  SIGNAL i2c_addr    : STD_LOGIC_VECTOR(6 DOWNTO 0);  --i2c address signal
  SIGNAL i2c_rw      : STD_LOGIC;                     --i2c read/write command signal
  SIGNAL i2c_data_wr : STD_LOGIC_VECTOR(7 DOWNTO 0);  --i2c write data
  SIGNAL i2c_data_rd : STD_LOGIC_VECTOR(7 DOWNTO 0);  --i2c read data
  SIGNAL i2c_busy    : STD_LOGIC;                     --i2c busy signal
--  signal gesture: STD_LOGIC_VECTOR(3 DOWNTO 0):="0000";
  SIGNAL temp_data1,temp_data2:STD_LOGIC_VECTOR(7 DOWNTO 0):=(others=>'0'); 
  SIGNAL busy_prev,i2c_ack_err   : STD_LOGIC;                     --previous value of i2c busy signal
  SIGNAL temp_data   : STD_LOGIC_VECTOR(7 DOWNTO 0); --temperature data buffer
signal i: integer :=0 ;

  COMPONENT i2c_master IS
    GENERIC(
     input_clk : INTEGER;  --input clock speed from user logic in Hz
     bus_clk   : INTEGER); --speed the i2c bus (scl) will run at in Hz
    PORT(
     clk       : IN     STD_LOGIC;                    --system clock
     reset_n   : IN     STD_LOGIC;                    --active low reset
     ena       : IN     STD_LOGIC;                    --latch in command
     addr      : IN     STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
     rw        : IN     STD_LOGIC;                    --'0' is write, '1' is read
     data_wr   : IN     STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
     busy      : OUT    STD_LOGIC;                    --indicates transaction in progress
     data_rd   : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
     ack_error : BUFFER STD_LOGIC;                    --flag if improper acknowledge from slave
     sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
     scl       : INOUT  STD_LOGIC);                   --serial clock output of i2c bus
  END COMPONENT;
BEGIN
  --instantiate the i2c master
  i2c_master_0:  i2c_master
    GENERIC MAP(input_clk => sys_clk_freq, bus_clk => 400_000)
    PORT MAP(clk => clk, reset_n => reset_n, ena => i2c_ena, addr => i2c_addr,
             rw => i2c_rw, data_wr => i2c_data_wr, busy => i2c_busy,
             data_rd => i2c_data_rd, ack_error => i2c_ack_err, sda => sda,
             scl => scl);


  PROCESS(clk, reset_n)
    VARIABLE busy_cnt : INTEGER RANGE 0 TO 2 := 0;               --counts the busy signal transistions during one transaction
    VARIABLE counter  : INTEGER RANGE 0 TO sys_clk_freq/10 := 0; --counts 100ms to wait before communicating
  BEGIN
    IF(reset_n = '0') THEN               --reset activated
      counter := 0;                        --clear wait counter
      i2c_ena <= '0';                      --clear i2c enable
      busy_cnt := 0;                       --clear busy counter
      gesture <= (OTHERS => '0'); 
          --clear temperature result output
      state <= start;                      --return to start state
    ELSIF(clk'EVENT AND clk = '1') THEN  --rising edge of system clock
      CASE state IS                        --state machine
      
        --give temp sensor 100ms to power up before communicating
        WHEN start =>
          IF(counter < sys_clk_freq/10) THEN   --100ms not yet reached
            counter := counter + 1;              --increment counter
          ELSE                                 --100ms reached
            counter := 0;                        --clear counter
            state <= bank_address;             --advance to setting the resolution
          END IF;
      
        WHEN bank_address =>
          busy_prev <= i2c_busy;                       --capture the value of the previous i2c busy signal
          IF(busy_prev = '0' AND i2c_busy = '1') THEN  --i2c busy just went high
            busy_cnt := busy_cnt + 1;                    --counts the times busy has gone from low to high during transaction
          END IF;
          CASE busy_cnt IS                             --busy_cnt keeps track of which command we are on
            WHEN 0 =>                                    --no command latched in yet
              i2c_ena <= '1';                              --initiate the transaction
              i2c_addr <= sensor_addr;                --set the address of the temp sensor
              i2c_rw <= '0';                               --command 1 is a write
              i2c_data_wr <= "00000000";                   --set the Register Pointer to the Ambient Temperature Register
            WHEN 1 =>                                    --1st busy high: command 1 latched
              i2c_ena <= '0';                              --deassert enable to stop transaction after command 1
              IF(i2c_busy = '0') THEN                      --transaction complete
                busy_cnt := 0;                               --reset busy_cnt for next transaction
                state <= read_data;                          --advance to reading the data
              END IF;
            WHEN OTHERS => NULL;
          END CASE;
        
        --read ambient temperature data
        WHEN read_data =>
          busy_prev <= i2c_busy;                       --capture the value of the previous i2c busy signal
          IF(busy_prev = '0' AND i2c_busy = '1') THEN  --i2c busy just went high
            busy_cnt := busy_cnt + 1;                    --counts the times busy has gone from low to high during transaction
          END IF;
          CASE busy_cnt IS                             --busy_cnt keeps track of which command we are on
            WHEN 0 =>                                    --no command latched in yet
              i2c_ena <= '1';                              --initiate the transaction
              i2c_addr <= sensor_addr;                --set the address of the temp sensor
              i2c_rw <= '1';                               --command 1 is a read
           
            WHEN 1 =>                                    --2nd busy high: command 2 latched
              i2c_ena <= '0';                              --deassert enable to stop transaction after command 2
              IF(i2c_busy = '0') THEN                      --indicates data read in command 2 is ready
                temp_data(7 DOWNTO 0) <= i2c_data_rd;        --retrieve LSB data from command 2
                busy_cnt := 0;                               --reset busy_cnt for next transaction
                state <= output_result;                      --advance to output the result
              END IF;
           WHEN OTHERS => NULL;
          END CASE;

        --output the temperature data
        WHEN output_result =>
               if (temp_data=X"20") then
                         state <= bank0_select; 
                     
                  else
                   state <= start;                      --advance to output the result          
                end if;   
        
        --set the resolution of the temperature data
                     WHEN bank0_select =>            
                       busy_prev <= i2c_busy;                       --capture the value of the previous i2c busy signal
                       IF(busy_prev = '0' AND i2c_busy = '1') THEN  --i2c busy just went high
                         busy_cnt := busy_cnt + 1;                    --counts the times busy has gone from low to high during transaction
                       END IF;
                       CASE busy_cnt IS                             --busy_cnt keeps track of which command we are on
                         WHEN 0 =>                                    --no command latched in yet
                           i2c_ena <= '1';                              --initiate the transaction
                           i2c_addr <= sensor_addr;                --set the address of the temp sensor
                           i2c_rw <= '0';                               --command 1 is a write
                           i2c_data_wr <= "11101111";                   --set the Register Pointer to the Configuration Register
                         WHEN 1 =>                                    --1st busy high: command 1 latched, okay to issue command 2
                           i2c_data_wr <= "00000000";                       --write the new configuration value to the Configuration Register
                         WHEN 2 =>                                    --2nd busy high: command 2 latched
                           i2c_ena <= '0';                              --deassert enable to stop transaction after command 2
                           IF(i2c_busy = '0') THEN                      --transaction complete
                             busy_cnt := 0;                               --reset busy_cnt for next transaction
                             state <= init_state;                    --advance to setting the Register Pointer for data reads
                           END IF;
                         WHEN OTHERS => NULL;
                       END CASE;
                       
                      WHEN init_state =>            
                       busy_prev <= i2c_busy;                       --capture the value of the previous i2c busy signal
                       IF(busy_prev = '0' AND i2c_busy = '1') THEN  --i2c busy just went high
                         busy_cnt := busy_cnt + 1;                    --counts the times busy has gone from low to high during transaction
                       END IF;
                       CASE busy_cnt IS                             --busy_cnt keeps track of which command we are on
                         WHEN 0 =>                                    --no command latched in yet
                           i2c_ena <= '1';                              --initiate the transaction
                           i2c_addr <= sensor_addr;                --set the address of the temp sensor
                           i2c_rw <= '0';                               --command 1 is a write
                           i2c_data_wr <= initRegisterArray(i,0);                  --set the Register Pointer to the Configuration Register
                         WHEN 1 =>                                    --1st busy high: command 1 latched, okay to issue command 2
                           i2c_data_wr <=  initRegisterArray(i,1);                      --write the new configuration value to the Configuration Register
                         WHEN 2 =>                                    --2nd busy high: command 2 latched
                           i2c_ena <= '0';                              --deassert enable to stop transaction after command 2
                           IF(i2c_busy = '0') THEN                      --transaction complete
                             busy_cnt := 0;  
                         if(i<50) then                                                                                                                            
                           state <= init_state;                                                     --reset busy_cnt for next transaction
                             state <= init_state; 
                               i<=i+1;
                          else                   --advance to setting the Register Pointer for data reads
                           state <= bank0_select_new;
                           i<=0;
                                       --advance to setting the Register Pointer for data reads
                            end if;                    
                             END IF;
                           WHEN OTHERS => NULL;
                         END CASE;
            
                        WHEN bank0_select_new =>            
                        busy_prev <= i2c_busy;                       --capture the value of the previous i2c busy signal
                        IF(busy_prev = '0' AND i2c_busy = '1') THEN  --i2c busy just went high
                          busy_cnt := busy_cnt + 1;                    --counts the times busy has gone from low to high during transaction
                        END IF;
                        CASE busy_cnt IS                             --busy_cnt keeps track of which command we are on
                          WHEN 0 =>                                    --no command latched in yet
                            i2c_ena <= '1';                              --initiate the transaction
                            i2c_addr <= sensor_addr;                --set the address of the temp sensor
                            i2c_rw <= '0';                               --command 1 is a write
                            i2c_data_wr <= "11101111";                   --set the Register Pointer to the Configuration Register
                          WHEN 1 =>                                    --1st busy high: command 1 latched, okay to issue command 2
                            i2c_data_wr <= "00000000";                       --write the new configuration value to the Configuration Register
                          WHEN 2 =>                                    --2nd busy high: command 2 latched
                            i2c_ena <= '0';                              --deassert enable to stop transaction after command 2
                            IF(i2c_busy = '0') THEN                      --transaction complete
                              busy_cnt := 0;                               --reset busy_cnt for next transaction
                              state <= gesture_init;                    --advance to setting the Register Pointer for data reads
                            END IF;
                          WHEN OTHERS => NULL;
                        END CASE;
                          
                        WHEN gesture_init =>            
                         busy_prev <= i2c_busy;                       --capture the value of the previous i2c busy signal
                         IF(busy_prev = '0' AND i2c_busy = '1') THEN  --i2c busy just went high
                           busy_cnt := busy_cnt + 1;                    --counts the times busy has gone from low to high during transaction
                         END IF;
                         CASE busy_cnt IS                             --busy_cnt keeps track of which command we are on
                           WHEN 0 =>                                    --no command latched in yet
                             i2c_ena <= '1';                              --initiate the transaction
                             i2c_addr <= sensor_addr;                --set the address of the temp sensor
                             i2c_rw <= '0';                               --command 1 is a write
                             i2c_data_wr <= initGestureArray(i,0);                  --set the Register Pointer to the Configuration Register
                           WHEN 1 =>                                    --1st busy high: command 1 latched, okay to issue command 2
                             i2c_data_wr <=  initGestureArray(i,1);                      --write the new configuration value to the Configuration Register
                           WHEN 2 =>                                    --2nd busy high: command 2 latched
                             i2c_ena <= '0';                              --deassert enable to stop transaction after command 2
                             IF(i2c_busy = '0') THEN                      --transaction complete
                               busy_cnt := 0;  
                           if(i<29) then                                                                                                                            
                             state <= gesture_init;                                                     --reset busy_cnt for next transaction                              
                                 i<=i+1;
                            else                   --advance to setting the Register Pointer for data reads
                             state <= gesture_reg;
                             i<=0;
                                          --advance to setting the Register Pointer for data reads
                              end if;                    
                               END IF;
                             WHEN OTHERS => NULL;
                           END CASE;
                           
       
                            --set the register pointer to the Ambient Temperature Register  
                            WHEN gesture_reg =>
                              busy_prev <= i2c_busy;                       --capture the value of the previous i2c busy signal
                              IF(busy_prev = '0' AND i2c_busy = '1') THEN  --i2c busy just went high
                                busy_cnt := busy_cnt + 1;                    --counts the times busy has gone from low to high during transaction
                              END IF;
                              CASE busy_cnt IS                             --busy_cnt keeps track of which command we are on
                                WHEN 0 =>                                    --no command latched in yet
                                  i2c_ena <= '1';                              --initiate the transaction
                                  i2c_addr <= sensor_addr;                --set the address of the temp sensor
                                  i2c_rw <= '0';                               --command 1 is a write
                                  i2c_data_wr <=X"43";                  --set the Register Pointer to the Ambient Temperature Register
                                WHEN 1 =>                                    --1st busy high: command 1 latched
                                  i2c_ena <= '0';                              --deassert enable to stop transaction after command 1
                                  IF(i2c_busy = '0') THEN                      --transaction complete
                                    busy_cnt := 0;                               --reset busy_cnt for next transaction
                                    state <= read_data1;                          --advance to reading the data
                                  END IF;
                                WHEN OTHERS => NULL;
                              END CASE;
                            
                            --read ambient temperature data
                            WHEN read_data1 =>
                              busy_prev <= i2c_busy;                       --capture the value of the previous i2c busy signal
                              IF(busy_prev = '0' AND i2c_busy = '1') THEN  --i2c busy just went high
                                busy_cnt := busy_cnt + 1;                    --counts the times busy has gone from low to high during transaction
                              END IF;
                              CASE busy_cnt IS                             --busy_cnt keeps track of which command we are on
                                WHEN 0 =>                                    --no command latched in yet
                                  i2c_ena <= '1';                              --initiate the transaction
                                  i2c_addr <= sensor_addr;                --set the address of the temp sensor
                                  i2c_rw <= '1';                               --command 1 is a read
                               
                                WHEN 1 =>                                    --2nd busy high: command 2 latched
                                  i2c_ena <= '0';                              --deassert enable to stop transaction after command 2
                                  IF(i2c_busy = '0') THEN                      --indicates data read in command 2 is ready
                                    temp_data2(7 DOWNTO 0) <= i2c_data_rd;        --retrieve LSB data from command 2
                                    busy_cnt := 0;                               --reset busy_cnt for next transaction
                                    state <= gesture_data;                      --advance to output the result
                                  END IF;
                               WHEN OTHERS => NULL;
                              END CASE;
                    
                            --output the temperature data
                            WHEN gesture_data =>
                                   if(temp_data2(7 DOWNTO 0)=X"01") then                          
                                             gesture <= "0001";                    -------up
                                     elsif(temp_data2(7 DOWNTO 0)=X"02") then
                                         gesture <= "0010";                         -------down
                                     elsif(temp_data2(7 DOWNTO 0)=X"04") then
                                          gesture <= "0011";                        -------left
                                     elsif(temp_data2(7 DOWNTO 0)=X"08") then
                                          gesture <= "0100";                         -------right
                                     elsif(temp_data2(7 DOWNTO 0)=X"10") then
                                           gesture <= "0101";                       -------Forward
                                     elsif(temp_data2(7 DOWNTO 0)=X"20") then
                                            gesture <= "0110";                     -------Backward
                                      elsif(temp_data2(7 DOWNTO 0)=X"40") then
                                             gesture <= "0111";                    -------clockwise
                                      elsif(temp_data2(7 DOWNTO 0)=X"80") then
                                             gesture <= "1000";                    -------Anticlockwise
                                      else
                                                  gesture <= "0000";          
                                          end if;  
                                    state <= gesture_delay;                      --advance to output the result
                                            
                            
                           WHEN gesture_delay =>
                                IF(counter < 5000000) THEN   --100ms not yet reached
                                  counter := counter + 1;              --increment counter
                                ELSE                                 --100ms reached
                                  counter := 0;                        --clear counter
                                  state <= gesture_reg;             --advance to setting the resolution
                                   
                                  temp_data2<=X"00";
                                END IF;
                                        
                         
                           --default to start state
                           WHEN OTHERS =>
                             state <= start;
                   
                         END CASE;
                       END IF;
                     END PROCESS;   
                                            
                   END behavior;
