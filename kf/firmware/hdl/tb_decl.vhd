library ieee;
use ieee.std_logic_1164.all;

use work.emp_project_decl.all;

package tb_decl is


constant SOURCE_FILE         : string := "in.txt";
constant SINK_FILE           : string := "out.txt"; 

constant PLAYBACK_LENGTH     : integer := 9 * 162;
constant CAPTURE_LENGTH      : integer := 9 * 162;
constant WAIT_CYCLES_AT_START: integer := 0;
constant PLAYBACK_OFFSET     : integer := 0;
constant CAPTURE_OFFSET      : integer := PLAYBACK_OFFSET + PAYLOAD_LATENCY + 3;

constant PLAYBACK_LOOP       : boolean := true;
constant STRIP_HEADER        : boolean := false;
constant INSERT_HEADER       : boolean := false;


end package;
