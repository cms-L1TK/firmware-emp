library ieee;
use ieee.std_logic_1164.ALL;

use work.emp_framework_decl.all;
use work.emp_device_types.all;
use work.emp_slink_types.all;



package emp_project_decl is


constant PAYLOAD_REV: std_logic_vector(31 downto 0) := X"12345678";

constant SLINK_CONF: slink_conf_array_t := ( others => kNoSlink );

constant LB_ADDR_WIDTH  : integer := 11;

constant CLOCK_AUX_DIV     : clock_divisor_array_t := (18, 9, 4);
constant CLOCK_COMMON_RATIO: integer               := 36;
constant CLOCK_RATIO       : integer               :=  6;

constant PAYLOAD_LATENCY: integer := 166 + 162;

-- mgt -> chk -> buf -> fmt -> (algo) -> (fmt) -> buf -> chk -> mgt -> clk -> altclk
constant REGION_CONF : region_conf_array_t := (
   0 => ( no_mgt, buf,    no_fmt, buf,    no_mgt ),
   1 => ( no_mgt, buf,    no_fmt, buf,    no_mgt ),
   2 => ( no_mgt, buf,    no_fmt, buf,    no_mgt ),
  others => kDummyRegion
);


end;
