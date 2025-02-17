library ieee;
use ieee.std_logic_1164.all;

use work.emp_project_decl.all;

package tb_decl is


constant SOURCE_FILE         : string := "/users/sb19423/integration_test/tf_integration_work/proj/emData/tm/in.txt";
constant SINK_FILE           : string := "out.txt"; 

constant PLAYBACK_LENGTH     : integer := 9 * 162; -- 360 Mhz
constant CAPTURE_LENGTH      : integer := 9 * 162; -- 360 Mhz
constant WAIT_CYCLES_AT_START: integer := 0;
constant PLAYBACK_OFFSET     : integer := 0;
constant CAPTURE_OFFSET      : integer := PLAYBACK_OFFSET + PAYLOAD_LATENCY + 3;

constant PLAYBACK_LOOP       : boolean := false;
constant STRIP_HEADER        : boolean := false;
constant INSERT_HEADER       : boolean := false;


end package;
