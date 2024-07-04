library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;


package tm_data_formats is


constant baseShiftUphi: integer := -17;
constant baseShiftUr  : integer := -12;
constant baseShiftUz  : integer := -11;

constant rangeUphi: real := 2.0 * MATH_PI / real( numRegions ) + invPtToDphi / minPt * 2.0 * maxRphi;
constant rangeUr  : real := tbMaxDiskR;
constant rangeUz  : real := tbLengthZ;

constant baseUphi: real := rangeUphi * 2.0 ** baseShiftUphi;
constant baseUr  : real := rangeUr   * 2.0 ** baseShiftUr;
constant baseUz  : real := rangeUz   * 2.0 ** baseShiftUz;

constant baseShiftUinv2R: integer := baseShiftTBinv2R;
constant baseShiftUcot  : integer := baseShiftTBcot;
constant baseShiftUphiT : integer := baseShiftTBphi0;
constant baseShiftUzT   : integer := baseShiftTBz0;

constant baseUinv2R: real := baseUphi / baseUr * 2.0 ** baseShiftUinv2R;
constant baseUcot  : real := baseUz   / baseUr * 2.0 ** baseShiftUcot;
constant baseUphiT : real := baseUphi          * 2.0 ** baseShiftUphiT;
constant baseUzT   : real := baseUz            * 2.0 ** baseShiftUzT;

constant maxUphiT: real := MATH_PI / real( numRegions );
constant maxUzT  : real := sinh( maxEta ) * chosenRofZ;

constant widthUinv2R: natural := widthTBinv2R;
constant widthUcot  : natural := widthTBcot;
constant widthUphiT : natural := width( 2.0 * maxUphiT / baseUphiT );
constant widthUzT   : natural := width( 2.0 * maxUzT   / baseUzT   );

constant widthUstubId: natural := widthTBstubId;
constant widthUr  : natural := width( rangeDTCr / baseUr );
constant widthUphi: natural := max( sum( widthsTBphi, baseShiftsTBphi ) );
constant widthUz  : natural := max( sum( widthsTBz,   baseShiftsTBz   ) );

constant unusedMSBScot: natural := integer( floor( log2( baseUcot * 2.0 ** widthUcot / ( 2.0 * maxCot ) ) ) );
constant baseShiftScot: integer := widthUcot - unusedMSBScot - 1 - widthAddrBRAM18;
constant baseScot: real := baseUcot * 2.0 ** baseShiftScot;

constant baseShiftSinvCot: integer := integer( ceil( log2( radiusOuter / tbLengthZ ) ) ) - widthDSPbu;
constant baseSinvCot: real := 2.0 ** baseShiftSinvCot;

constant baseCot: real := baseZ / baseR;

constant baseShiftHinv2R: integer := ilog2( baseInv2R / baseUinv2R );
constant baseShiftHphiT : integer := ilog2( basePhiT  / baseUphiT  );
constant baseShiftHcot  : integer := ilog2( baseCot   / baseUcot   );
constant baseShiftHzT   : integer := ilog2( baseZT    / baseUzT    );

constant baseHinv2R: real := baseInv2R / 2.0 ** baseShiftHinv2R;
constant baseHphiT : real := basePhiT  / 2.0 ** baseShiftHphiT;
constant baseHcot  : real := baseCot   / 2.0 ** baseShiftHcot;
constant baseHzT   : real := baseZT    / 2.0 ** baseShiftHzT;

constant baseTransformHinv2R: real := baseUinv2R / baseHinv2R;
constant baseTransformHphiT : real := baseUphiT  / baseHphiT;
constant baseTransformHcot  : real := baseUcot   / baseHcot;
constant baseTransformHzT   : real := baseUzT    / baseHzT;

constant baseShiftTransformHinv2R: integer := widthDSPbu - width( baseTransformHinv2R );
constant baseShiftTransformHphiT : integer := widthDSPbu - width( baseTransformHphiT  );
constant baseShiftTransformHcot  : integer := widthDSPbu - width( baseTransformHcot   );
constant baseShiftTransformHzT   : integer := widthDSPbu - width( baseTransformHzT    );

constant baseShiftHr  : integer := ilog2( baseR   / baseUr   );
constant baseShiftHphi: integer := ilog2( basePhi / baseUphi );
constant baseShiftHz  : integer := ilog2( baseZ   / baseUz   );

constant baseHr  : real := baseR   / 2.0 ** baseShiftHr;
constant baseHphi: real := basePhi / 2.0 ** baseShiftHphi;
constant baseHz  : real := baseZ   / 2.0 ** baseShiftHz;

constant baseTransformHr  : real := baseUr   / baseHr;
constant baseTransformHphi: real := baseUphi / baseHphi;
constant baseTransformHz  : real := baseUz   / baseHz;

constant baseShiftTransformHr  : integer := widthDSPbu - width( baseTransformHr   );
constant baseShiftTransformHphi: integer := widthDSPbu - width( baseTransformHphi );
constant baseShiftTransformHz  : integer := widthDSPbu - width( baseTransformHz   );

constant widthHinv2R: natural := widthUinv2R + widthDSPbu - baseShiftTransformHinv2R;
constant widthHphiT : natural := widthUphiT  + widthDSPbu - baseShiftTransformHphiT;
constant widthHcot  : natural := widthUcot   + widthDSPbu - baseShiftTransformHcot;
constant widthHzT   : natural := widthUzT    + widthDSPbu - baseShiftTransformHzT;

constant widthHstubId: natural := widthTBstubId; 
constant widthHr  : natural := widthUr   + widthDSPbu - baseShiftTransformHr;
constant widthHphi: natural := widthUphi + widthDSPbu - baseShiftTransformHphi;
constant widthHz  : natural := widthUz   + widthDSPbu - baseShiftTransformHz;

constant widthLinv2R: natural := widthTMinv2R;
constant widthLphiT : natural := widthTMphiT;
constant widthLzT   : natural := widthTMzT;

constant widthLstubId: natural := widthTBstubId;
constant widthLr  : natural := widthTMr;
constant widthLphi: natural := widthTMphi;
constant widthLz  : natural := widthTMz;

constant baseLinv2R: real := baseInv2R;
constant baseLphiT : real := basePhiT;
constant baseLzT   : real := baseZT;
constant baseLr    : real := baseR;
constant baseLphi  : real := basePhi;
constant baseLz    : real := baseZ;

constant widthRinv2R : natural := widthLinv2R;
constant widthRphiT  : natural := widthLphiT;
constant widthRzT    : natural := widthLzT;
constant widthRstubId: natural := widthTBstubId;
constant widthRlayer: natural := widthLayer;
constant widthRr    : natural := widthLr;
constant widthRphi  : natural := widthLphi;
constant widthRz    : natural := widthLz;

constant widthStubId: natural := widthTBstubId;


end;