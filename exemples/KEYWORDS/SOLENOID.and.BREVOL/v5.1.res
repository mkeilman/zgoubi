NuFactory. Solenoid pion capture. In-flight decay into muon                                                   
 'OBJET'                                                                                                           1
 833.910238                                                                                                   
 5                                                                                                            
 0.1  0.1 0.1 0.1 0. .001 'o'                                                                                 
 0.  0. 0. 0. 0. 1.                                                                                           
 'DRIFT'                                                                                                           2
-20.                                                                                                          
'BREVOL'                                                                                                           3
 0 0                                                                                                          
 0.095933608187 1                                                                                             
 TEST CARTE SOLENO                                                                                            
 1521                                  IX                                                                     
 sol30m.map                                                                                                   
 0  0. 0. 0.                            PAS DE DROITE COUPURE                                                 
 2                                                                                                            
 1.                                                                                                           
 1 0 0 0                                                                                                      
 'DRIFT'                                                                                                           4
-20.                                                                                                          
'FAISCEAU'                                                                              5                          5
'MATRIX'                                                                                                           6
 1  0                                                                                                         
'RESET'                                                                                                            7
 'OBJET'                                                                                                           8
 833.910238                                                                                                   
 5                                                                                                            
 0.1  0.1 0.1 0.1 0. .001 'o'                                                                                 
 0.  0. 0. 0. 0. 1.                                                                                           
  'SOLENOID'                                                                            9                          9
   0                                                                                                          
   3000.  1.  16.                                                                                             
   20.  20.                                                                                                   
 1.                                                                                                           
   1  0. 0. 0.                                                                                                
'FAISCEAU'                                                                             10                         10
'MATRIX'                                                                               1                          11
 1  0                                                                                                         
 'END'                                                                                                            12

********************************************************************************************************************************
      1  OBJET       1                 
                          MAGNETIC  RIGIDITY =        833.910 kG*cm

                                         CALCUL  DES  TRAJECTOIRES

                              OBJET  (5)  FORME  DE     11 POINTS 



                                Y (cm)         T (mrd)       Z (cm)        P (mrd)       S (cm)        dp/p 
               Sampling :          0.10          0.10          0.10          0.10           0.0          0.1000E-02
  Reference trajectory #1 :         0.0           0.0           0.0           0.0           0.0           1.000    

********************************************************************************************************************************
      2  DRIFT       2                 

                              Drift,  length =   -20.00000  cm

 TRAJ 1 IEX,D,Y,T,Z,P,S,time :  1   1.000       0.000       0.000       0.000       0.000          -20.000           0.0000    

 Cumulative length of optical axis =  -0.200000     m ;   corresponding Time  (for ref. rigidity & particle) =  -2.5911E-09 s 

********************************************************************************************************************************
      3  BREVOL      3                 

           Title in this field map problem : TEST CARTE SOLENO                                                                                                      
  A total of           1  field map(s) to be loaded :
          sol30m.map                                                                      


     Min/max fields in map       :   0.1040                    /    166.8    
       @  X(CM),  Y(CM), Z(CM) :  3.020E+03  0.00      0.00    /  1.474E+03  0.00      0.00    
     Normalisation coeffs on B, x, y, z   :  9.5934E-02   1.000       0.000       0.000    
     Min/max normalised fields (kG)  :  9.9809E-03                       16.00    

     Nber of steps in X =1521;  nber of steps in Y =    1
     Step in X =   2.000     cm ;  step in Y =   0.000     cm

                     OPTION  DE  CALCUL  : 2

                    Integration step :   1.000     cm


 Cumulative length of optical axis =  -0.200000     m ;   corresponding Time  (for ref. rigidity & particle) =  -2.5911E-09 s 

********************************************************************************************************************************
      4  DRIFT       4                 

                              Drift,  length =   -20.00000  cm

 TRAJ 1 IEX,D,Y,T,Z,P,S,time :  1   1.000       0.000       0.000       0.000       0.000           3000.0          0.10140    

 Cumulative length of optical axis =  -0.400000     m ;   corresponding Time  (for ref. rigidity & particle) =  -5.1823E-09 s 

********************************************************************************************************************************
      5  FAISCEAU    5                 
0                                             TRACE DU FAISCEAU

                                               11 TRAJECTOIRES

                                   OBJET                                                  FAISCEAU

          D       Y(CM)     T(MR)     Z(CM)     P(MR)    S(CM)          D       Y(CM)     T(MR)     Z(CM)     P(MR)    S(CM)

O   1   1.0000     0.000     0.000     0.000     0.000     0.000       1.0000    0.000    0.000    0.000    0.000    3000.000      1
A   1   1.0000     0.100     0.000     0.000     0.000     0.000       1.0000    0.077   -0.394   -0.043    0.218    3000.001      2
B   1   1.0000    -0.100     0.000     0.000     0.000     0.000       1.0000   -0.077    0.394    0.043   -0.218    3000.001      3
C   1   1.0000     0.000     0.100     0.000     0.000     0.000       1.0000    0.004    0.077   -0.002   -0.043    3000.000      4
D   1   1.0000     0.000    -0.100     0.000     0.000     0.000       1.0000   -0.004   -0.077    0.002    0.043    3000.000      5
E   1   1.0000     0.000     0.000     0.100     0.000     0.000       1.0000    0.043   -0.218    0.077   -0.394    3000.001      6
F   1   1.0000     0.000     0.000    -0.100     0.000     0.000       1.0000   -0.043    0.218   -0.077    0.394    3000.001      7
G   1   1.0000     0.000     0.000     0.000     0.100     0.000       1.0000    0.002    0.043    0.004    0.077    3000.000      8
H   1   1.0000     0.000     0.000     0.000    -0.100     0.000       1.0000   -0.002   -0.043   -0.004   -0.077    3000.000      9
I   1   1.0010     0.000     0.000     0.000     0.000     0.000       1.0010    0.000    0.000    0.000    0.000    3000.000     10
J   1   0.9990     0.000     0.000     0.000     0.000     0.000       0.9990    0.000    0.000    0.000    0.000    3000.000     11


  Beam  characteristics   (EMIT,ALP,BET,XM,XPM,NLIV,NINL,RATIN) : 

   2.2848E-07    3.916        7.749        0.000       1.1908E-21      11      11    1.000    B-Dim     1      1
   2.2848E-07    3.916        7.749        0.000      -2.0279E-21      11      11    1.000    B-Dim     2      1
   2.9468E-08  -1.8200E-14   2.0636E-07   0.1014        250.0          11      11    1.000    B-Dim     3      1


  Beam  characteristics   SIGMA(4,4) : 

           Ex, Ez =  1.818150E-08  1.818150E-08
           AlpX, BetX = -3.915979E+00  7.749441E+00
           AlpZ, BetZ = -3.915979E+00  7.749441E+00

  1.408964E-07 -7.119836E-08 -2.040666E-20  4.357924E-11

 -7.119836E-08  3.832442E-08 -4.358089E-11  8.444697E-16

 -2.040666E-20 -4.358089E-11  1.408964E-07 -7.119836E-08

  4.357924E-11  8.444697E-16 -7.119836E-08  3.832441E-08

********************************************************************************************************************************
      6  MATRIX      6                 

           Frame for MATRIX calculation moved by :
            XC =    0.000 cm , YC =    0.000 cm ,   A =  0.00000 deg  ( = 0.000000 rad )


Path length of particle  1 :   3000.0000     cm


                  TRANSFER  MATRIX  ORDRE  1  (MKSA units)

          0.769172        0.441907        0.425152        0.244596         0.00000         0.00000    
         -0.394252        0.768688       -0.218234        0.426021         0.00000         0.00000    
         -0.425152       -0.244596        0.769172        0.441907         0.00000         0.00000    
          0.218234       -0.426021       -0.394252        0.768688         0.00000         0.00000    
           0.00000         0.00000         0.00000         0.00000         1.00000         0.00000    
           0.00000         0.00000         0.00000         0.00000         0.00000         1.00000    

          DetY-1 =      -0.2345240302,    DetZ-1 =      -0.2345240349

          R12=0 at  -0.5749     m,        R34=0 at  -0.5749     m

      First order sympletic conditions (expected values = 0) :
        -2.1123E-05   -2.1123E-05    8.6743E-04    4.8808E-04    4.8426E-04   -8.6742E-04

********************************************************************************************************************************
      7  RESET       7                 

********************************************************************************************************************************
      8  OBJET       8                 
                          MAGNETIC  RIGIDITY =        833.910 kG*cm

                                         CALCUL  DES  TRAJECTOIRES

                              OBJET  (5)  FORME  DE     11 POINTS 



                                Y (cm)         T (mrd)       Z (cm)        P (mrd)       S (cm)        dp/p 
               Sampling :          0.10          0.10          0.10          0.10           0.0          0.1000E-02
  Reference trajectory #1 :         0.0           0.0           0.0           0.0           0.0           1.000    

********************************************************************************************************************************
      9  SOLENOID    9                 

      -----  SOLENOID    : 
                Length  of  element  :    3000.      cm
                Inner radius  RO =   1.000      cm
                B-CNTRL  =   16.00         kG
                     XE =   20.00     cm,   XS =   20.00     cm

                    Integration step :   1.000     cm


 Cumulative length of optical axis =    29.6000     m ;   corresponding Time  (for ref. rigidity & particle) =   3.8349E-07 s 

********************************************************************************************************************************
     10  FAISCEAU    10                
0                                             TRACE DU FAISCEAU

                                               11 TRAJECTOIRES

                                   OBJET                                                  FAISCEAU

          D       Y(CM)     T(MR)     Z(CM)     P(MR)    S(CM)          D       Y(CM)     T(MR)     Z(CM)     P(MR)    S(CM)

O   1   1.0000     0.000     0.000     0.000     0.000     0.000       1.0000    0.000    0.000    0.000    0.000    3000.000      1
A   1   1.0000     0.100     0.000     0.000     0.000     0.000       1.0000    0.079   -0.394   -0.039    0.219    3000.001      2
B   1   1.0000    -0.100     0.000     0.000     0.000     0.000       1.0000   -0.079    0.394    0.039   -0.219    3000.001      3
C   1   1.0000     0.000     0.100     0.000     0.000     0.000       1.0000    0.011    0.197   -0.006   -0.117    3000.000      4
D   1   1.0000     0.000    -0.100     0.000     0.000     0.000       1.0000   -0.011   -0.197    0.006    0.117    3000.000      5
E   1   1.0000     0.000     0.000     0.100     0.000     0.000       1.0000    0.039   -0.219    0.079   -0.394    3000.001      6
F   1   1.0000     0.000     0.000    -0.100     0.000     0.000       1.0000   -0.039    0.219   -0.079    0.394    3000.001      7
G   1   1.0000     0.000     0.000     0.000     0.100     0.000       1.0000    0.006    0.117    0.011    0.197    3000.000      8
H   1   1.0000     0.000     0.000     0.000    -0.100     0.000       1.0000   -0.006   -0.117   -0.011   -0.197    3000.000      9
I   1   1.0010     0.000     0.000     0.000     0.000     0.000       1.0010    0.000    0.000    0.000    0.000    3000.000     10
J   1   0.9990     0.000     0.000     0.000     0.000     0.000       0.9990    0.000    0.000    0.000    0.000    3000.000     11


  Beam  characteristics   (EMIT,ALP,BET,XM,XPM,NLIV,NINL,RATIN) : 

   5.9615E-07    1.402        3.023        0.000       2.0159E-21      11      11    1.000    B-Dim     1      1
   5.9615E-07    1.402        3.023        0.000       8.4824E-22      11      11    1.000    B-Dim     2      1
   2.4223E-08  -2.0378E-14   1.6963E-07   0.1001        250.0          11      11    1.000    B-Dim     3      1


  Beam  characteristics   SIGMA(4,4) : 

           Ex, Ez =  4.743977E-08  4.743974E-08
           AlpX, BetX = -1.401913E+00  3.023169E+00
           AlpZ, BetZ = -1.401913E+00  3.023170E+00

  1.434185E-07 -6.650642E-08  1.197561E-13  2.900055E-09

 -6.650642E-08  4.653261E-08 -2.899633E-09  3.748799E-13

  1.197561E-13 -2.899633E-09  1.434185E-07 -6.650641E-08

  2.900055E-09  3.748799E-13 -6.650641E-08  4.653259E-08

********************************************************************************************************************************
     11  MATRIX      11                

           Frame for MATRIX calculation moved by :
            XC =    0.000 cm , YC =    0.000 cm ,   A =  0.00000 deg  ( = 0.000000 rad )


Path length of particle  1 :   3000.0000     cm


                  TRANSFER  MATRIX  ORDRE  1  (MKSA units)

          0.785462         1.14673        0.393477        0.622675         0.00000         0.00000    
         -0.394006         1.97302       -0.219150         1.17189         0.00000         0.00000    
         -0.393477       -0.622632        0.785462         1.14676         0.00000         0.00000    
          0.219150        -1.17181       -0.394006         1.97306         0.00000         0.00000    
           0.00000         0.00000         0.00000         0.00000         1.00000         0.00000    
           0.00000         0.00000         0.00000         0.00000         0.00000         1.00000    

          DetY-1 =       1.0015534429,    DetZ-1 =       1.0015978378

          R12=0 at  -0.5812     m,        R34=0 at  -0.5812     m

      First order sympletic conditions (expected values = 0) :
          1.599         1.599        0.1381        0.2306        3.4204E-02   -0.1381    

********************************************************************************************************************************
     12  END         12                

                            11 particles have been launched
                     Made  it  to  the  end :     11

********************************************************************************************************************************

           MAIN PROGRAM : Execution ended upon key  END       

********************************************************************************************************************************

  Zgoubi, version 5.1.0.
  Job  started  on  02-Feb-15,  at  16:57:11 
  Job  ended  on  02-Feb-15,  at  16:57:11 

   CPU time, total :    8.00039999999999918E-002
