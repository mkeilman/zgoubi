      IMPLICIT DOUBLE PRECISION (A-H,O-Z)

c      PARAMETER (NA=500, NR=150)
      PARAMETER (NA=1000, NR=300)
c      PARAMETER (NA=700, NR=200)

      DIMENSION ATAB(NA), RTAB(NR), BZ(NA,NR)
      DIMENSION XB(NA,NR), YB(NA,NR)

      parameter(T2kG = 10.D0)
      parameter(c = 2.99792458d8, amp =  938.27231d6)
      parameter(amu =  931.75d6)

      character txt120*120
      data lunIn, lunW /  7, 12  /

      data akappa,nCO,map,kaseV,ASectr,DltACN /-1.D0,1, 0,0, 0.D0, 0.D0/

      PI = 4.D0 * ATAN(1.D0)
      R2D=180.D0/PI
      D2R = 1.D0/R2D
      am = amp

      write(6,*) 
      write(6,*) '--------------------------------------------'
      write(6,*) ' geneMap procedure now running...' 
      write(6,*) 

c---------------- Hypothesis data : 
      call readat
     >   (lunIn,'geneMap.data', 
     >    nCell, AK, ZTA, pf, R0,T0,G0, akappa, A,Q, T1,T2,kCO,map,
     >    kaseV,ASectr,DltACN,kDrift)

      if (Q.le.0.d0) Q = 1.d0
      if (A.le.0.d0) A = 1.d0
      if (A.gt.1.d0) am = amu 

      write(6,*) ' Inout data read from geneMap.data file, '

      if(ASectr.eq.0.d0) ASectr = 2. * PI / NCELL
      GK = akappa
      G0cm = G0 * 1.d2

c---------------- END HYPOTHESIS       
      if(kCO .eq. -1) then 
        nCO = 1
      elseif(kCO .lt. 1 .or. kCO .gt. 1000) then 
        nCO = 5
      else
        nCO = kCO
      endif

      ZTA=ZTA  * D2R
      p0 = sqrt(T0 * (T0 + 2.* am))
      p1 = sqrt(T1 * (T1 + 2.* am))
      p2 = sqrt(T2 * (T2 + 2.* am))
      Brho0 = p0/c / (Q/A)
      Brho1 = p1/c / (Q/A)
      Brho2 = p2/c / (Q/A)
      r2 = r0 * (p2/p0)**(1.d0/(ak+1.d0))
      write(6,*)
      write(6,fmt='(''K,xi,Gap,kappa,pf as read from geneMap.data :'', 
     > 2F10.4,'' (deg.)  '',3F10.4)')  AK, ZTA*R2D, G0, akappa, pf
      write(6,fmt='(''A, Q, T1, T2, T0, r0, nCell, nCO values read :'', 
     > 5F16.2,'' (eV)  '',F10.4,'' (m)'', 2I6)')
     > A,Q,T1,T2,T0,R0,nCell,nCO
      write(6,*) '  BRho-Ref,  BRho-min, BRho_max : ',
     >                               Brho0, Brho1, Brho2,' T.m'

      DR = R2 * (1.d0 - (p1/p2)**(1.d0/(AK+1.d0)))
      RMED = R2 - DR/2.d0

      RMIN = (R2-DR) - 0.2D0
C       RMAX = R2 + 1.D0
      RMAX = R2 + 0.2D0

      write(6,fmt='('' RMin, RMax, R0, DR : '',1p,4g12.4)') 
     >                                       RMin, RMax, R0, DR 

      TTF = 2.D0 * PI / NCELL
      Af = TTF * PF    ! sector angle of magnet

      B0 = T2kG * brho0 /  (r0*sin(Af/2.)/sin(ttf/2.)) 
      write(6,fmt='('' B0 : '',1p,g12.4,'' kG '')') B0

      C0=0.1455D0        ! fringe coefficients
      C1=2.267D0
      C2=-.6395D0
      C3=1.1558D0
      C4=0.D0
      C5=0.D0    
C----------------------------------------

      XACC=0.0001D0     ! accuracy for newton zero method
C      XACC=0.0000001D0     ! accuracy for newton zero method

      RO1=R0
      B1=1.D0/TAN(ZTA)
      RO2=R0
      B2=B1

c      AMIN = DLOG(RMIN/RO2)/B2 - 20.D0 * G0 /RMIN
c      AMAX = DLOG(R0/RO1)/B1 + 20.D0 * G0 /RMAX      
      ACN = 0.D0 + DltACN
c      AMIN = -ASectr/2.D0 - ACN
c      AMAX =  ASectr/2.D0 - ACN
      AMIN = -ASectr/2.D0 
      AMAX =  ASectr/2.D0 

c           write(6,*)  '  AMIN, AMAX, ACN ',amin,amax,acn

      OMG = Af  /2.D0
C Positionning of spiral EFB #1
      TTA1=  ACN + OMG
C Positionning of spiral EFB #2
      TTA2=  ACN - OMG

      
      if(kDrift.eq.1) then
        dchrf = ASectr
      else
        dchrf = TTF
      endif
      chrfe =  -((ASectr - dchrf )/2.D0 + ACN)
      chrfs =    (ASectr - dchrf )/2.D0 - ACN
c        write(6,*) ' Total angle of map ASectr, ACENT : ',
c     >                         ASectr*r2d,' deg.',ACN*r2d,' deg.'
c        write(6,*) ' RE ALE RS ALS =  0. ',chrfe,' 0. ',chrfs

C----------------------------------------
C Generate closed orbit
C and make zgoubi_geneMap-Out.dat file
      OPEN(UNIT=lunW,FILE='zgoubi_geneMap-Out.dat')
      write(lunW,fmt='(2(a,F10.4),a)') 
     >'Data generated by geneMap. K=',AK,' xi=',ZTA*R2D,' deg'
      write(lunW,*) '''OBJET'''      
      write(lunW,*) Brho0*1000.,'     ',T0/1.d6,' (MeV)'
      write(lunW,*) '2'
      write(lunW,*) nCO,'   1'
      if(kaseV.eq.1) then 
        z = 1.d-4 
      else
        z = 0.d0
      endif
      zp = 0.d0
      ddr = 0.d0
      if(nCO.gt.1) ddr = DR / float(nCO-1) 
c      ddr = DR / float((nCO+2)/2) 
      do iCO = 1, nCO
        if(nCO.gt.1) then
          r = R2-(iCO-1.)*ddr
        else
          if(kCO.eq.-1) then
c yields co at min energy, T1
            r =   R2-DR
          else
            r =   R2-DR/2.d0
          endif
        endif
        rhoF = r * sin(Af/2.d0) / sin(TTF/2.d0)       
c        r = r * cos(Af/2.d0) + ( rhoF*(1.d0-cos(TTF/2.d0))
c     >          + r*(1.d0-cos(Af/2.d0)) )/2.d0
c        r = r * cos(Af/2.d0) +  rhoF*(1.d0-cos(TTF/2.d0))
        tta  =  -DLOG(r/R0) / B1
C        rCO = r * cos((TTF-Af)/2.D0) / cos(tta)
        rCO = r * cos((dchrf-Af)/2.D0) / cos(tta)
        pRel = (r/R0)**(1.D0+AK)
c           write(*,*) 'r , pRel = ',r, pRel, 2*nCell*r*(
c     >       sin(pi/nCell*(1.-pf)) +pi/nCell*pf)
        pp = pRel * p0
        TT = sqrt(pp*pp+am*am) - am 
        write(lunW,fmt='(1p,2g13.5,2g12.4,a,g15.7,a,i1,a,g13.5,a)')
     >   rCO*100.d0, tta*1000.d0 + 15.D0,
     >     z, zp, '  0.  ',pRel,' ''',mod(iCO,10),'''',
     >     TT/1.e6, ' MeV'
        write(*,fmt='(1p,2g13.5,2g12.4,a,g15.7,a,i1,a,g13.5,a)')
     >   rCO*100.d0, tta*1000.d0 + 15.D0,
     >   z,zp , '  0.  ',pRel,' ''',mod(iCO,10),''' ', TT/1.e6, ' MeV'
      enddo
      txt120 = '1 1 1 1 1 1 1 1 1 1'
      do iico = 1, nco,10
        write(lunW,*) txt120
      enddo
      txt120 =  '''PARTICUL'''
      write(lunW,*) txt120
      amass = 938.27231d0 * A
      charge = 1.60217733d-19 * Q
      write(txt120,fmt='(1p,2e14.6,2x,a)') amass, charge, '0. 0. 0.'
C      txt120 = '938.27231  1.60217733D-19 0. 0. 0.'
      write(lunW,*) txt120
      txt120 = '''PICKUPS'''
      write(lunW,*) txt120
      txt120 = '1'
      write(lunW,*) txt120
      txt120 = '#E'
      write(lunW,*) txt120
      txt120 = '''FAISTORE'''
      write(lunW,*) txt120
      txt120 = 'b_zgoubi.fai   #E'
      write(lunW,*) txt120
      txt120 = '1'
      write(lunW,*) txt120
c      txt120 = '''MARKER''  #S '
c      write(lunW,*) txt120
      txt120 =  '''CHAMBR'''
      write(lunW,*) txt120
      txt120 =  ' 1'
      write(lunW,*) txt120
      yl = 999. !!!!(rmax-rmin)/2. *1.5 *100.
      yc = (rmax+rmin)/2. *100.
      zl = 2.* G0cm
      write(lunW,fmt='(3(a,f9.4),a)')  ' 1 ',yl,' ',zl,' ',yc,'  0.'
      txt120 = '''FAISCEAU'''
      write(lunW,*) txt120
C      stepM = G0cm/300.d0 
      stepM = G0cm/20.d0 
      stepA = G0cm/20.d0 
      do kCell=1, 1  !!!nCell
        if(kDrift.eq.1) call insrtD(TTF-ASectr,R0,lunW)
        if(map.eq.1) then
C Generate .dat type file using field map
          txt120 = '''POLARMES'''
          write(lunW,*) txt120
          txt120 = '0 0 '
          write(lunW,*) txt120
          txt120 = '1. 1. 1. '
          write(lunW,*) txt120
          txt120 = ' Dipole SPIRAL'
          write(lunW,*) txt120
          write(lunW,*) NA,NR
          txt120 = 'FIELDMAP'
          write(lunW,*) txt120
          txt120 = '0  0. 0. 0. '
          write(lunW,*) txt120
          txt120 = '2    25 '
          write(lunW,*) txt120
          write(txt120,fmt='(f7.3)') stepM            !!   integration step size (cm)    
          write(lunW,*) txt120
        else
C Generate .dat type file using flying mesh 
           txt120 =  '''FFAG-SPI'''    
           write(lunW,*) txt120
           txt120 = '0 ' 
           write(lunW,*) txt120
           write(txt120,fmt='(a,1p,2e14.6)') '1 ',ASectr*R2D,R0*100.D0     !! NMAG, ASectr=tetaF+2tetaD+2Atan(XFF/R0), R0
           write(lunW,*) txt120
           ACENT = ACN*R2D      
           write(txt120,fmt='(f8.4,a,F8.4,a,F8.4)') 
     >                         ACENT,' 0. ',B0,' ',AK   !!   mag 1 : ACENT, drm, B0, K       
           write(lunW,*) txt120
           write(txt120,fmt='(1p,2e12.4)') G0cm,GK           !! EFB 1 : gap_0, kappa (=0/.ne.0 -> const/var)
           write(lunW,*) txt120
           txt120 = '6  .1455   2.2670  -.6395  1.1558  0. 0.  0.'       !!  Fringe Field Coefficients                    
           write(lunW,*) txt120
           write(txt120,fmt='(1p,2e14.6,a)') 
     >             OMG*R2D,ZTA*R2D,' 1.E6  -1.E6  1.E6  1.E6'  !!  omega, spiral angle,4 dummies                
           write(lunW,*) txt120
           write(txt120,fmt='(1p,2e12.4)') G0cm,GK           !! EFB 2 : gap_0, kappa (=0/.ne.0 -> const/var)
           write(lunW,*) txt120
           write(txt120,fmt='(a)')  
     >           '6  .1455   2.2670  -.6395  1.1558  0. 0.  0.'                                   
           write(lunW,*) txt120
           write(txt120,fmt='(1p,2e14.6,a)') 
     >             -OMG*R2D,ZTA*R2D,' 1.E6  -1.E6  1.E6  1.E6'  !!  omega, spiral angle,4 dummies                
           write(lunW,*) txt120
           write(txt120,fmt='(a)') '0. -1 '                             !!     EFB 3 : inhibited by iop=0       
           write(lunW,*) txt120
           write(txt120,fmt='(a)')  '0  0.   0.   0.   0.   0. 0.  0.'   
           write(lunW,*) txt120
           write(txt120,fmt='(a)') '0.  0.   0.    0.    0. 0.'
           write(lunW,*) txt120
           write(txt120,fmt='(a)') ' 2    10. '                  !!   KIRD anal/num (=0/2,25,4), resol(mesh=step/resol)
           write(lunW,*) txt120
           write(txt120,fmt='(f7.3)') stepA            !!   integration step size (cm)    
           write(lunW,*) txt120
        endif
        txt120 = '2'
        write(lunW,*) txt120
        write(lunW,*) ' 0. ',chrfe,' 0. ',chrfs
      enddo !nCell
      txt120 = '''FAISCEAU'''
      write(lunW,*) txt120
      txt120 = '''MARKER''  #E '
      write(lunW,*) txt120
      txt120 = '''END'''
      write(lunW,*) txt120

            txt120 = ' '
            write(lunW,*) txt120
            txt120 = ' '
            write(lunW,*) txt120
            txt120 = '''REBELOTE'''
            write(lunW,*) txt120
            txt120 = '99   0.2  99'
            write(lunW,*) txt120

      close(12)

      call system('mv -f zgoubi.dat zgoubi.dat_save')
      call system('cp -f zgoubi_geneMap-Out.dat zgoubi.dat')
C----------------------------------------

      WRITE(6,*)  '  amin, amax, ACENT (deg.) : ',
     >                     amin*r2d, amax*r2d, ACN*r2d 
      WRITE(6,*) ' Total sector angle : ',ASectr*R2D,' deg.'
      WRITE(6,*) ' Magnetic sector : ',(TTA1-TTA2)*R2D,' deg.'
      SETVAL = FFSPI1(TTA1,TTA2,GK)

      ASTP =(AMAX-AMIN)/FLOAT(NA-1)
      RSTP = (RMAX-RMIN)/FLOAT(NR-1)

      WRITE(6,*) '  ASTP/NA, RSTP/IR : ',ASTP,'/',NA,' (rad),  ',
     >     RSTP,'/',NR,' (cm)  '
      CALL CPU_TIME(TIMSEC)

      IF(MAP.EQ.1) THEN

        OPEN(UNIT=10,FILE='FIELDMAP',FORM='FORMATTED')

        IRSTP = 1
        IASTP = 1    
        DO 1 IR = 1, NR, IRSTP
          RTAB(IR) = RMIN + (IR-1.D0)*RSTP
c          write(77,*) ir,rtab(ir)
 1      CONTINUE
        DO 2 IA = 1, NA, IASTP
          ATAB(IA) = AMIN + (IA-1.D0)*ASTP
          write(77,*) ia,atab(ia), amin, amax
 2      CONTINUE
        DO 3 IR = 1, NR, IRSTP
          RB = RTAB(IR) 
          DO 3 IA = 1, NA, IASTP
            XB(IA,IR) = RB * COS(ATAB(IA))
            YB(IA,IR) = RB * SIN(ATAB(IA))
 3      CONTINUE

c          write(*,*) ' nr,irstp,na,iastp :', nr,irstp,na,iastp 
        write(*,*) ' computing field map, wait ... '
        DO 4 IR = 1, NR, IRSTP

          WRITE(88,*) 
          WRITE(11,*)  

          DO 4 IA = 1, NA, IASTP

C             write(*,*) ' ia, ir : ', ia, ir
            BZ(IA,IR)=FFSPIF(ATAB(IA),RTAB(IR),XB(IA,IR),YB(IA,IR),B0,
     >       R0,R2,AK,AMIN,AMAX,XACC,RO1,B1,RO2,B2,G0,C0,C1,C2,C3,C4,C5,
     >                                                  DE,FE,DS,FS)
          WRITE(11,FMT='(1P, 3G12.4, 2I4,6G12.4)') ATAB(IA),RTAB(IR),
     >      BZ(IA,IR), IA,IR,DE,FE,DS,FS,XB(IA,IR),YB(IA,IR)
        
 4      CONTINUE


        TEMP = TIMSEC
        CALL CPU_TIME(TIMSEC)
        WRITE(   6,*) '  CPU time, total :  ',  TIMSEC-TEMP

        WRITE(10,*)  ' carte de champ aimant spiral'
        WRITE(10,*)  ' carte de champ aimant spiral'
        WRITE(10,*)  ' ----------------------------   '
c            ACN = 0.D0
            KART = 2
C        WRITE(10,992) NA,NR,ACN,(RMAX+RMIN)/2.D0*100.,KART
        KMOD = 0
        WRITE(10,992) NA,NR,ACN,R2*1.D2,KART,KMOD
 992    FORMAT(2I4,1P,2E15.7,1X,2I3)
        WRITE(10,*) (ATAB(I),I=1,NA),(RTAB(J)*100.,J=1,NR)
     >    ,((BZ(I,J),I=1,NA),J=1,NR)

C gnuplot seulement si la carte n'est pas trop volumineuse
        if(na.le.600) 
     >    call system('gnuplot
     >~/zgoubi/struct/ffag/tools/spiralFFAG/scanKXi/gnuplotMap.cmd')
c        call system('gv gnuplotMap.eps ')
      ENDIF ! if map=1 

      STOP
      END

      FUNCTION FFSPIF(A,R,XB,YB,B0,R0,R2,AK,AMIN,AMAX,XACC,
     >                      RO1,B1,RO2,B2,G0,C0,C1,C2,C3,C4,C5,
     >                                                DE,FE,DS,FS)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER (PLIM=40.D0)
      SAVE TTA1,TTA2, GK

C Rustine carte pi/2
         IF(R.GT.1.3D0*R2)  THEN
           FFSPIF = 0.D0
           goto 88
         ENDIF

C Gap shape
C         GK = -1.D0
         G = G0 * (R0/R)**GK

C  DISTANCE TO FIRST EFB, AND FIELD FACTOR
         DE=-DSTEFB(XB,YB,RO1,B1,AMIN,AMAX,XACC,TTA1,
     >                                             YN)
         IF(YB.GT.YN) DE = -DE
         GE=DE/G         
         P = (C0+GE*(C1+GE*(C2+GE*(C3+GE*(C4+GE*C5)))))
            IF    (P .GE.  PLIM) THEN
              FE = 0.D0
            ELSEIF(P .LE. -PLIM) THEN
              FE = 1.D0
            ELSE
              FE = 1.D0/(1.D0+EXP(P))
            ENDIF

C  DISTANCE TO FIRST EFB, AND FIELD FACTOR
         DS=DSTEFB(XB,YB,RO2,B2,AMIN,AMAX,XACC,TTA2,
     >                                             YN)
         IF(YB.GT.YN) DS = -DS
         GS=DS/G
         P = (C0+GS*(C1+GS*(C2+GS*(C3+GS*(C4+GS*C5)))))
            IF    (P .GE.  PLIM) THEN
              FS = 0.D0
            ELSEIF(P .LE. -PLIM) THEN
              FS = 1.D0
            ELSE
              FS = 1.D0/(1.D0+EXP(P))
            ENDIF
            
         FMIN=1.D-60
         IF (FE.LT.FMIN) FE=0.D0
         IF (FS.LT.FMIN) FS=0.D0
       
         FFSPIF = B0 * (R/R0)**AK*FE*FS 

C 88      WRITE(88,FMT='(1P, 6G14.6)') A*R, R, FFSPIF
 88      WRITE(88,FMT='(1P, 6G14.6)') xb, yb, FFSPIF

      RETURN
      
      ENTRY FFSPI1(TTA1I,TTA2I,GKI)
      TTA1=TTA1I
      TTA2=TTA2I
      GK = GKI
      RETURN

      END

      FUNCTION DSTEFB(XB,YB,D,E,AMIN,AMAX,XACC,TTARF,
     >                                             YN)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      TZ=RTNEWT(XB,YB,D,E,AMIN,AMAX,XACC,TTARF)
      XN = D*EXP(E*TZ)*COS(TZ+TTARF)
      YN = D*EXP(E*TZ)*SIN(TZ+TTARF)
      DSTEFB=SQRT( (XB - XN)**2 + (YB - YN)**2 )
      RETURN
      END
      
      FUNCTION RTNEWT(XB,YB,D,E,X1,X2,XACC,TTARF)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER (JMAX=10000)
C      RTNEWT=.5D0*(X1+X2)
      RTNEWT=X2
      DO 11 J=1,JMAX
         TEMP=RTNEWT
         CALL FUNCD(RTNEWT,XB,YB,D,E,F,DF,TTARF)
         DX=F/DF
C     DEB RAJOUT
         DXLIM=1.D0
         IF (ABS(DX).GT.DXLIM) THEN
            DX=0.1D0*(X1+X2)
C            write(*,*)'test ajout flo'
         ENDIF
C     FIN RAJOUT
         RTNEWT=RTNEWT-DX
         IF((X1-RTNEWT)*(RTNEWT-X2).LT.0.D0) THEN 
           RTNEWT=TEMP 
           RETURN   
         ENDIF

         IF(ABS(DX).LT.XACC) RETURN 
 11      CONTINUE
C      PAUSE 'rtnewt exceeding maximum iterations'
      RETURN
      END
      FUNCTION RTNEWT_OLD(XB,YB,D,E,X1,X2,XACC,TTARF)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER (JMAX=10000)
      PARAMETER (DXLIM=1.D0)

      RTNEWT=.5D0*(X1+X2)
c      RTNEWT=X2 - .1D0*(X2-X1)
      DO 11 J=1,JMAX
         CALL FUNCD(RTNEWT,XB,YB,D,E,F,DF,TTARF)
         DX=F/DF
C      DEB RAJOUT
         IF (ABS(DX).GT.DXLIM) DX=0.1D0*(X1+X2) 
C      FIN RAJOUT
         RTNEWT=RTNEWT-DX
C         IF((X1-RTNEWT)*(RTNEWT-X2).LT.0.)PAUSE 'jumped out of brackets'
         IF((X1-RTNEWT)*(RTNEWT-X2).LT.0.D0) GOTO 11
         IF(ABS(DX).LT.XACC) goto 99
 11      CONTINUE
C      PAUSE 'rtnewt exceeding maximum iterations'
 99   continue
c       write(*,*) ' sbr rtnewt, max J value =',J
      RETURN
      END

      SUBROUTINE FUNCD(X,XB,YB,D,E,FN,DF,TTARF)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      FN=FCTN(XB,YB,D,E,X,TTARF)
      DF=DFCTN(XB,YB,D,E,X,TTARF)
      RETURN
      END
      
      FUNCTION FCTN(XB,YB,R0,B,T,TTARF)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      SAVE EBT, cost, sint
      EBT = EXP(B*T)
      COST=COS(TTARF+T)
      SINT=SIN(TTARF+T)
      FCTN= 
     - (XB - EBT*R0*COST)*(B*EBT*R0*COST - EBT*R0*SINT) + 
     - (YB - EBT*R0*SINT)*(EBT*R0*COST + B*EBT*R0*SINT)
C        WRITE(*,*) ' (FCTN) T, FCTN = ',T, FCTN,B,XB,YB,E,TTARF,R0
      RETURN
      ENTRY DFCTN(XB,YB,R0,B,T,TTARF)
       DFCTN= 
     - (B*EBT*R0*COST - EBT*R0*SINT)*(-(B*EBT*R0*COST) + EBT*R0*SINT) + 
     - (XB - EBT*R0*COST)*(-(EBT*R0*COST) + B**2*EBT*R0*COST- 
     - 2*B*EBT*R0*SINT) + (-(EBT*R0*COST) - B*EBT*R0*SINT)*
     - (EBT*R0*COST + B*EBT*R0*SINT) + (YB - EBT*R0*SINT)*
     - (2*B*EBT*R0*COST - EBT*R0*SINT + B**2*EBT*R0*SINT)
      RETURN
      END

      FUNCTION STRCON(STR,STRIN,NCHAR,
     >                                IS)
      implicit double precision (a-h, o-z)
      LOGICAL STRCON
      CHARACTER STR*(*), STRIN*(*)
C     ------------------------------------------------------------------------
C     .TRUE. if the string STR contains the string STRIN with NCHAR characters
C     at least once.
C     IS = position of first occurence of STRIN in STR
C     ------------------------------------------------------------------------

      INTEGER DEBSTR,FINSTR

      II = 0
      DO 1 I = DEBSTR(STR), FINSTR(STR)
        II = II+1
        IF( STR(I:I+NCHAR-1) .EQ. STRIN ) THEN
          IS = II
          STRCON = .TRUE.
          RETURN
        ENDIF
 1    CONTINUE
      STRCON = .FALSE.
      RETURN
      END
      FUNCTION DEBSTR(STRING)
      implicit double precision (a-h, o-z)
      INTEGER DEBSTR
      CHARACTER * (*) STRING

C     --------------------------------------
C     RENVOIE DANS DEBSTR LE RANG DU
C     1-ER CHARACTER NON BLANC DE STRING,
C     OU BIEN 0 SI STRING EST VIDE ou BLANC.
C     --------------------------------------

      DEBSTR=0
      LENGTH=LEN(STRING)
C      LENGTH=LEN(STRING)+1
1     CONTINUE
        DEBSTR=DEBSTR+1
C        IF(DEBSTR .EQ. LENGTH) RETURN
C        IF (STRING(DEBSTR:DEBSTR) .EQ. ' ') GOTO 1
        IF (STRING(DEBSTR:DEBSTR) .EQ. ' ') THEN
          IF(DEBSTR .EQ. LENGTH) THEN
            DEBSTR = 0
            RETURN
          ELSE
            GOTO 1
          ENDIF
        ENDIF

      RETURN
      END
      FUNCTION FINSTR(STRING)
      implicit double precision (a-h, o-z)
      INTEGER FINSTR
      CHARACTER * (*) STRING
C     --------------------------------------
C     RENVOIE DANS FINSTR LE RANG DU
C     DERNIER CHARACTER NON BLANC DE STRING,
C     OU BIEN 0 SI STRING EST VIDE ou BLANC.
C     --------------------------------------

      FINSTR=LEN(STRING)+1
1     CONTINUE
        FINSTR=FINSTR-1
        IF(FINSTR .EQ. 0) RETURN
        IF (STRING(FINSTR:FINSTR) .EQ. ' ') GOTO 1

      RETURN
      END

      subroutine readat(lunIn,fname, 
     >  nCell, AK, ZTA, pf, r0, T0, gap, akappa,AA,QQ,T1,T2,nCO,map, 
     >  kaseV,AT,DltACN,kDrift)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)

      include "READAT.H"
C      open(unit=lunIn,file='geneMap.data')

      return
      end

      subroutine insrtD(ASectr,R0,lunW)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      character txt120*120
      PI = 4.D0 * ATAN(1.D0)
      R2D=180.D0/PI
           txt120 =  '''DIPOLE'''    
           write(lunW,*) txt120
           txt120 = '0 ' 
           write(lunW,*) txt120
           write(txt120,fmt='(1p,2e14.6)') ASectr*R2D,R0*100.D0     !! NMAG, ASectr=tetaF+2tetaD+2Atan(XFF/R0), R0
           write(lunW,*) txt120
           ACENT = ASectr*R2D/2.      
           write(txt120,fmt='(F8.4,a)') 
     >                         ACENT,'  1e-10  0.  0.  0.    '   !!   mag 1 : ACENT, B, n, b, g
           write(lunW,*) txt120
           write(txt120,fmt='(a)') '  0.  0. '    !! lambda, qsi (sharp edge)
           write(lunW,*) txt120
           txt120 = '6  .1455  2.267  -.6395  1.1558 0. 0. 0.'                                   
           write(lunW,*) txt120
           omgp = ACENT
           write(txt120,fmt='(1p,e14.6,a)') 
     >             omgp,' 0.  1.E6  -1.E6  1.E6  1.E6'  !!  omega, tta, 4 dummies                
           write(lunW,*) txt120
           write(txt120,fmt='(a)') '  0.  0. '    !! lambda, qsi (sharp edge)
           write(lunW,*) txt120
           txt120 = '6  .1455  2.267  -.6395  1.1558 0. 0. 0.'                                   
           write(lunW,*) txt120
           omgm = -ACENT
           write(txt120,fmt='(1p,e14.6,a)') 
     >             omgm,' 0. 1.E6  -1.E6  1.E6  1.E6'  !!  omega, spiral angle,4 dummies                
           write(lunW,*) txt120
           write(txt120,fmt='(a)') '0. -1 '          !!     EFB 3 : inhibited by iop=0       
           write(lunW,*) txt120
           write(txt120,fmt='(a)')  '0  0.   0.   0.   0.   0. 0.  0.'   
           write(lunW,*) txt120
           write(txt120,fmt='(a)') '0.  0.   0.    0.    0. 0. 0.'
           write(lunW,*) txt120
           write(txt120,fmt='(a)') ' 2    10. '          !!   KIRD anal/num (=0/2,25,4), resol(mesh=step/resol)
           write(lunW,*) txt120
           stepA = ASectr*R0*100.D0/50.D0  
           write(txt120,fmt='(f7.3)') stepA   !!   integration step size (cm)    
           write(lunW,*) txt120
        txt120 = '2'
        write(lunW,*) txt120
        write(lunW,*) ' 0. 0. 0. 0. '
      txt120 = '''FAISCEAU'''
      write(lunW,*) txt120

      return
      end





