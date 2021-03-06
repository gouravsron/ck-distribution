      SUBROUTINE  QOFT(IMOL,Ii,T,QT)

*-------------------------------------------------------------------
* In this subroutine the total internal partition sum Q(T) is
* calculated. 
*-------------------------------------------------------------------
      IMPLICIT REAL*8 (a-h,o-z)

      INTEGER IMOL,Ii,NMOL,NSPECI,IRANGE
      PARAMETER (NMOL=32,NSPECI=75)

      REAL*8 T,TEMP0,QT,eps
      PARAMETER (TEMP0=296.,eps=1.E-5)

      COMMON / ISVEC / NISO(NMOL), MISO(NSPECI), ISONM(NMOL)
      COMMON / QTOT / Q296(NSPECI), QCOEF(NSPECI,2,4), AQ(NSPECI),
     .                BQ(NSPECI)

Cf2py intent(in) IMOL,Ii,T
Cf2py intent(out) QT
      
********************************************************************
*  1. Determine the position in the NSPECI-arrays using the number
*     of the molecule IMOL and the number of the isotope Ii:
********************************************************************
      Ip= ISONM(IMOL) + Ii

********************************************************************
*  2. In case T is equal to the reference temperature TEMP0 the
*     total internal partition sum QT of specie Ip is found from the
*     array Q296(NSPECI):
********************************************************************
      IF (DABS(T-TEMP0).LT.eps) THEN
         QT= Q296(Ip)
         GOTO 999
      ENDIF

********************************************************************
* 3.a In case T is NOT equal to TEMP0, the calculation of QT
*     depends on the temperature range in which T belongs:
*     [70,400]  = 1   
*     <400,2005]= 2 
*     2005 < T  = 3 
********************************************************************
      IF (T.GE.7.0E1 .AND. T.LE.4.0E2)    IRANGE=1
      IF (T.GT.4.0E2 .AND. T.LE.2.005E3)  IRANGE=2
      IF (T.GT.2.005E3)                   IRANGE=3
********************************************************************
* 3.b In case IRANGE=1 or IRANGE=2 a 3rd order polynomial is used
*     to calculate QT:
********************************************************************
      IF (IRANGE.EQ.1 .OR. IRANGE.EQ.2) THEN
         QT= QCOEF(Ip,IRANGE,1) +
     +       QCOEF(Ip,IRANGE,2) * T +
     +       QCOEF(Ip,IRANGE,3) * T * T +
     +       QCOEF(Ip,IRANGE,4) * T * T * T
********************************************************************
* 3.c In case RANGE=3 extrapolation is used to calculate QT:
********************************************************************
      ELSEIF (RANGE.EQ.3) THEN
         IF (AQ(Ip).LT.0.0) THEN
            QT= -1.0
         ELSE
            QT= DEXP( AQ(Ip)*DLOG(T) + BQ(Ip) )
         ENDIF
      ENDIF
********************************************************************
999   RETURN
      END

********************************************************************
      BLOCK DATA QTDATA

*-------------------------------------------------------------------
* This data block contains the common block QTOT, concerning the
* total internal partition sum
* QTOT contains:
*     Q296(NSPECI) : the total internal partition sum at the
*                    reference temperature T=296 K, for each 
*                    molecule and its isotopes
*     QCOEF(NSPECI,2,4) : 4 coefficients per molecule and its 
*                         isotope, for 2 temperature ranges, to
*                         be used to calculate the total internal
*                         partition sum with a 3rd order polynomial
* In case T>2005 K, Q(T) is found by extrapolation:
*     LN(Q(T))=  A*LN(T) + B
*     AQ(NSPECI) : A coefficients for high temperature extrapolation
*     BQ(NSPECI) : B coefficients for high temperature extrapolation
*-------------------------------------------------------------------
      IMPLICIT REAL*8  (a-h,o-z)
      
      INTEGER NSPECI
      PARAMETER (NSPECI=75)

      COMMON / QTOT / Q296(NSPECI), QCOEF(NSPECI,2,4), AQ(NSPECI),
     .                BQ(NSPECI)

********************************************************************
      DATA (Q296(i), i=1,NSPECI) /
*       H2O                                                 CO2
     +	.174824E+03, .176311E+03, .105791E+04, .866085E+03, .286084E+03,
*
     +  .576543E+03, .607783E+03, .354336E+04, .123504E+04, .714234E+04,
*                                 O3
     +  .323520E+03, .376742E+04, .348838E+04, .372378E+04, .364022E+04,
*       N2O
     +  .498127E+04, .334085E+04, .344098E+04, .525202E+04, .306164E+05,
*       CO
     +  .107440E+03, .224743E+03, .112800E+03, .661315E+03, .236493E+03,
*       CH4                                    O2
     +  .591953E+03, .117578E+04, .269868E+05,-.100000E+01,-.100000E+01,
*                    NO                                     SO2
     + -.100000E+01, .136286E+05, .629983E+04, .143719E+05, .630040E+04,
*                    NO2          NH3                       HNO3
     +  .632754E+04, .273021E+05, .173254E+04, .115578E+04, .206001E+06,
*       OH                                     HF           HCL
     +  .644694E+03, .648860E+03, .249241E+04, .414766E+02, .160686E+03,
*                    HBR                       HI           CLO
     +  .160924E+03, .200212E+03, .200274E+03, .389072E+03, .526040E+05,
*                    OCS
     +  .535212E+05, .118980E+04, .121962E+04, .241146E+04, .127710E+04,
*       H2CO                                   HOCL                             
     +  .142625E+04, .292479E+04, .142625E+04, .193070E+05, .196566E+05,
*       N2           HCN                                    CH3CL
     +  .233594E+03, .890125E+03, .182974E+04, .612714E+03, .217165E+05,
*                    H2O2         C2H2                      C2H6
     +  .220607E+05, .313916E+05, .405852E+03, .324689E+04,-.100000E+01,
*       PH3          COF2         SF6          H2S          HCOOH
     +  .363932E+04,-.100000E+01,-.100000E+01,-.100000E+01,-.100000E+01/


* Total internal partition sums for temperature range [70 K,400 K]  
*     H2O (161)                                                       
      DATA (QCOEF( 1,1,J), J=1,4)/
     + -.37688E+01, .26168E+00, .13497E-02,-.66013E-06/          
*     H2O (181)
      DATA (QCOEF( 2,1,J), J=1,4)/
     + -.38381E+01, .26466E+00, .13555E-02,-.65372E-06/     
*     H2O (171)
      DATA (QCOEF( 3,1,J), J=1,4)/
     + -.22842E+02, .15840E+01, .81575E-02,-.39650E-05/
*     H2O (162)                          
      DATA (QCOEF( 4,1,J), J=1,4)/
     + -.20481E+02, .13017E+01, .66225E-02,-.30447E-05/ 
*     CO2 (626)       
      DATA (QCOEF( 5,1,J), J=1,4)/
     + -.21995E+01, .96751E+00,-.80827E-03, .28040E-05/
*     CO2 (636)         
      DATA (QCOEF( 6,1,J), J=1,4)/
     + -.38840E+01, .19263E+01,-.16058E-02, .58202E-05/ 
*     CO2 (628)         
      DATA (QCOEF( 7,1,J), J=1,4)/
     + -.47289E+01, .20527E+01,-.17421E-02, .60748E-05/  
*     CO2 (627)         
      DATA (QCOEF( 8,1,J), J=1,4)/
     + -.27475E+02, .11973E+02,-.10110E-01, .35187E-04/ 
*     CO2 (638)        
      DATA (QCOEF( 9,1,J), J=1,4)/
     + -.84191E+01, .41186E+01,-.34961E-02, .12750E-04/  
*     CO2 (637)         
      DATA (QCOEF(10,1,J), J=1,4)/
     + -.48468E+02, .23838E+02,-.20089E-01, .73067E-04/ 
*     CO2 (828)              
      DATA (QCOEF(11,1,J), J=1,4)/
     + -.22278E+01, .10840E+01,-.89718E-03, .32143E-05/   
*     CO2 (728)                              
      DATA (QCOEF(12,1,J), J=1,4)/
     + -.29547E+02, .12714E+02,-.10913E-01, .38169E-04/ 
*     O3 (666)                     
      DATA (QCOEF(13,1,J), J=1,4)/
     + -.13459E+03, .62255E+01, .14811E-01, .18608E-04/
*     O3 (668)              
      DATA (QCOEF(14,1,J), J=1,4)/
     + -.12361E+03, .61656E+01, .19168E-01, .13223E-04/
*     O3 (686)            
      DATA (QCOEF(15,1,J), J=1,4)/
     + -.12359E+03, .60957E+01, .18239E-01, .13939E-04/ 
*     N2O (446)                       
      DATA (QCOEF(16,1,J), J=1,4)/
     + -.95291E+01, .15719E+02,-.12063E-01, .53781E-04/ 
*     N2O (456)                   
      DATA (QCOEF(17,1,J), J=1,4)/ 
     +  .48994E+01, .10211E+02,-.62964E-02, .33355E-04/
*     N2O (546)                        
      DATA (QCOEF(18,1,J), J=1,4)/
     + -.28797E+01, .10763E+02,-.78058E-02, .36321E-04/ 
*     N2O (448)
      DATA (QCOEF(19,1,J), J=1,4)/ 
     +  .25668E+02, .15803E+02,-.67882E-02, .44093E-04/ 
*     N2O (477)                 
      DATA (QCOEF(20,1,J), J=1,4)/ 
     +  .18836E+03, .91152E+02,-.31071E-01, .23789E-03/ 
*     CO (26)               
      DATA (QCOEF(21,1,J), J=1,4)/ 
     +  .31591E+00, .36205E+00,-.22603E-05, .61215E-08/ 
*     CO (36) 
      DATA (QCOEF(22,1,J), J=1,4)/ 
     +  .62120E+00, .75758E+00,-.59190E-05, .15232E-07/ 
*     CO (28) 
      DATA (QCOEF(23,1,J), J=1,4)/ 
     +  .30985E+00, .38025E+00,-.29998E-05, .76646E-08/  
*     CO (27)
      DATA (QCOEF(24,1,J), J=1,4)/ 
     +  .18757E+01, .22289E+01,-.15793E-04, .41607E-07/ 
*     CO (38)
      DATA (QCOEF(25,1,J), J=1,4)/ 
     +  .60693E+00, .79754E+00,-.78021E-05, .19200E-07/ 
*     CH4 (211) 
      DATA (QCOEF(26,1,J), J=1,4)/
     + -.17475E+02, .95375E+00, .39758E-02,-.81837E-06/ 
*     CH4 (311)
      DATA (QCOEF(27,1,J), J=1,4)/
     + -.27757E+02, .17264E+01, .93304E-02,-.48181E-05/ 
*     CH4 (212) 
      DATA (QCOEF(28,1,J), J=1,4)/
     + -.89810E+03, .44451E+02, .17474E+00,-.22469E-04/ 
*     O2 (66) 
      DATA (QCOEF(29,1,J), J=1,4)/
     + -.10000E+01, .00000E+00, .00000E+00, .00000E+00/
*     O2 (68) 
      DATA (QCOEF(30,1,J), J=1,4)/
     + -.10000E+01, .00000E+00, .00000E+00, .00000E+00/ 
*     O2 (67)  
      DATA (QCOEF(31,1,J), J=1,4)/
     + -.10000E+01, .00000E+00, .00000E+00, .00000E+00/ 
*     NO (46)  
      DATA (QCOEF(32,1,J), J=1,4)/
     + -.17685E+03, .28839E+02, .87413E-01,-.92142E-04/
*     NO (56)   
      DATA (QCOEF(33,1,J), J=1,4)/
     + -.61157E+02, .13304E+02, .40161E-01,-.42247E-04/
*     NO (48) 
      DATA (QCOEF(34,1,J), J=1,4)/
     + -.18775E+03, .30428E+02, .92040E-01,-.96827E-04/
*     SO2 (626) 
      DATA (QCOEF(35,1,J), J=1,4)/
     + -.17187E+03, .94104E+01, .34620E-01, .25199E-04/
*     SO2 (646)   
      DATA (QCOEF(36,1,J), J=1,4)/
     + -.17263E+03, .94528E+01, .34777E-01, .25262E-04/
*     NO2 (646)   
      DATA (QCOEF(37,1,J), J=1,4)/
     + -.89749E+03, .44718E+02, .15781E+00, .43820E-04/ 
*     NH3 (4111) 
      DATA (QCOEF(38,1,J), J=1,4)/
     + -.48197E+02, .27739E+01, .11492E-01,-.18209E-05/
*     NH3 (5111)  
      DATA (QCOEF(39,1,J), J=1,4)/
     + -.32700E+02, .18444E+01, .77001E-02,-.12388E-05/
*     HNO3 (146) 
      DATA (QCOEF(40,1,J), J=1,4)/
     + -.74208E+04, .34984E+03, .89051E-01, .39356E-02/
*     OH (61)              
      DATA (QCOEF(41,1,J), J=1,4)/ 
     +  .76510E+02, .11377E+01, .39068E-02,-.42750E-05/ 
*     OH (81)              
      DATA (QCOEF(42,1,J), J=1,4)/ 
     +  .76140E+02, .11508E+01, .39178E-02,-.42870E-05/
*     OH (62)             
      DATA (QCOEF(43,1,J), J=1,4)/ 
     +  .14493E+03, .47809E+01, .15441E-01,-.16217E-04/
*     HF (19)              
      DATA (QCOEF(44,1,J), J=1,4)/ 
     +  .15649E+01, .13318E+00, .80622E-05,-.83354E-08/ 
*     HCL (15)             
      DATA (QCOEF(45,1,J), J=1,4)/ 
     +  .28877E+01, .53077E+00, .99904E-05,-.70856E-08/ 
*     HCL (17)             
      DATA (QCOEF(46,1,J), J=1,4)/ 
     +  .28873E+01, .53157E+00, .99796E-05,-.70647E-08/ 
*     HBR (19)             
      DATA (QCOEF(47,1,J), J=1,4)/ 
     +  .28329E+01, .66462E+00, .83420E-05,-.30996E-08/ 
*     HBR (11)            
      DATA (QCOEF(48,1,J), J=1,4)/ 
     +  .28329E+01, .66483E+00, .83457E-05,-.31074E-08/ 
*     HI (17)    
      DATA (QCOEF(49,1,J), J=1,4)/ 
     + .41379E+01, .12977E+01, .61598E-05, .10382E-07/
*     CLO (56)        
      DATA (QCOEF(50,1,J), J=1,4)/ 
     +  .15496E+04, .11200E+03, .19225E+00, .40831E-04/ 
*     CLO (76) 
      DATA (QCOEF(51,1,J), J=1,4)/ 
     +  .15728E+04, .11393E+03, .19518E+00, .43308E-04/
*     OCS (622)   
      DATA (QCOEF(52,1,J), J=1,4)/ 
     +  .18600E+02, .31185E+01, .30405E-03, .85400E-05/
*     OCS (624)            
      DATA (QCOEF(53,1,J), J=1,4)/ 
     +  .19065E+02, .31965E+01, .31228E-03, .87535E-05/ 
*     OCS (632)         
      DATA (QCOEF(54,1,J), J=1,4)/ 
     +  .42369E+02, .61394E+01, .13090E-02, .16856E-04/ 
*     OCS (822)           
      DATA (QCOEF(55,1,J), J=1,4)/ 
     +  .21643E+02, .32816E+01, .57748E-03, .90034E-05/
*     H2CO (126)           
      DATA (QCOEF(56,1,J), J=1,4)/
     + -.44663E+02, .23031E+01, .95095E-02,-.16965E-05/ 
*     H2CO (136)           
      DATA (QCOEF(57,1,J), J=1,4)/
     + -.91605E+02, .47223E+01, .19505E-01,-.34832E-05/
*     H2CO (128)           
      DATA (QCOEF(58,1,J), J=1,4)/
     + -.44663E+02, .23031E+01, .95095E-02,-.16965E-05/
*     HOCL (165)           
      DATA (QCOEF(59,1,J), J=1,4)/
     + -.62547E+03, .31546E+02, .11132E+00, .32438E-04/
*     HOCL (167)           
      DATA (QCOEF(60,1,J), J=1,4)/
     + -.60170E+03, .31312E+02, .11841E+00, .23717E-04/ 
*     N2 (44)             
      DATA (QCOEF(61,1,J), J=1,4)/ 
     +  .73548E+00, .78662E+00,-.18282E-05, .68772E-08/ 
*     HCN (124)     
      DATA (QCOEF(62,1,J), J=1,4)/
     + -.97107E+00, .29506E+01,-.16077E-02, .61148E-05/ 
*     HCN (134)  
      DATA (QCOEF(63,1,J), J=1,4)/
     + -.16460E+01, .60490E+01,-.32724E-02, .12632E-04/ 
*     HCN (125) 
      DATA (QCOEF(64,1,J), J=1,4)/
     + -.40184E+00, .20202E+01,-.10855E-02, .42504E-05/
*     CH3CL (215)
      DATA (QCOEF(65,1,J), J=1,4)/
     + -.89695E+03, .40155E+02, .82775E-01, .13400E-03/ 
*     CH3CL (217)
      DATA (QCOEF(66,1,J),J=1,4)/
     + -.91113E+03, .40791E+02, .84091E-01, .13611E-03/
*     H2O2 (1661)  
      DATA (QCOEF(67,1,J), J=1,4)/
     + -.95255E+03, .49483E+02, .21249E+00,-.35489E-04/
*     C2H2 (1221)
      DATA (QCOEF(68,1,J), J=1,4)/ 
     +  .25863E+01, .11921E+01,-.79281E-03, .46225E-05/ 
*     C2H2 (1231)
      DATA (QCOEF(69,1,J),J=1,4)/ 
     +  .20722E+02, .95361E+01,-.63398E-02, .36976E-04/ 
*     C2H6 (1221)           
      DATA (QCOEF(70,1,J), J=1,4)/
     + -.10000E+01, .00000E+00, .00000E+00, .00000E+00/
*     PH3 (1111) 
      DATA (QCOEF(71,1,J), J=1,4)/
     + -.11388E+03, .69602E+01, .17396E-01, .65088E-05/
*     COF2 (269)            
      DATA (QCOEF(72,1,J), J=1,4)/
     + -.10000E+01, .00000E+00, .00000E+00, .00000E+00/
*     SF6 (29)           
      DATA (QCOEF(73,1,J), J=1,4)/
     + -.10000E+01, .00000E+00, .00000E+00, .00000E+00/ 
*     H2S (121)    
      DATA (QCOEF(74,1,J), J=1,4)/
     + -.10000E+01, .00000E+00, .00000E+00, .00000E+00/ 
*     HCOOH (126)
      DATA (QCOEF(75,1,J), J=1,4)/
     + -.10000E+01, .00000E+00, .00000E+00, .00000E+00/

* Total internal partition sums for temperature range [400 K,2005 K]
*     H2O (161)
      DATA (QCOEF( 1,2,J),J=1,4)/-.51182E+02, .63598E+00,   
     +                .31873E-03, .32149E-06/  
*     H20 (181)
      DATA (QCOEF( 2,2,J),J=1,4)/-.45948E+02, .61364E+00, 
     +                .35470E-03, .32872E-06/  
*     H2O (171)
      DATA (QCOEF( 3,2,J),J=1,4)/-.27577E+03, .36821E+01,  
     +                .21279E-02, .19724E-05/    
*     H2O (162)
      DATA (QCOEF( 4,2,J),J=1,4)/-.10499E+03, .24288E+01,  
     +                .25247E-02, .15024E-05/          
*     CO2 (626)
      DATA (QCOEF( 5,2,J),J=1,4)/-.35179E+03, .27793E+01,   
     +               -.36737E-02, .40901E-05/            
*     CO2 (636)
      DATA (QCOEF( 6,2,J),J=1,4)/ .31424E+03, .14819E+00,   
     +                .18144E-02, .34270E-05/      
*     CO2 (628)
      DATA (QCOEF( 7,2,J),J=1,4)/ .41427E+03,-.28104E+00,  
     +                .26658E-02, .31136E-05/   
*     CO2 (627)
      DATA (QCOEF( 8,2,J),J=1,4)/-.12204E+04, .18403E+02, 
     +               -.19962E-01, .38328E-04/          
*     CO2 (638)
      DATA (QCOEF( 9,2,J),J=1,4)/-.17721E+03, .51237E+01,  
     +               -.49831E-02, .12861E-04/           
*     CO2 (637)
      DATA (QCOEF(10,2,J),J=1,4)/-.22254E+04, .36099E+02,   
     +               -.39733E-01, .79776E-04/         
*     CO2 (838)
      DATA (QCOEF(11,2,J),J=1,4)/-.21531E+03, .21676E+01,  
     +               -.24526E-02, .36542E-05/          
*     CO2 (728)
      DATA (QCOEF(12,2,J),J=1,4)/ .40887E+04,-.98940E+01,  
     +                .30287E-01, .12296E-04/         
*     O3 (666)
      DATA (QCOEF(13,2,J),J=1,4)/ .70208E+04,-.32154E+02,  
     +                .76432E-01,-.70688E-05/           
*     O3 (688)
      DATA (QCOEF(14,2,J),J=1,4)/ .16322E+04,-.77895E+01,  
     +                .53646E-01,-.13162E-04/
*     O3 (686)
      DATA (QCOEF(15,2,J),J=1,4)/ .18667E+04,-.91145E+01,   
     +                .54732E-01,-.13296E-04/      
*     N2O (466)
      DATA (QCOEF(16,2,J),J=1,4)/ .59819E+04,-.22671E+02,   
     +                .72560E-01,-.11473E-04/        
*     N2O (456)
      DATA (QCOEF(17,2,J),J=1,4)/ .25987E+04,-.85322E+01,   
     +                .40843E-01,-.79294E-05/   
*     N2O (546)
      DATA (QCOEF(18,2,J),J=1,4)/ .35285E+04,-.12908E+02,  
     +                .47147E-01,-.83427E-05/   
*     N2O (448)
      DATA (QCOEF(19,2,J),J=1,4)/ .36585E+04,-.92760E+01, 
     +                .54617E-01,-.95417E-05/          
*     N2O (477)
      DATA (QCOEF(20,2,J),J=1,4)/ .98093E+04, .19355E+01,  
     +                .24605E+00,-.48629E-04/        
*     CO (26)
      DATA (QCOEF(21,2,J),J=1,4)/ .65928E+01, .33911E+00,   
     +                .79512E-05, .27069E-07/  
*     CO (36)
      DATA (QCOEF(22,2,J),J=1,4)/ .15017E+02, .70324E+00,       
     +                .24475E-04, .56426E-07/             
*     CO (28)                        
      DATA (QCOEF(23,2,J),J=1,4)/ .75898E+01, .35270E+00,   
     +                .12628E-04, .28309E-07/          
*     CO (27)                              
      DATA (QCOEF(24,2,J),J=1,4)/ .42623E+02, .20771E+01,    
     +                .61914E-04, .16632E-06/             
*     CO (38)                                    
      DATA (QCOEF(25,2,J),J=1,4)/ .17317E+02, .73239E+00,   
     +                .35779E-04, .58967E-07/    
*     CH4 (211)  
      DATA (QCOEF(26,2,J),J=1,4)/ .35513E+03,-.11165E+01, 
     +                .71453E-02,-.16135E-05/ 
*     CH4 (311)          
      DATA (QCOEF(27,2,J),J=1,4)/-.17262E+03, .29240E+01,         
     +                .57503E-02,-.10899E-05/                
*     CH4 (212)                            
      DATA (QCOEF(28,2,J),J=1,4)/ .21422E+05,-.42118E+02,   
     +                .20083E+00, .10661E-03/         
*     O2 (66)                     
      DATA (QCOEF(29,2,J),J=1,4)/-.10000E+01, .00000E+00,     
     +                .00000E+00, .00000E+00/         
*     O2 (68)                         
      DATA (QCOEF(30,2,J),J=1,4)/-.10000E+01, .00000E+00,        
     +                .00000E+00, .00000E+00/                 
*     O2 (67)                                
      DATA (QCOEF(31,2,J),J=1,4)/-.10000E+01, .00000E+00,           
     +                .00000E+00, .00000E+00/                     
*     NO (46)                                
      DATA (QCOEF(32,2,J),J=1,4)/-.13687E+04, .48097E+02,   
     +                .90728E-02, .26135E-05/            
*     NO (56)                 
      DATA (QCOEF(33,2,J),J=1,4)/-.54765E+03, .21844E+02,      
     +                .46287E-02, .11057E-05/             
*     NO (48)                                 
      DATA (QCOEF(34,2,J),J=1,4)/-.12532E+04, .49741E+02,      
     +                .10974E-01, .24674E-05/               
*     SO2 (626)                                     
      DATA (QCOEF(35,2,J),J=1,4)/ .51726E+04,-.20352E+02,           
     +                .87930E-01,-.52092E-05/              
*     SO2 (636)                            
      DATA (QCOEF(36,2,J),J=1,4)/ .52103E+04,-.20559E+02,        
     +                .88623E-01,-.55322E-05/                 
*     NO2 (646)                                                
      DATA (QCOEF(37,2,J),J=1,4)/ .29305E+05,-.10243E+03,   
     +                .34919E+00, .15348E-04/            
*     NH3 (4111)                                      
      DATA (QCOEF(38,2,J),J=1,4)/ .53877E+03, .70380E+00,      
     +                .10900E-01, .35142E-05/             
*     NH3 (5111)                                       
      DATA (QCOEF(39,2,J),J=1,4)/ .36092E+03, .45860E+00,       
     +                .72936E-02, .23486E-05/                 
*     HNO3 (146)                                            
      DATA (QCOEF(40,2,J),J=1,4)/ .40718E+06,-.24214E+04,    
     +                .64287E+01,-.10773E-02/              
*     OH (61)                                          
      DATA (QCOEF(41,2,J),J=1,4)/-.61974E+02, .23874E+01,        
     +               -.97362E-04, .10729E-06/                  
*     OH (81)                                                
      DATA (QCOEF(42,2,J),J=1,4)/-.63101E+02, .24036E+01,  
     +               -.93312E-04, .10475E-06/           
*     OH (62)                                         
      DATA (QCOEF(43,2,J),J=1,4)/-.31590E+03, .93816E+01,      
     +                .15600E-03, .54606E-06/      
*     HF (19)                                      
      DATA (QCOEF(44,2,J),J=1,4)/ .32470E+00, .14095E+00,   
     +               -.93764E-05, .60911E-08/                 
*     HCL (15)                                                    
      DATA (QCOEF(45,2,J),J=1,4)/ .25734E+01, .54202E+00,          
     +               -.33353E-04, .37021E-07/                
*     HCL (17)                      
      DATA (QCOEF(46,2,J),J=1,4)/ .25937E+01, .54276E+00,           
     +               -.33345E-04, .37100E-07/                   
*     HBR (19)                                   
      DATA (QCOEF(47,2,J),J=1,4)/ .62524E+01, .66207E+00,      
     +               -.27599E-04, .51074E-07/              
*     HBR (11)                      
      DATA (QCOEF(48,2,J),J=1,4)/ .62563E+01, .66225E+00,     
     +               -.27588E-04, .51093E-07/               
*     HI (17)                  
      DATA (QCOEF(49,2,J),J=1,4)/ .21682E+02, .12417E+01,     
     +               -.31297E-06, .10661E-06/              
*     CLO (56)                 
      DATA (QCOEF(50,2,J),J=1,4)/-.32321E+04, .12011E+03,          
     +                .23683E+00,-.48509E-04/                  
*     CLO (76)                   
      DATA (QCOEF(51,2,J),J=1,4)/-.33857E+04, .12234E+03,           
     +                .24153E+00,-.49591E-04/           
*     OCS (622)                                     
      DATA (QCOEF(52,2,J),J=1,4)/-.11191E+03, .23157E+01,           
     +                .70961E-02,-.14510E-05/               
*     OCS (624)
      DATA (QCOEF(53,2,J),J=1,4)/-.11333E+03, .23669E+01,  
     +                .72844E-02,-.14918E-05/          
*     OCS (632)     
      DATA (QCOEF(54,2,J),J=1,4)/-.28497E+03, .49188E+01,   
     +                .14264E-01,-.29340E-05/            
*     OCS (822)             
      DATA (QCOEF(55,2,J),J=1,4)/-.13795E+03, .25510E+01,   
     +                .75996E-02,-.15672E-05/          
*     H2CO (126)         
      DATA (QCOEF(56,2,J),J=1,4)/ .10827E+04,-.23289E+01,   
     +                .12214E-01, .29810E-05/        
*     H2CO (136)    
      DATA (QCOEF(57,2,J),J=1,4)/ .22290E+04,-.48211E+01,    
     +                .25122E-01, .60757E-05/            
*     H2CO (128) 
      DATA (QCOEF(58,2,J),J=1,4)/ .10827E+04,-.23289E+01,    
     +                .12214E-01, .29810E-05/             
*     HOCL (165) 
      DATA (QCOEF(59,2,J),J=1,4)/ .10904E+05,-.35742E+02,   
     +                .23414E+00,-.34244E-04/           
*     HOCL (167) 
      DATA (QCOEF(60,2,J),J=1,4)/ .11062E+05,-.36361E+02, 
     +                .23872E+00,-.35509E-04/         
*     N2 (44)     
      DATA (QCOEF(61,2,J),J=1,4)/ .10100E+02, .75749E+00,     
     +               -.67405E-05, .57247E-07/             
*     HCN (124)           
      DATA (QCOEF(62,2,J),J=1,4)/ .24602E+03, .66588E+00,   
     +                .53695E-02,-.92887E-06/            
*     HCN (134)                               
      DATA (QCOEF(63,2,J),J=1,4)/ .49946E+03, .13761E+01,    
     +                .11084E-01,-.19286E-05/           
*     HCN (125)
      DATA (QCOEF(64,2,J),J=1,4)/ .16586E+03, .45963E+00, 
     +                .37319E-02,-.65245E-06/  
*     CH3CL (215)     
      DATA (QCOEF(65,2,J),J=1,4)/ .28504E+05,-.11914E+03,   
     +                .33419E+00, .43461E-04/            
*     CH3CL (229)
      DATA (QCOEF(66,2,J),J=1,4)/ .28955E+05,-.12103E+03,  
     +                .33949E+00, .44151E-04/            
*     H2O2 (1661)              
      DATA (QCOEF(67,2,J),J=1,4)/ .71508E+04, .87112E+00,   
     +                .29330E+00,-.60860E-04/                
*     C2H2 (1221)     
      DATA (QCOEF(68,2,J),J=1,4)/ .94384E+01, .36148E+00,
     +                .33278E-02,-.61666E-06/              
*     C2H2 (1231)     
      DATA (QCOEF(69,2,J),J=1,4)/ .75506E+02, .28919E+01, 
     +                .26623E-01,-.49335E-05/    
*     C2H6 (1221)     
      DATA (QCOEF(70,2,J),J=1,4)/-.10000E+01, .00000E+00,     
     +                .00000E+00, .00000E+00/     
*     PH3  (1111)  
      DATA (QCOEF(71,2,J),J=1,4)/ .28348E+04,-.75986E+01,  
     +                .35714E-01, .58694E-05/          
*     COF2 (269) 
      DATA (QCOEF(72,2,J),J=1,4)/-.10000E+01, .00000E+00,     
     +                .00000E+00, .00000E+00/        
*     SF6 (29)
      DATA (QCOEF(73,2,J),J=1,4)/-.10000E+01, .00000E+00,  
     +                .00000E+00, .00000E+00/     
*     H2S (121)
      DATA (QCOEF(74,2,J),J=1,4)/-.10000E+01, .00000E+00,     
     +                .00000E+00, .00000E+00/                     
*     HCOOH (126)
      DATA (QCOEF(75,2,J),J=1,4)/-.10000E+01, .00000E+00,   
     +                .00000E+00, .00000E+00/                

*  A coefficients for high temperature extrapolation:
*   LN(Q(T))= A*LN(T) + B 
      DATA (AQ(i), i=1,NSPECI)  / .226100E+01, .227050E+01, .227050E+01,  
     +  .226120E+01, .319540E+01, .274440E+01, .268940E+01, .303220E+01,
     +  .299430E+01, .303350E+01, .298930E+01, .253530E+01, .197900E+01,
     +  .107470E+01, .109440E+01, .165290E+01, .142450E+01, .154210E+01,
     +  .150940E+01, .134650E+01, .147370E+01, .148280E+01, .148350E+01,
     +  .147890E+01, .149270E+01, .121370E+01, .130340E+01, .255580E+01,
     + -.100000E+01,                                 
     + -.100000E+01,-.100000E+01, .151060E+01, .150960E+01, .151130E+01,
     +  .196420E+01, .195630E+01, .220060E+01, .234040E+01, .234070E+01,
     +  .166280E+01, .125620E+01, .125060E+01, .139880E+01, .119150E+01,
     +  .134830E+01, .134870E+01, .141210E+01, .141220E+01, .148280E+01,
     +  .123800E+01, .123620E+01, .126930E+01, .126810E+01, .126250E+01,
     +  .126100E+01, .237630E+01, .237490E+01, .237630E+01, .164260E+01,
     +  .163230E+01, .143190E+01, .142360E+01, .141970E+01, .141680E+01,
     +  .235820E+01, .235820E+01, .130420E+01, .139690E+01, .139690E+01,
     + -.100000E+01, .231487E+01,-.100000E+01,-.100000E+01,-.100000E+01,
     + -.100000E+01/                          

* B coefficients for high temperature extrapolation:
*   LN(Q(T))= A*LN(T) + B
      DATA (BQ(i), i=1,NSPECI) / -.865480E+01,-.869570E+01,-.690400E+01,  
     + -.698800E+01,-.142340E+02,-.103890E+02,-.996700E+01,-.105700E+02,
     + -.113190E+02,-.984100E+01,-.126550E+02,-.704580E+01,-.287730E+01,
     +  .329670E+01, .315580E+01,-.586580E+00, .528580E+00,-.212890E+00,
     +  .281140E+00, .308480E+01,-.436250E+01,-.368430E+01,-.437850E+01,
     + -.257950E+01,-.369760E+01, .306600E+00,-.565120E-02,-.514510E+01,
     + -.100000E+01,                                                  
     + -.100000E+01,-.100000E+01, .449890E+00,-.311240E+00, .507160E+00,
     + -.240720E+01,-.234750E+01,-.261510E+01,-.658160E+01,-.698720E+01,
     +  .371490E+01,-.994960E+00,-.947490E+00,-.569920E+00,-.337450E+01,
     + -.311820E+01,-.311940E+01,-.333780E+01,-.333790E+01,-.315210E+01,
     +  .417780E+01, .420940E+01, .318090E+00, .352090E+00, .107600E+01,
     +  .451040E+00,-.691800E+01,-.619030E+01,-.691800E+01, .822630E+00,
     +  .912490E+00,-.330520E+01,-.116380E+01,-.412330E+00,-.148210E+01,
     + -.372050E+01,-.370490E+01, .353900E+01,-.150070E+01, .578920E+00,
     + -.100000E+01,-.550870E+01,-.100000E+01,-.100000E+01,-.100000E+01,
     + -.100000E+01/                                              
********************************************************************
      END
