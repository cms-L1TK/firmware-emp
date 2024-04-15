library ieee;
use ieee.std_logic_1164.all;

use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.hybrid_data_types.all;
use ieee.numeric_std.all;

package dr_data_types is

-- RAM things
type t_ramInv is array ( 0 to 2 ** widthDRdZ - 1 ) of std_logic_vector( widthDRinvdZ - 1 downto 0 ); -- use width of dZ as it is wider than dPhi
function init_ramInv return t_ramInv;

type t_track is
record
  reset     : std_logic;
  valid     : std_logic;
  cm        : std_logic;
  lastTrack : std_logic;
  inv2R     : std_logic_vector( widthDRinv2R  - 1 downto 0 );
  phiT      : std_logic_vector( widthDRphiT   - 1 downto 0 );
  zT        : std_logic_vector( widthDRzT     - 1 downto 0 );
  chi2      : std_logic_vector( widthDRchi2   - 1 downto 0 );
  nConsistentStubs: std_logic_vector( widthDRConsistentStubs - 1 downto 0);
  stubs : t_stubsDRin( numLayers - 1 downto 0 );
end record;
type t_tracks is array ( natural range <> ) of t_track;
function nulll return t_track;

type t_stub is
record
    valid : std_logic;
    stubId: std_logic_vector( widthDRstubId - 1 downto 0 );
end record;
type t_stubs is array ( natural range <> ) of t_stub;
function nulll return t_stub;

function conv( t: t_track ) return t_trackDR;

end;


package body dr_data_types is


function nulll return t_track is begin return ( '0', '0', '0', '0', ( others => '0' ), ( others => '0' ), ( others => '0' ), ( others => '0' ), ( others => '0' ), ( others => nulll ) ); end function;
function nulll return t_stub is begin return ( '0', ( others => '0' ) ); end function; -- is it used?

function conv( t: t_track ) return t_trackDR is
  variable res: t_trackDR := ( t.reset, t.valid, t.inv2R, t.phiT, t.zT, ( others => nulll ) );
  variable s: t_stubDRin;
begin
  for k in res.stubs'range loop
    s := t.stubs( k );
    res.stubs( k ) := ( s.valid, s.r, s.phi, s.z, s.dPhi, s.dZ ); -- output
  end loop;
  return res;
end function;

function init_ramInv return t_ramInv is
  variable ram: t_ramInv := ( others => ( others => '0' ) );
  variable inv: real;
begin
  for i in ram'range loop
      if i = 0 then
        ram( i ) := ( others => '1' ); -- Division by 0...
        next;
      end if;
      inv := 1.0 / real( i ) * real( 2 ** widthDRinvdZ - 1); -- left shift with the number of bits that is representing the inverse
      ram( i ) := std_logic_vector( to_unsigned( integer( inv ), widthDRinvdZ) );
  end loop;
  return ram;
end function;

end;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.hybrid_data_types.all;
use work.dr_data_types.all;
use work.hybrid_tools.all;

-- DRin Track Conversion
entity track_conversion is
  port (
    clk: in std_logic;
    t_in: in t_trackDRin;
    t_out: out t_track
  );
  end;
  
  architecture rtl of track_conversion is

  -- Latency of this track conversion thingy
  constant latency: natural := 5;

  -- Initialise RAM for division
  signal ramInv: t_ramInv := init_ramInv;
  attribute ram_style: string;
  attribute ram_style of ramInv: signal is "block";
  
  -- Tracks storage
  signal t      : t_track := nulll;
  signal t_array: t_tracks( 0 to latency - 1 ) := ( others => nulll ); -- latency of this 
  
  -- Signals for chi2
  type chi2_tmps is array ( 0 to numLayers - 1 ) of unsigned( widthDRchi2 - 1 downto 0 );
  signal chi2_tmp : chi2_tmps := ( others => ( others => '0' ) );
  
  -- Signals for number of consistent stubs
  type nStubsArray is array ( 0 to 1 ) of std_logic_vector( widthDRConsistentStubs - 1 downto 0 );
  signal consistentStubs: std_logic_vector( 0 to numLayers - 1 ) := ( others => '0'); -- Each bit represent a consistent stub
  signal nConsistentStubs: nStubsArray := ( others => ( others => '0' ) ); -- The number of consistent stubs, i.e. the number of 1s in the above vector
  
  begin
  
  -- Store and shift tracks
  t_array( 0 ) <= ( t_in.reset, t_in.valid, '0', t_in.lastTrack, t_in.inv2R, t_in.phiT, t_in.zT, ( others => '0' ), ( others => '0' ), t_in.stubs );
  t_out <= t;

  g_shift : for i in 0 to latency - 2 generate
  begin
    process ( clk ) is
    begin
    if rising_edge( clk ) then

      t_array( i + 1 ) <= t_array( i );

      -- Reset
      -- if t_in.reset = '1' then
      --   t_array( i + 1 ) <= nulll;
      -- end if;

    end if;
  end process;
  end generate;

-- Loop over all stubs in track
  g_stub: for k in t_array( 0 ).stubs'range generate

    -- clk 1
    signal phi    : unsigned( widthDRphi  - 2 downto 0) := ( others => '0' ); -- Only need absolute value
    signal z      : unsigned( widthDRz    - 2 downto 0) := ( others => '0' ); -- Only need absolute value
    signal dPhi   : unsigned( widthDRdPhi - 1 downto 0) := ( others => '0' );
    signal dZ     : unsigned( widthDRdZ   - 1 downto 0) := ( others => '0' );
    signal invdPhi: unsigned(widthDRinvdZ - 1 downto 0) := ( others => '0' ); -- Use dZ width due to ramInv
    signal invdZ  : unsigned(widthDRinvdZ - 1 downto 0) := ( others => '0' );
  
    -- clk 2
    constant widthPhiDiv: integer := widthDRphi + widthDRinvdZ - 1;
    constant widthZDiv  : integer := widthDRz   + widthDRinvdZ - 1;
    signal phi_div_tmp: unsigned(widthPhiDiv - 1 downto 0) := ( others => '0' ); -- choose bit widths
    signal z_div_tmp  : unsigned(widthZDiv   - 1 downto 0) := ( others => '0' );

    -- clk 3
    constant widthChi2Phi: integer := widthPhiDiv * 2;
    constant widthChi2Z  : integer := widthZDiv * 2;
    signal chi2_phi_tmp: unsigned(widthChi2Phi - 1 downto 0) := ( others => '0' );
    signal chi2_z_tmp  : unsigned(widthChi2Z   - 1 downto 0) := ( others => '0' );
  
  begin
    process ( clk ) is

    variable s : t_stubDRin := nulll;
 
    begin
    if rising_edge( clk ) then

      s := t_in.stubs( k );
      consistentStubs( k ) <= '0';

      -- clk 1: Read values from stub and RAM
      phi     <= unsigned( abs( s.phi ) ); -- The "sign bit" is needed for padding when we left shift later
      z       <= unsigned( abs( s.z ) );
      dPhi    <= unsigned( s.dPhi );
      dZ      <= unsigned( s.dZ );
      invdPhi <= unsigned( ramInv( uint( s.dPhi ) ) );
      invdZ   <= unsigned( ramInv( uint( s.dZ ) ) );
  
      -- clk 2: Check if consistent stub
      if phi & '0' < dPhi and z & '0' < dZ then -- Check that the residuals are smaller than half the resolution
        consistentStubs( k ) <= '1';
      end if;
  
      -- clk 2: Calculate phi/dPhi
      phi_div_tmp <= phi * invdPhi;
      z_div_tmp   <=   z * invdZ;

      -- clk 3: Calculate the chi2
      chi2_phi_tmp <= phi_div_tmp * phi_div_tmp;
      chi2_z_tmp   <= z_div_tmp   * z_div_tmp;
      -- Technically should be divided by 2 because of the number of degrees of freedom but doesn't matter atm

      -- clk 4: Add phi and z chi2
      chi2_tmp( k ) <= resize( chi2_phi_tmp + chi2_z_tmp, widthDRchi2 );

      -- Reset
      if t_in.reset = '1' then
        phi_div_tmp          <= ( others => '0' );
        z_div_tmp            <= ( others => '0' );
        chi2_phi_tmp         <= ( others => '0' );
        chi2_z_tmp           <= ( others => '0' );
        chi2_tmp( k )        <= ( others => '0' );
        consistentStubs( k ) <= '0';
      end if;

    end if; -- clk
    end process;
  end generate;
  

  -- Save values to output track
  process ( clk ) is

  -- clk 4
  variable chi2_sum_tmp: unsigned( widthDRchi2 - 1 downto 0 ) := ( others => '0' );

  begin
    if rising_edge( clk ) then

      -- clk 3: Sum the number of consistent stubs
      nConsistentStubs( 0 ) <= stdu( count( consistentStubs, '1' ), widthDRConsistentStubs );

      -- clk 4: Shift the nConsistentStubs
      nConsistentStubs( 1 ) <= nConsistentStubs( 0 );

      -- clk 5: Sum the temporary chi2 values
      chi2_sum_tmp := ( others => '0' );
      for k in 0 to numLayers - 1 loop
        chi2_sum_tmp := chi2_sum_tmp + chi2_tmp( k );
      end loop;
      
      -- clk 5: Set values to track
      t <= ( t_array( latency - 1 ).reset, t_array( latency - 1 ).valid, '0', t_array( latency - 1 ).lastTrack, t_array( latency - 1 ).inv2R, t_array( latency - 1 ).phiT, t_array( latency - 1 ).zT, std_logic_vector( chi2_sum_tmp ), nConsistentStubs( 1 ), t_array( latency - 1 ).stubs );

      -- Reset
      if t_in.reset = '1' then
        t <= nulll;
        nConsistentStubs <= ( others => (others => '0' ) );
        chi2_sum_tmp := ( others => '0' );
      end if;

    end if;
  end process;

end;

