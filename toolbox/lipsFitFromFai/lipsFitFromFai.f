C        1         2         3         4         5         6         7
C23456789012345678901234567890123456789012345678901234567890123456789012
C
C This programs can do either of the following
C - compute concentration ellipse surface, turn-by-turn, from a multiturn [b_]zgoubi.fai. 
C In principle the program is capable of selecting the element to be considered, if 
C FAISTORA was requested at several different elements along the ring 
C - compute concentration ellipse surface along a line from a single-pass [b_]zgoubi.fai (for 
C instance using '[b_]zgoubi.fai labela, labelb, ...' under FAISTORE.
C
C As an option, dispersion can be removed, as follows :   
C - first produce a zgoubi.TWISS.out file with exactly same sequencing (same numbering) of 
C element as that used to produced  [b_]zgoubi.fai. What will happen is that lipsFitFromFai
C will first read Dx, Dxp, Dy, Dyp as a function of element number in zgoubi.TWISS.out. It 
C will then use it to change coordinates (e.g., Y, T) read from  [b_]zgoubi.fai to 
C dispersion removed coordinates (e.g., Y-Dx*dp/p, T-Dxp*dp/p) 
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      LOGICAL OKOPN, CHANGE
C----- PLOT SPECTRUM     
      COMMON/CDF/ IES,IORDRE,LCHA,LIST,NDAT,NRES,NPLT,NFAI,NMAP,NSPN
      PARAMETER (NCANAL=2500)
      COMMON/SPEDF/BORNE(6),SPEC(NCANAL,3),PMAX(3),NC0(3)

      common/KP/ lusav,kpa,kpb
      LOGICAL IDLUNI

      CHARACTER(80) FILFAI
      logical exs
      character(2) HV
      INTEGER DEBSTR,FINSTR

      character(7) TXT7A, TXT7B, TXT7R, TXT7L, TXTYN
      character(200) TXT200
      character(500) TXT500
      CHARACTER(80) STRA(2)
      logical strcon, ok

      INCLUDE 'MXLD.H'
      dimension disp(4,mxl)
      character(1) rmvDsp
      character(50) dspFNameDflt,dspFName

      data HV / '  ' /
      data stra / 2*'  ' /

C Channel number, .le. NCANAL
      data nc0 / 3* NCANAL /
      data borne / 0.5d0, 1.d0, 0.5d0, 1.d0, 0.d0, 1.d0 /
C kpa = turn # ; nt=-1 for all particles
      data kpa, nt / 1, -1 /
C kla = lmnt # ; inhibited if -1
      data kla / -1 /
      data rmvDsp / 'N' /
      data dspFNameDflt / 'zgoubi.OPTICS.out' / 
       
      write(*,*) ' '
      write(*,*) '----------------------------------------------------'
      write(*,*) 'Now running pgm lipsFitFromFai ... '
      write(*,*) 'Will find ellipse matched to particle population'
     >//' at turn # kpa and at lmnt kla (inhibited if kla=-1),'
     >//' as specified in lipsFitFromFai.In.'
      write(*,*) 'Dispersion will be removed from particle coordinates'
     >//' if requested. '
      write(*,*) '----------------------------------------------------'
      write(*,*) ' '

C Range of turns to be considered may be specified using lipsFitFromFai.In
      INQUIRE(FILE='lipsFitFromFai.In',exist=EXS)

c     if(exs) then
      IF (IDLUNI(lunIn)) THEN
        open(unit=lunIn,file='lipsFitFromFai.In')
      ELSE
        stop 'Pgm lipsFitFromFai :   No idle unit number ! '
      ENDIF

c    elseif(.NOT.exs) then
      if(.NOT.exs) then
        write(*,*)'WARNING : File lipsFitFromFai.In does not exist'
        write(*,*)'Pgm creates one from default values'
        write(*,*)'Press ENTER to continue'

        read(*,*)

        write(lunIn,fmt='(2a)')  'zgoubi.fai '
     >  ,' ! file name (*.fai or b_*.fai type)'
        write(lunIn,fmt='(i6,1x,t40,a)')  kpa
     >  ,' ! kpa : turn # (lips will match bunch for that turn)'
        write(lunIn,fmt='(i6,1x,t40,a)')  kla
     >  ,' ! kla : lmnt # (inhibited if -1)'
        write(lunIn,fmt='(a,2x,a,t40,a)')  rmvDsp,
     >  dspFName(debstr(dspFName):finstr(dspFName)),
     >  ' ! rmvDsp : remove dispersion Y/N (default is No), '
     >  //' Y requires zgoubi.TWISS.out or'
     >  //' zgoubi.OPTICS.out from prior TWISS or OPTICS run.'
      endif

      rewind(lunIn)

C        read(lunIn,*,err=11,end=11) filfai
      read(lunIn,fmt='(a)',err=11,end=11) txt200
      if(strcon(txt200,'!',
     >                     is)) txt200 = txt200(1:is-1)
      txt200=txt200(debstr(txt200):finstr(txt200))
      call strget(txt200,2,
     >                     nbstr,stra)
      read(stra(1),*) filfai
      if(nbstr.eq.2) read(stra(2),*) nt
c            write(*,*) ' lipsFromFai ',nbstr, stra(1)
c            write(*,*) stra(2), nt
c            read(*,*)
      read(lunIn,*,err=11,end=11) kpa
      read(lunIn,*,err=11,end=11) kla
      read(lunIn,fmt='(a)',err=11,end=11) txt200
      close(lunIn)
      if(strcon(txt200,'!',
     >                     is)) txt200 = txt200(1:is-1)
      call strget(txt200,2,
     >                     nbstr,stra)
      read(stra(1),*) rmvDsp
      if(nbstr.eq.2) then 
        read(stra(2),*) dspFName
      else
        dspFName = dspFNameDflt
      endif
      write(*,*) ' Read following data from lipsFitFromFai.In :'
      write(*,*) filfai,'   !  .fai file name '
      write(*,*) kpa,   '   !  # of the turn to be lips''ed '
      write(*,*) kla,   '   !  # of the lmnt to be considered'
     >                              //' (-1 to inhibit)'
      write(*,*) rmvDsp//
     >' '//dspFName(debstr(dspFName):finstr(dspFName))//' '
     >//'   !  remove disperesion (Y/N), file name'
     >//' (either zgoubi.OPTICS.out or zgoubi.TWISS.out)'

c      write(*,*) ' Press Enter to continue'
c     read(*,*)

      if(rmvDsp .eq. 'Y') then
        write(*,*) ' Dispersion removal : ',rmvDsp
        INQUIRE(FILE=dspFName,exist=EXS)
        if(.not. exs) then
          write(*,*) ' However, could not find required file '//
     >    ' '//dspFName(debstr(dspFName):finstr(dspFName))//'.'
     >    //' Dispersion will not be removed.'
        else
          write(*,*) '       using file : '
     >    //dspFName(debstr(dspFName):finstr(dspFName))//'.'
          ok = IDLUNI(ldsp) 
          OPEN(UNIT=ldsp,FILE=dspFName)          
          txt500 = ' ' 
          if(dspFName(debstr(dspFName)+7:debstr(dspFName)+11) .eq. 
     >          'TWISS') then
            dowhile(.not. strcon(txt500,'# From TWISS keyword',
     >                                 is))
              read(ldsp,fmt='(a)',err=20,end=21) txt500
c            write(*,*) ' lips** '//txt500(debstr(txt500):finstr(txt500))
c               read(*,*)
            enddo
            read(ldsp,*) txt500
            read(ldsp,*) txt500
c            write(*,*) ' lips** '//txt500(debstr(txt500):finstr(txt500))
 12         continue
              read(ldsp,fmt='(a)',err=10,end=10) txt500
c              write(*,*) ' lips** READ nuel '
              read(txt500,*,err=10,end=10) 
     >        dum,dum,dum,dum,dum,dum,dum, 
     >        dum,dum,dum,dum,dum,dum,  nuel
c              write(*,*) ' lips** nuel : ',nuel
              read(txt500,*,err=10,end=10) 
     >        dum,dum,dum,dum,dum,dum,
     >        disp(1,nuel),disp(2,nuel),disp(3,nuel),disp(4,nuel)
c              write(*,fmt='(i7,2x,1p,4e14.6,a)') 
c     >        nuel,(disp(id,nuel),id=1,4),' nuel,(disp(id,nuel),i=1,4)'
c                  read(*,*)
            goto 12
          elseif(dspFName(debstr(dspFName)+7:debstr(dspFName)+12) .eq. 
     >          'OPTICS') then
C Read 3 header lines
            read(ldsp,*) txt500
            read(ldsp,*) txt500
            read(ldsp,*) txt500
c            write(*,*) ' lips** '//txt500(debstr(txt500):finstr(txt500))
 13         continue
              read(ldsp,fmt='(a)',err=10,end=10) txt500
c              write(*,*) ' lips** READ nuel '
              read(txt500,*,err=10,end=10) 
     >        dum,dum,dum,dum,dum,dum,dum,dum,dum,dum,dum,dum,dum,nuel
c              write(*,*) ' lips** nuel : ',nuel
              read(txt500,*,err=10,end=10) 
     >        dum,dum,dum,dum,dum,dum,
     >        disp(1,nuel),disp(2,nuel),disp(3,nuel),disp(4,nuel)
c              write(*,fmt='(i7,2x,1p,4e14.6,a)') 
c     >        nuel,(disp(id,nuel),id=1,4),' nuel,(disp(id,nuel),i=1,4)'
c                  read(*,*)
            goto 13
          else
            stop 'Could not disentangle dispersion file name. Sorry. '
          endif
 10       continue
          call readsp(rmvDsp,disp)
        endif
      endif

      INQUIRE(FILE=filfai,exist=EXS)
      if(.not. exs) then
        write(*,*) ' No such file '
     >  ,filfai(debstr(filfai):finstr(filfai))
        stop ' Please change .fai file name in'//
     >  ' lipsFitFromFai[_iterate].In.'
      endif

      if(kpa.eq.0) kpa = 1  ! this is for lipsFitFromFai_iterate
      kpb = kpa 
      kpc = 1
      ksmpl = kpb-kpa+1

      write(TXT7A,fmt='(I7)') kpa
      write(TXT7B,fmt='(I7)') kpb
      write(TXT7R,fmt='(I7)') ksmpl
      write(TXT7L,fmt='(I7)') kla
      write(TXTYN,fmt='(a)') rmvDsp

      write(*,*) ' Particle # : '//'   all ' 
      write(*,*) ' Number of turns and range :  '//TXT7R
     >//' turn(s),  from '//TXT7A//' to '//TXT7B
      write(*,*) ' Lmnt number :  '//TXT7L
      write(*,*) ' Dispersion removal : ',TXTYN

      call READC2B(KPa,KPb,KPc)
      call READC4B(KLa,KLa)
      call INIGR(
     >           NLOG, LM)
C     >           NLOG, LM, FILFAI)
      nl = nfai
      okopn = .false.
      change = .true.
      call LIPS(NLOG,NL,filfai,LM,OKOPN,CHANGE,HV,kpa,kpb,nt,kla)
          
      stop ' Ended correctly it seems...'

 11   continue
      stop 'Error during read from lipsFitFromFai.In.'

 20   continue
      stop 'Reached end of zgoubi.TWISS.out file.'
 21   continue
      stop 'Error during read in zgoubi.TWISS.out file.'
      end

      SUBROUTINE LIPS(NLOG,NL,filfai,LM,OKOPN,CHANGE,HV,kpa,kpb,nt,kla)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      LOGICAL OKOPN, CHANGE
      character(*) HV
      CHARACTER(80) filfai
C----- PLOT SPECTRUM     
      COMMON/CDF/ IES,IORDRE,LCHA,LIST,NDAT,NRES,NPLT,NFAI,NMAP,NSPN
      PARAMETER (NCANAL=2500)
      COMMON/SPEDF/BORNE(6),SPEC(NCANAL,3),PMAX(3),NC0(3)
      INCLUDE 'MAXNPT.H'
      COMMON/TRACKM/COOR(NPTMAX,9),NPTS,NPTR

      DIMENSION YM(3), YPM(3), U(3), A(3), B(3), YNU(3)
      DIMENSION YMX(6), YPMX(6)
 
      LOGICAL OKECH
      CHARACTER(1) REP
      CHARACTER(80) NOMFIC
      LOGICAL BINARY, BINARF
      CHARACTER HVL(3)*12

c      SAVE NT
c      DATA NT / -1 /

      LOGICAL OPN
      DATA OPN / .FALSE. /
      LOGICAL IDLUNI, OKKT5

C      INCLUDE 'FILFAI.H'

      SAVE NPASS, ktma
      dimension nptin(3)

      DATA HVL / 'Horizontal', 'Vertical', 'Longitudinal' /
      data ktma / -1 /
    
      IF(.NOT.OKOPN) 
     > CALL OPNDEF(NFAI,FILFAI,NL,
     >                            NOMFIC,OKOPN) 

      NPTR=NPTS

      OKECH = .FALSE.

      IF(NT.EQ.-1) THEN
        CALL READC6B(1,NPTS)
      ELSE
        CALL READC6B(NT,NT)        
      ENDIF

 6    CONTINUE
C          OPN = .FALSE.
        IF(.NOT. OPN) THEN
         IF(NT.EQ.-1) THEN
          IF (IDLUNI(IUN)) THEN
           call system('cat lipsFitFromFai.Out>>lipsFitFromFai.Out_old')
           call system('rm -f lipsFitFromFai.Out')
           OPEN(UNIT=IUN,FILE='lipsFitFromFai.Out',ERR=699)
           OPN = .TRUE.
           WRITE(IUN,*) '# //////////////////////////////////////////'
           WRITE(*,*) '# //////////////////////////////////////////'
           WRITE(IUN,*) 
     >     '# % Ellipse matching considers turn#',kpa,' and lmnt # ',kla
           WRITE(IUN,*) 
     >     '# XM, XPM, (U(I),I=1,3), '//
     >     'COOR(npass,5)/(npass-1), dp/p, KT, YM, YPM, kpa, kpb, p'//
     >     ', LM, DPM, # of prtcls in rms lips_x,_y,_z, '//
     >     'sig_x,_y,_l, sig_xp,_yp,_d, sig_xxp,_yyp,_ldp, dp/p|Init'//
     >     ', kla, <s>'
C     >    'COOR(npass,5)/(npass-1), dp/p, KT, YM, YPM, kpa, kpb, energ'
          ELSE
            GOTO 698
          ENDIF
         ENDIF
        ENDIF

          IF(NT.EQ.-1) THEN
            KPR = 2
            KT1 = 1
            KT2 = 999999
            CALL READC6B(KT1,KT2)
          ELSE
            KPR = 1
          ENDIF

          nspec = 0
         
C--------- Coordinate reading/storing loop
C 62       CONTINUE
          nspec = nspec + 1
          IF(CHANGE) THEN
            NPTR = NPTMAX
            NPTS=NPTR
            I1 = 1
            CALL STORCO(NL,LM,I1  ,BINARY, 
     >                                     NPASS,energ,ktma)
            CHANGE=.FALSE.
            IF(NPTR.GT.0) THEN
              IF(NPTS.GT. NPTR) NPTS=NPTR
            ELSE
              NPTR = NPTS
c              IF(NT.EQ.-1) KT = 1 
c             GOTO 69
            ENDIF
          ENDIF
          IF(NPTR .GT. 0) THEN
            CALL LPSFIT(NLOG,KPR,LM,
     >                    YM,YPM,YMX,YPMX,U,A,B,nptin,sav,*60)
 60         CONTINUE

c            IF(OKKT5(KT)) THEN
c              IF(KPR.EQ.2) 
               CALL LPSIMP(IUN,YNU,BORNE,U,KT1,ktma,HV
     >             ,npass,kpa,kpb,kla,energ,nptin,sav)

c              write(6,*) ' Pause '
c              read(5,*)

c            ENDIF

          ENDIF

          IF(NT.EQ.-1) THEN
c            KT = KT+1
c            CALL READC6B(KT,KT)
            CALL READC5(
     >                  KT1,KT2)
            CHANGE = .TRUE.
c            IF(KT.LE.KT2) GOTO 62             !--------- Coordinate reading/storing loop
          ENDIF

 69       CONTINUE
          IF(OPN) THEN
            CALL FLUSH2(IUN,.FALSE.)
            CLOSE(IUN)
            CHANGE = .TRUE.
          ENDIF
      GOTO 99


 698  WRITE(6,*) ' *** Problem : No idle unit for lipsFitFromFai.Out '
      stop ' *** Problem : No idle unit for lipsFitFromFai.Out '
c      GOTO 99
 699  WRITE(6,*) ' *** Problem at OPEN lipsFitFromFai.Out '
      stop ' *** Problem : No idle unit for lipsFitFromFai.Out '
c      GOTO 99

 99   RETURN
      END

      SUBROUTINE LPSFIT(NLOG,KPR,LM,
     >                  YM,YPM,YMX,YPMX,U,A,B,nptin,sav,*)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION YM(*), YPM(*), U(*), A(*), B(*)
      DIMENSION YMX(*), YPMX(*)
      INCLUDE 'MAXNPT.H'
      COMMON/TRACKM/COOR(NPTMAX,9),NPTS,NPTR

      DIMENSION G(3)
      CHARACTER TXT(3)*5, REP*1

      INCLUDE 'MAXCOO.H'

      DIMENSION UM(3), UMI(3), UMA(3), SMEAR(3)
      CHARACTER*1 KLET

      PARAMETER ( PI=3.1415926536, SQ2 = 1.414213562)
C      PARAMETER ( PI=4.D0*ATAN(1.D0), SQ2 = SQRT(2.D0) )

      dimension nptin(3)

      DATA TXT/ 'HORI.', 'VERT.', 'LONG.'/

      DO 7 J=1,MXJ-1,2
        YMX(J) = 1.D10
        YMX(J+1) = -1.D10
        YPMX(J) = 1.D10
        YPMX(J+1) = -1.D10
 7    CONTINUE

      DO 2 J=1,MXJ-1,2
C------- JJ = 1 , 2 or 3  for  Y-T, Z-P or T-P(time-momentum) planes
        J1 = J
        J2 = J+1
        JJ= J2 / 2
        XM=0.D0
        XPM=0.D0
        SNPT = 0.D0
        DO 21 I=1,NPTS
            X = COOR(I,J1)
            XP = COOR(I,J2)
            XM = XM + X
            XPM = XPM + XP
c              write(*,fmt='(a,2g12.4,3i4)') 'blibli ',x,xp,i,npts,jj
C----------- Min-max of the distribution
            IF(YMX(J1) .GT. X) YMX(J1) = X
            IF(YMX(J2) .LT. X) YMX(J2) = X
            IF(YPMX(J1) .GT. XP) YPMX(J1) = XP
            IF(YPMX(J2) .LT. XP) YPMX(J2) = XP
            SNPT = SNPT + 1
 21     CONTINUE
        XM = XM/SNPT
        XPM = XPM/SNPT
        YM(JJ)=XM
        YPM(JJ)=XPM
 2    CONTINUE

      call lpsim2(ym(1),ypm(1),ym(2),ypm(2),ym(3),ypm(3))

      DO 25 J=1,MXJ-1,2
C------- JJ = 1 , 2 or 3  for  Y-T, Z-P or T-P(time-momentum) planes
        J1 = J
        J2 = J+1
        JJ= (J+1) / 2
        X2=0.D0
        XP2=0.D0
        XXP=0.D0
        SNPT = 0.D0
        DO 26 I=1,NPTS
            X = COOR(I,J1)
            XP = COOR(I,J2)
            X2 = X2 + (X-YM(JJ))**2
            XP2 = XP2 + (XP-YPM(JJ))**2
            XXP = XXP + (X-YM(JJ))*(XP-YPM(JJ))
            SNPT = SNPT + 1
c              write(*,fmt='(a,3g12.4,i4)') 'blublu ',x,x2,ym(jj),jj
 26     CONTINUE
        X2  = X2/SNPT
        XP2 = XP2/SNPT
        XXP = XXP/SNPT

        call lpsim4(jj,x2,xp2,xxp)

C G. Leleux : surface de l'ellipse S=4.pi.sqrt(DELTA)
C Soit d11=X2/sqrt(DELTA), d12=XXP/sqrt(DELTA), d22=XP2/sqrt(DELTA), alors 
C  d22.x^2-2.d12.x.x'+d11.x'^2=S/pi=4sqrt(DELTA), ce qui permet d'ecrire 
C   gamma=d22=XP2/sqrt(DELTA), -alpha=d12=XXP/sqrt(DELTA), beta=d11=X2/sqrt(DELTA). 
C En outre, par definition des dij, 
C     2.sigma_x=sqrt(d11.S/pi),  2.sigma_x'=sqrt(d22.S/pi). 
C En outre, frontiere : 
C          <x^2>_frontiere=2.(sigma_x)^2,    <x'^2>_frontiere=2.(sigma_x')^2

        SQ = SQRT(X2*XP2-XXP*XXP) 
        IF(SQ .GT. 0.D0) THEN
          B(JJ)=  X2/SQ
C Error  FM 03/02
C          A(JJ)=  XXP/SQ
          A(JJ)=  -XXP/SQ
          G(JJ)=  XP2/SQ
        ENDIF
C------- Courant invariant at 1 sigma is U=4.sqrt(DELTA)=Eps/pi (consistant with zgoubi !!) :
C Eps=ellipse surface
C        U(JJ) = 4.D0*SQ
        U(JJ) = SQ

c        write(*,fmt='(a,3g12.4,2i6)') 'blabla ',x2,xp2,u(jj),npts,jj

 25   CONTINUE

      sav = 0.d0
      DO I=1,NPTS
          sav = sav + COOR(I,8)
          SNPT = SNPT + 1
      enddo
      sav = sav / dble(npts)

      IF(KPR .EQ. 0) RETURN
     
C----- SMEAR and count in lips
      DO 3 J=1,MXJ-1,2
C------- JJ = 1 , 2 or 3  for  Y-T, Z-P or T-P(time-momentum) planes
        J1 = J
        J2 = J+1
        JJ= (J+1) / 2
        UMA(JJ) = -1.D10
        UMI(JJ) = 1.D10
        UM(JJ)=0.D0
        U2M=0.D0
        SNPT = 0.D0
        nptin(jj) = 0
        DO 31 I=1,NPTS
C--------- Normalized coordinates (*Beta), for phase-space point I:
            X = ( COOR(I,J1) - YM(JJ) )
            XP = ( COOR(I,J2) - YPM(JJ) )
            XN = X 
            XPN = ( A(JJ) * XN + B(JJ) * XP )
C----------- Courant invariant Epsilon/pi at phase-space point I:
            UI = ( XN * XN + XPN * XPN )/ B(JJ)

C            Count
            if(ui.le.u(jj)) nptin(jj) = nptin(jj)+1

            IF(UI .GT. UMA(JJ)) UMA(JJ) = UI
            IF(UI .LT. UMI(JJ)) UMI(JJ) = UI

            UM(JJ) = UM(JJ) + UI
            U2M = U2M + UI * UI
            SNPT = SNPT + 1
 31     CONTINUE

        UM(JJ) = UM(JJ)/SNPT
        U2M = U2M/SNPT
        SMEAR(JJ) = SQRT( U2M - UM(JJ) * UM(JJ) )

c        write(*,*) 
c     >  ' lipsfromfai nptin(jj)/imax = ',nptin(jj),'/',npts

 3    CONTINUE

C----- Twiss parameters and emittance
      CALL READC5(NT1,NT2)
      CALL READC9(KKEX,KLET)

      RETURN 1
      END
      SUBROUTINE BLOCK
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)

C----- NUMERO DES UNITES LOGIQUES D'ENTREES-SORTIE
      COMMON/CDF/ 
     >      IES,IORDRE,LCHA,LIST,NDAT,NRES,NPLT,NFAI,NMAP,NSPN
 
C----- CONSTANTES
      COMMON/CONST/ CL,PI,DPI,RAD,DEG,QE,AH

      PARAMETER (MRD=9)
      COMMON/DROITE/ AM(MRD),BM(MRD),CM(MRD),IDRT

      COMMON/EFBS/ AFB(MRD), BFB(MRD), CFB(MRD), IFB

      CHARACTER  KAR(41)
      COMMON/KAR/ KAR
 
      COMMON/OBJET/ FO(6,1),KOBJ,IDMAX,IMAXT
 
      LOGICAL ZSYM
      COMMON/OPTION/ KORD,KFLD,MG,LC,ML,ZSYM
 
      COMMON/PTICUL/ AAM,Q,G,TO
 
      COMMON/REBELO/ NRBLT,IPASS,KWRI,NNDES,STDVM
 
      CHARACTER FAM*8,KLEY*10
      PARAMETER (MXF=30,MXC=10) 
      COMMON/SCAL/
     >  SCL(MXF,MXC),TIM(MXF,MXC),FAM(MXF),KTI(MXF),KSCL,KLEY
 
C----- CONVERSION COORD. (CM,MRD) -> (M,RD)
      PARAMETER (MXJ=7)
      COMMON/UNITS/ UNIT(MXJ-1)

      COMMON/VXPLT/ XMI,XMA,YMI,YMA,KX,KY,IAX,LIS,NB

      DATA NDAT,NRES,NPLT,NFAI,NMAP,NSPN/3,4,1,2,8,9/
 
      DATA CL, PI, DPI, RAD, DEG, QE, AH /
     >2.99792458D8 , 3.141592653589D0, 6.283185307178D0,
     > .01745329252D0 , 57.29577951D0, 1.602176487D-19, 6.626075D-34 /
 
      DATA IDRT / 0 /

      DATA IFB / 0 /

      DATA (KAR(I),I=1,41) /
     > 'O','A','B','C','D','E','F','G','H','I','J','K','L','M','N'
     >,'P','Q','R','T','U','V','W','X','Y','Z','2','3','4','5','6'
     >,'7','8','(',')','+','-','/','=','"','0','*'/
 
      DATA KOBJ /0/
 
      DATA MG,LC,ML,ZSYM/ 1,2,3,.TRUE./
 
      DATA Q / 1.60217733D-19  /
 
      DATA NRBLT,IPASS/0, 1/
 
      DATA (FAM(I),I=1,MXF)/
     > 'AIMANT' , 'QUADRUPO', 'SEXTUPOL', 'QUADISEX' , 'SEXQUAD'
     >,'TOSCA3D', 'OCTUPOLE', 'DECAPOLE', 'DODECAPO'
     >, 'TOSCA' , 'MULTIPOL' , 'DIPOLE'
     >, 'BEND'    , 'SOLENOID' , 'CAVITE'
     >,'POISSON', 14*' ' /
 
C                    Y     T     Z       P     X,S   dp/p
      DATA UNIT / .01D0,.001D0,.01D0, .001D0, .01D0, 1.D0 /

C      DATA KX,KY,IAX,LIS,NB /6, 2, 1, 1, 100 /
      DATA KX,KY,IAX,LIS,NB /2, 3, 1, 1, 100 /

      RETURN

      ENTRY UNITR(KXI,KYI,
     >                    UXO,UYO)
      IF(KXI.EQ.1) THEN
        UXO = UNIT(6)
      ELSEIF(KXI.LE.MXJ) THEN
        UXO = UNIT(KXI-1)
      ELSE
        UXO = 1.D0
      ENDIF
      IF(KYI.EQ.1) THEN
        UYO = UNIT(6)
      ELSEIF(KYI.LE.MXJ) THEN
        UYO = UNIT(KYI-1)
      ELSE
        UYO = 1.D0
      ENDIF
      RETURN
      END
      SUBROUTINE READCO(NL,LM,
     >                        KART,LET,YZXB,NDX,*,*,*)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C     ----------------------------------------------------
C     Look for and read coordinates, etc. of particle # NT
C     ----------------------------------------------------
      CHARACTER(1) LET
      INCLUDE 'MXVAR.H'
      DIMENSION YZXB(MXVAR),NDX(5)

      INCLUDE 'MXLD.H'
      COMMON/LABCO/ ORIG(MXL,6) 
      COMMON/CDF/ IES,IORDRE,LCHA,LIST,NDAT,NRES,NPLT,NFAI,NMAP,NSPN
c      COMMON/LUN/ NDAT,NRES,NPLT,NFAI,NMAP,NSPN
      INCLUDE 'MAXNPT.H'          
      COMMON/TRACKM/COOR(NPTMAX,9),NPTS,NPTR
      PARAMETER (MXJ=7)
      COMMON/UNITS/ UNIT(MXJ-1) 
      COMMON/VXPLT/ XMI,XMA,YMI,YMA,KX,KY,IAX,LIS,NB

      PARAMETER (MXS=4)
      DIMENSION FO(MXJ),F(MXJ),SI(MXS),SF(MXS)
      PARAMETER (MXT=10)
      DIMENSION SX(MXT),SY(MXT),SZ(MXT)
      
      CHARACTER*8 LBL1, LBL2
      CHARACTER KLEY*10

      LOGICAL BINARY,BINAR,OKKP,OKKT,OKKL

      CHARACTER*1 KLET, KLETO, KLETI, TX1

      character(1) rmvdspi, rmvDsp
      dimension dispi(4,mxl), disp(4,mxl)

      SAVE KP1, KP2, KP3, BINARY
      SAVE KL1, KL2
      SAVE KT1, KT2
      SAVE KKEX, KLET
      save disp, rmvDsp

      DATA KP1, KP2, KP3 / 1, NPTMAX, 1 /
      DATA KT1, KT2 / 1, 1 /
      DATA KL1, KL2 / 1, 999999 /
      DATA KKEX, KLET / 1, '*' / 
      
      IF(NL .EQ. NSPN) THEN
      ELSE
        IF(NL .EQ. NFAI) THEN
C--------- read in zgoubi.fai type storage file

          IMAX = 0
          IF(BINARY) THEN
 222        CONTINUE
            READ(NL,ERR=222,END=10) 
     >      KEX,(FO(J),J=1,7),
     >      (F(J),J=1,7), 
     >      (SI(J),J=1,4),(SF(J),J=1,4),
     >      ENEKI, ENERG, 
     >      IT, IREP, SORT, AMQ1,AMQ2,AMQ3,AMQ4,AMQ5, RET, DPR, PS,
     >      BORO, IPASS,NOEL, KLEY,LBL1,LBL2,LET
C            IF(LM .NE. -1) THEN
C              IF(LM .NE. NOEL) GOTO 222
C            ENDIF

            KT3 = 1
            IF(.NOT. OKKT(KT1,KT2,KT3,IT,KEX,LET,
     >                             IEND)) GOTO 222
            IF(.NOT. OKKP(KP1,KP2,KP3,IPASS,
     >                                IEND)) GOTO 222
            IF(.NOT. OKKL(KL1,KL2,NOEL,
     >                                IEND)) GOTO 222
            IF(IEND.EQ.1) GOTO 91

          ELSE
 21         READ(NL,110,ERR=21,END=10)
     >      KEX,(FO(J),J=1,7),
     >      (F(J),J=1,7), 
     >      (SI(J),J=1,4),(SF(J),J=1,4),
     >      ENEKI, ENERG, 
     >      IT, IREP, SORT, AMQ1,AMQ2,AMQ3,AMQ4,AMQ5, RET, DPR, PS,
     >      BORO, IPASS,NOEL, 
     >      TX1,KLEY,TX1,TX1,LBL1,TX1,TX1,LBL2,TX1,TX1,LET,TX1

            INCLUDE "FRMFAI.H"

c               write(*,*) ' lipsfromfai ',KT1,KT2,KT3,IT,KEX
c               write(*,*) '             ',KP1,KP2,KP3,IPASS
c               write(*,*) '             ',KL1,KL2,NOEL
c               write(*,*) OKKT(KT1,KT2,KT3,IT,KEX,LET,
c     >                             IEND),
c     >                     OKKP(KP1,KP2,KP3,IPASS,
c     >                                IEND),
c     >                    OKKL(KL1,KL2,NOEL,
c     >                           IEND)

CCCCCCCCCCC           if(it.eq.1) yref = f(2)
C            IF(LM .NE. -1) THEN
C              IF(LM .NE. NOEL) GOTO 21
C            ENDIF

            KT3 = 1
            IF(.NOT. OKKT(KT1,KT2,KT3,IT,KEX,LET,
     >                             IEND)) GOTO 21

            IF(.NOT. OKKP(KP1,KP2,KP3,IPASS,
     >                                IEND)) GOTO 21

            IF(.NOT. OKKL(KL1,KL2,NOEL,
     >                           IEND)) GOTO 21

            IF(IEND.EQ.1) GOTO 91

          ENDIF

        ELSEIF(NL .EQ. NPLT) THEN
C--------- read in zgoubi.plt type storage file

          IMAX = 0
          IF(BINARY) THEN
 232         CONTINUE
            READ(NL,ERR=232,END=10) 
     >      KEX,(FO(J),J=1,7),
     >      (F(J),J=1,7), DS, 
     >      KART, IT, IREP, SORT, XX, BX, BY, BZ, RET, DPR, 
     >      EX, EY, EZ, BORO, IPASS,NOEL, KLEY,LBL1,LBL2,LET
C            IF(LM .NE. -1) THEN
C              IF(LM .NE. NOEL) GOTO 232
C            ENDIF

            KT3 = 1
            IF(.NOT. OKKT(KT1,KT2,KT3,IT,KEX,LET,
     >                             IEND)) GOTO 232
            IF(.NOT. OKKP(KP1,KP2,KP3,IPASS,
     >                                IEND)) GOTO 232

            IF(.NOT. OKKL(KL1,KL2,NOEL,
     >                           IEND)) GOTO 232

            IF(IEND.EQ.1) GOTO 91

          ELSE
 31         READ(NL,100,ERR=31,END=10)
     >      KEX,(FO(J),J=1,MXJ),
     >      (F(J),J=1,MXJ), DS,
     >      KART, IT, IREP, SORT, XX, BX, BY, BZ, RET, DPR,
     >      EX, EY, EZ, BORO, IPASS, NOEL, 
     7      TX1,KLEY,TX1,TX1,LBL1,TX1,TX1,LBL2,TX1,
     8                                            TX1,LET,TX1
C     >      KLEY,LBL1,LBL2,LET
            INCLUDE "FRMPLT.H"
CCCCCCCCCCC           if(it.eq.1) yref = f(2)                   
C            IF(LM .NE. -1) THEN
C              IF(LM .NE. NOEL) GOTO 31
C            ENDIF

            KT3 = 1
            IF(.NOT. OKKT(KT1,KT2,KT3,IT,KEX,LET,
     >                             IEND)) GOTO 31

            IF(.NOT. OKKP(KP1,KP2,KP3,IPASS,
     >                                IEND)) GOTO 31

            IF(.NOT. OKKL(KL1,KL2,NOEL,
     >                           IEND)) GOTO 31

            IF(IEND.EQ.1) GOTO 91

          ENDIF
        ENDIF        

        IF(KP1.GE.0.AND.IPASS.GT.KP2) GOTO 91

C------- dp/p
        J = 1
        JU = 6
        YZXB(J)   =   F(J)   * UNIT(JU)     
C        YZXB(J)   =   1.D0 + F(J)  
        YZXB(J+10) =  FO(J)   * UNIT(JU)        ! dp/p_initial

C------- Y, T, Z, P, S, Time
        DO 20 J=2,MXJ
          JU = J-1
          YZXB(J)   =  F(J)   * UNIT(JU)     
CCCCCCC          if(j.eq.2) YZXB(J) = (f(j)-yref) * UNIT(JU)
          YZXB(J+10) = FO(J)  * UNIT(JU) 
 20     CONTINUE

C Removal od dispersion -------------------------------------------
C           write(*,*) ' readco rmvDsp : ',rmvdsp
        if(rmvDsp .eq. 'Y') then
          do j = 2, 5
            delta = yzxb(1)
            YZXB(j) = YZXB(j) - disp(j-1,noel) * delta
          enddo
c          write(88,fmt='(i6,10(2x,e12.4))') 
c     >      noel,YZXB(1), (YZXB(j), disp(j-1,noel),j=2,5), delta
        endif
C------------------------------------------------------------------

C           write(66,*) ' sbr readco it ipass, f7 :',it,ipass,yzxb(7)

C------- KART=1 : Cartesian coordinates, X is current x-coordinate
C        KART=2 : Cylindrical coordinates, X is current angle
        YZXB(8) = XX

        IF(KART .EQ. 1)  YZXB(8) = YZXB(8) * UNIT(5)
C         step size :
        YZXB(9) = DS       * UNIT(5)
C         r = sqrt(y^2+z^2) :
        YZXB(10) = SQRT(YZXB(2)*YZXB(2) + YZXB(4)*YZXB(4))
        YZXB(18) = RET
C------- (p_ps)/ps
        YZXB(19) = DPR            
C-------- momentum
C        YZXB(19) = BORO * (1.D0+F(1))*0.299792458D0   
        YZXB(20) = ENERG
C         convert B from kG to T
        YZXB(30) = BX      * .1D0
        YZXB(31) = BY      * .1D0
        YZXB(32) = BZ      * .1D0
        YZXB(33) = SQRT(BY*BY +  BZ*BZ) * .1D0

        YZXB(34) = EX
        YZXB(35) = EY     !!!/YZXB(2)
        YZXB(36) = EZ 
        YZXB(37) = SQRT(EY*EY +  EZ*EZ)

        PI2 = 2.D0*ATAN(1.D0)
        YINL = F(2)* UNIT(1) !!!!!!* AMAG  
        ZINL = F(4)* UNIT(3) !!!!!!* AMAG
C FM, Dec. 05       XINL = XX* UNIT(5) - ORIG(NOEL,5)
        XINL = XX* UNIT(5) + ORIG(NOEL,5)
        YZXB(44) = ZINL 
        PHI = ORIG(NOEL,6)
        CT = COS(ORIG(NOEL,4)+PHI) 
        ST = SIN(ORIG(NOEL,4)+PHI)
        YZXB(48) = ( XINL*CT - YINL*ST) + ORIG(NOEL,1)
        YZXB(42) = ( XINL*ST + YINL*CT) + ORIG(NOEL,2)
      ENDIF

C      Location about where particle was lost
      YZXB(38) = SORT * 1.D-2
      YZXB(39) = IPASS 
      YZXB(57) = NOEL

      NDX(1)=KEX
      NDX(2)=IT
      NDX(3)=IREP
      NDX(4)=IMAX
      NDX(5)=NOEL
      RETURN

 91   RETURN 3

cC------- Read pass #,  KP1 to KP2
c      KP1O=KP1
c      KP2O=KP2
c      RETURN

C------------------ Dispersion function
      ENTRY READSP(rmvDspi,dispi)
      rmvDsp = rmvDspi
      if(rmvDsp .eq. 'Y') then
        do id = 1, 4
          do nuel = 1, mxl
            disp(id,nuel) = dispi(id,nuel)
          enddo
        enddo
      endif
     
c           do nuel = 1, 150
c            write(88,fmt='(1p,4(e12.4,1x),2x,i7)')  
c     >    (disp(id,nuel),id=1,4),nuel
c          enddo
c             stop ' readsp ***************'
      RETURN

C------------------ Pass #, KP1 to KP2
      ENTRY READC1(
     >             KP1O,KP2O)
C------- Read pass #,  KP1 to KP2
      KP1O=KP1
      KP2O=KP2
      RETURN

C--
      ENTRY READC2(LN)
C------- Write pass #,  KP1 to KP2
 12   WRITE(6,FMT='(''  Option status is now : KP1='',I6,
     >   '',   KP2='',I6)') KP1, KP2
        WRITE(6,FMT='(''     Available options are : '',
     >   /,10X,'' KP1, KP2 > 0 : will plot within range [KP1,KP2]'', 
     >   /,10X,'' KP1=-1, KP2 > 0 : will plot every KP2 other pass '')')
        WRITE(6,FMT='(/,
     >        '' Enter desired values KP1, KP2  ( 0 0 to exit ) : '')')
        READ(LN,*,ERR=12) KP1NEW, KP2NEW
      GOTO 11
C--
      ENTRY READC2B(KP1W,KP2W,KP3W)
C------- Pass KP1 to pass KP2, step KP3
        KP1NEW=KP1W
        KP2NEW=KP2W
        KP3NEW=KP3W
 11     CONTINUE
        IF(KP1NEW.NE.0) KP1=KP1NEW
        IF(KP2NEW.NE.0) KP2=KP2NEW
        IF(KP3NEW.NE.0) KP3=KP3NEW
      RETURN
C----------------------------

C------------------ Element #, KL1 to KL2
      ENTRY READC3(
     >             KL1O,KL2O)
C------- Read lmnt #,  KL1 to KL2
      KL1O=KL1
      KL2O=KL2
      RETURN
C--
      ENTRY READC4(LN)
        KLA = KL1
        KLB = KL2
C------- Write lmnt #,  KL1 to KL2
 30     WRITE(6,FMT='('' Observation now at elements  KL1='',I6,
     >   ''to   KL2='',I6)') KL1, KL2
        WRITE(6,FMT='(''     Available options for elment are : '',
     >   /,10X,'' 0 < KL1 < KL2  : will plot within range [KL1,KL2]'', 
     >   /,10X,'' KL1=-1, KL2 > 0 : will plot every KL2 other pass '')')
        WRITE(6,FMT='(/,
     >        '' Enter desired values KL1, KL2  : '')')
        READ(LN,fmt='(2I3)',ERR=33) KL1NEW, KL2NEW
      GOTO 32
 33     KL1NEW = KLA
        KL2NEW = KLB
      GOTO 32
C--
      ENTRY READC4B(KL1W,KL2W)
C------- Lmnt  KL1 to lmnt KL2
        KL1NEW=KL1W
        KL2NEW=KL2W
 32     CONTINUE
        IF(KL1NEW.NE.0) KL1=KL1NEW
        IF(KL2NEW.NE.0) KL2=KL2NEW
      RETURN
C----------------------------

C------------------ Traj # KT1 to traj # KT2
      ENTRY READC5(
     >             KT1O,KT2O)
C------- Read traj.  KT1 to KT2
        KT1O=KT1
        KT2O=KT2
      RETURN
C--
      ENTRY READC6B(KT1W,KT2W)
C------- Traj KT1 to traj KT2
        KT1NEW=KT1W
        KT2NEW=KT2W
 51     CONTINUE
        IF(KT1NEW.NE.0) KT1=KT1NEW
        IF(KT2NEW.NE.0) KT2=KT2NEW
      RETURN
C----------------------------

      ENTRY READC7(BINAR)
      BINAR=BINARY
      RETURN

      ENTRY READC8(BINAR)
      BINARY=BINAR
      RETURN

      ENTRY READC9(KKEXO,KLETO)
        KKEXO=KKEX
        KLETO=KLET
      RETURN

      ENTRY READCX(KKEXI,KLETI)
        KKEX=KKEXI
        KLET=KLETI
      RETURN      

 10   CONTINUE
      KT2 = IT
      RETURN 1

 99   RETURN 2
      END
      SUBROUTINE OPNDEF(LU2O,DEFN2O,LUO,
     >                                  FNO,OKOPN)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      CHARACTER*(*) DEFN2O, FNO
      LOGICAL OKOPN

      LOGICAL EXS, OPN, BINARY 
      CHARACTER*11 FRMT

      IF( LU2O .EQ. -1) THEN
C------- Looks for a free LUO starting from #10
        OKOPN = .FALSE.
        LU2O = 9
 1      CONTINUE  
        LU2O = LU2O+1
        IF(LU2O.EQ.100) GOTO 96
        INQUIRE(UNIT=LU2O,EXIST=EXS,OPENED=OPN,IOSTAT=IOS)
        IF( IOS .EQ. 0 .AND. OPN ) GOTO 1
      ELSEIF(LU2O .EQ. LUO) THEN
C------- Check whether LUO is already open
        INQUIRE(UNIT=LUO,EXIST=EXS,OPENED=OPN,NAME=FNO,IOSTAT=IOS)
        IF(IOS .EQ. 0) THEN
          OKOPN = OPN
        ELSE
          OKOPN = .FALSE.
        ENDIF
      ELSE
        IF(LUO.GT.0) CLOSE(LUO)
        OKOPN = .FALSE.
      ENDIF

      IF(.NOT. OKOPN) THEN
C--------- Check existence of DEFN2O
        INQUIRE(FILE=DEFN2O,EXIST=EXS,IOSTAT=IOS)

        IF(IOS .EQ. 0) THEN

          BINARY=DEFN2O(1:2).EQ.'B_' .OR. DEFN2O(1:2).EQ.'b_'
          IF(BINARY) THEN 
            FRMT='UNFORMATTED'
          ELSE
            FRMT='FORMATTED'
          ENDIF
          IF(EXS) THEN
            OPEN(UNIT=LU2O,FILE=DEFN2O,STATUS='OLD',ERR=99,IOSTAT=IOS,
     >           FORM=FRMT)
            IF(IOS.NE.0) GOTO 97
            I4=4
            IPRNT = 0
            CALL HEADER(LU2O,I4,IPRNT,BINARY,*99)
          ELSE
            OPEN(UNIT=LU2O,FILE=DEFN2O,STATUS='NEW',ERR=99,IOSTAT=IOS,
     >           FORM=FRMT)
            IF(IOS.NE.0) GOTO 97
          ENDIF

          FNO = DEFN2O
          LUO = LU2O
          OKOPN = .TRUE.
        ELSE

          WRITE(6,*) ' Exec error occured in Subroutine OPNDEF : '
          WRITE(6,*) ' IOS NON-ZERO '

        ENDIF
        CALL READC8(BINARY)
      ENDIF

      IF(OKOPN) WRITE(6,FMT='(2A)') 'Opened file is ',DEFN2O

      RETURN

 96   WRITE(6,*) ' Exec error occured in Subroutine OPNDEF : ' 
      WRITE(6,*) ' Logical unit # exceeds 100 ; CANNOT OPEN ',DEFN2O
      RETURN

 97   WRITE(6,*) ' Error occured while in Subroutine OPNDEF : '
      WRITE(6,*) '      IOS NON-ZERO ; CANNOT OPEN ',DEFN2O
 99   CONTINUE
      RETURN

C 98   CONTINUE
C      CLOSE(LU2O)
C      RETURN

      END
      SUBROUTINE INIGR(
     >                 NLOG, LM)
C     >                 NLOG, LM, NOMFIC)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C      CHARACTER*(*) NOMFIC

      LOGICAL OKECH, OKVAR, OKBIN
      COMMON/ECHL/OKECH, OKVAR, OKBIN

      INCLUDE 'MXVAR.H'
      CHARACTER KVAR(MXVAR)*10, KPOL(2)*9, KDIM(MXVAR)*10
      COMMON/INPVR/ KVAR, KPOL, KDIM

      PARAMETER (NCANAL=2500)
      COMMON/SPEDF/BORNE(6),SPEC(NCANAL,3),PMAX(3),NC0(3)

      INCLUDE 'MAXNPT.H'
      COMMON/TRACKM/COOR(NPTMAX,9),NPTS,NPTR

      COMMON/VXPLT/ XMI,XMA,YMI,YMA,KX,KY,IAX,LIS,NB

      CHARACTER * 9   DMY
      CHARACTER*80 TXT
      CHARACTER LOGOT*18, TEMP*80

      DATA  OKECH ,OKVAR, OKBIN / .FALSE., .TRUE., .FALSE.  /

      DATA KVAR/
     >' dp/p ','   Y  ','   T  ','   Z  ','   P  ','   S  ',' Time ',
     >'   X  ',' Step ','   r  ',
     >'dp/p|o','  Yo  ','  To  ','  Zo  ','  Po  ','  So  ',' Time ',
     >'Phase ',' dp/p ','KinEnr',
     >'  Sx  ','  Sy  ','  Sz  ',' <S>  ',
     >' <Sx> ',' <Sy> ',' <Sz> ','COUNT ','      ',
     >'  Bx  ','  By  ','  Bz  ','  Br  ',
     >'  Ex  ','  Ey  ','  Ez  ','  Er  ',
     >' S_out',' Pass#'  ,2*'      ',
     >' Y_Lab','      ',' Z_Lab','      ','      ','      ',' X_Lab',
     >8*' ',
     >' lmnt#' ,
     >13*' '
     >/
      DATA KPOL/ 'CARTESIAN' , 'CYLINDR.' /

      DATA NPTS / NPTMAX /

      DATA KDIM/
     >'       ','  (m)  ',' (rad) ','  (m)  ',' (rad) ','  (m)  ',
     >'(mu_s) ','  (m)  ','  (m)  ','  (m)  '                  ,
     >'       ','  (m)  ',' (rad) ','  (m)  ',' (rad) ','  (m)  ',
     >'       ',' (rad) ','       ',' (MeV) ',9*'       ',
     > 4*'  (T)  ', 4*'(eV/m) ' ,
     >'  (m)  ',3*' ',
     >'  (m)  ','      ','  (m)  ','      ','      ','      ','  (m)  ',
     >22*'   '/


      DATA KARSIZ / 4 /
      SAVE KARSIZ 

C----- Number of the lmnt concerned by the plot (-1 for all)
      LM = -1

C----- tunes log unit
      NLOG = 30
C----- Input data file name
C      Normally, default is zgoubi.fai, .plt, .spn, .map...
C      NOMFIC = 'b_zgoubi.fai'

      RETURN
      END

      SUBROUTINE STORCO(NL,LM,KPS,BINARY,
     >                                   NPASS,energ,ktma)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C     ---------------------------------------------------
C     Read coordinates from zgoubi output file, and store  
C     ---------------------------------------------------
      LOGICAL BINARY
      INCLUDE 'MAXNPT.H'          
      COMMON/TRACKM/COOR(NPTMAX,9),NPTS,NPTR

      CHARACTER LET 

      INCLUDE 'MXVAR.H'
      DIMENSION YZXB(MXVAR),NDX(5)
      LOGICAL IDLUNI

c      logical first(mxt)
c      save first
c      data first / mxt * .true. /

      CALL RAZ(COOR,NPTMAX*9)

      CALL REWIN2(NL,*96)
c      WRITE(6,*) '  REWIND-ing...' 
c      WRITE(6,*) '  READING  AND  STORING  COORDINATES...'

      NOC=0
      NRBLT = -1 
C----- BOUCLE SUR READ FICHIER NL 
 44   CONTINUE
        CALL READCO(NL,LM,
     >                    KART,LET,YZXB,NDX,*10,*44,*17)

C----- NDX: 1->KEX, 2->IT, 3->IREP, 4->IMAX

        if(ndx(2) .gt. ktma) ktma = ndx(2)

        if(noc.eq.0) energ = yzxb(20)

        NOC=NOC+1
        IF(NINT(YZXB(39)) .GE. NRBLT+1) NRBLT = NINT(YZXB(39)) -1
        CALL FILCOO(KPS,NOC,YZXB,NDX)
        IF(NOC.EQ. NPTR) GOTO 10

      GOTO 44             
C     ----------------------------------

 99   CONTINUE
      WRITE(6,*) ' *** Coordinates  storage  stopped: error during',
     > ' read of event # ',NOC+1
      GOTO 11

 10   CONTINUE
      WRITE(6,*) ' END OF FILE  encountered'
c      IF (IDLUNI(ITMP)) open(unit=itmp,file='temp_ipmx')
c      write(itmp,*) noc,' max # of turns in .fai file'
c      close(itmp)
      GOTO 11

 17   CONTINUE
      WRITE(6,*) ' Required # of passes has been read, ',noc,' points'
      GOTO 11

 11   CONTINUE
      NPASS = NRBLT + 1
      NPTR=NOC
      CALL READC5(KT1,KT2)
      write(*,*) ' Pgm lipsFitFromFai, trjctries kt1:kt2 : ',kt1,':',kt2
      IF(KT1 .EQ. -1 .OR. KT2 .GT. KT1) THEN
        WRITE(6,*) '  Analysis of particles from a set '
        IF(KPS.EQ. 0) WRITE(6,*) '  Initial  phase-space'
        IF(KPS.EQ. 1) WRITE(6,*) '  Final  phase-space'
        WRITE(6,*) '  # of turns  in the structure :',NPASS
      ELSEIF(KT1 .EQ. KT2) THEN
        IF(NPASS.EQ.0) THEN
        ELSE
          WRITE(6,*) '  A single  particle  analized          :',KT1
          WRITE(6,*) '  # of turns in the structure   :',NPASS
        ENDIF
      ENDIF

      WRITE(6,*) ' ',NOC,' points have been stored'
      if(noc.eq.0) STOP ' No more points to analize '

 96   RETURN                  
      END
      FUNCTION BINARF(LUN)
      LOGICAL BINARF
      CHARACTER*7 QUID
      INQUIRE(UNIT=LUN,UNFORMATTED=QUID)
      BINARF=QUID.EQ.'YES'
      RETURN
      END
      FUNCTION OKKL(KL1,KL2,NOEL,
     >                           IEND)
      LOGICAL OKKL

      INCLUDE "OKKL.H"

      RETURN
      END
      FUNCTION OKKP(KP1,KP2,KP3,IPASS,
     >                            IEND)
      LOGICAL OKKP

      INCLUDE "OKKP.H"

      RETURN
      END
      FUNCTION OKKT(KT1,KT2,KT3,IT,KEX,LET,
     >                                 IEND)
      LOGICAL OKKT
      CHARACTER*1 LET,KLETO
      LOGICAL OKKT5

      INCLUDE 'MAXNPT.H'          
      LOGICAL LOST(NPTMAX)
      SAVE LOST
      DATA LOST / NPTMAX* .FALSE. / 

      INCLUDE "OKKT.H"

      CALL READC9(KEXO,KLETO)

C------ Plot or store only as long as KEX is correct 
      IF(KEXO.NE.99) OKKT = OKKT .AND. (KEX.EQ.KEXO)
      IF(KLETO.NE.'*') THEN
        IF(KLETO.EQ.'S') THEN
C------ Only secondary particles (from decay process using MCDESINT) can be plotted
          OKKT = OKKT .AND. (LET.EQ.'S')
        ELSEIF(KLETO.EQ.'P') THEN
C------ Only parent particles (if decay process using MCDESINT) can be plotted
          OKKT = OKKT .AND. (LET.NE.'S')
        ENDIF
      ENDIF

      IF(.NOT.LOST(IT)) LOST(IT) = KEX.LE.0
      RETURN

      ENTRY OKKT5(KT)      
      OKKT5 = .NOT. LOST(KT)
      RETURN
      END
      SUBROUTINE FLUSH2(IUNIT,BINARY)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)   
      LOGICAL BINARY
      CHARACTER*80 TXT80
      BACKSPACE(IUNIT)
      IF(.NOT.BINARY) THEN
        READ(IUNIT,FMT='(A80)') TXT80
      ELSE
        READ(IUNIT) TXT80
      ENDIF
      RETURN
      END
      SUBROUTINE REWIN2(NL,*)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      LOGICAL BINAR
      REWIND(NL)
C------- Swallow the header (4 lines)
      CALL READC7(BINAR)
      I4 = 4
      IPRNT = 0
      CALL HEADER(NL,I4,IPRNT,BINAR,*99)
      RETURN
 99   RETURN 1
      END
      FUNCTION IDLUNI(LN)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      LOGICAL IDLUNI

      LOGICAL OPN

      I = 20
 1    CONTINUE
        INQUIRE(UNIT=I,ERR=99,IOSTAT=IOS,OPENED=OPN)
        I = I+1
        IF(I .EQ. 100) GOTO 99
        IF(OPN) GOTO 1
        IF(IOS .GT. 0) GOTO 1
      
      LN = I-1
      IDLUNI = .TRUE.
      RETURN

 99   CONTINUE
      LN = 0
      IDLUNI = .FALSE.
      RETURN
      END
      FUNCTION EMPTY(STR)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      LOGICAL EMPTY
      CHARACTER*(*) STR
      INTEGER FINSTR
      EMPTY = FINSTR(STR) .EQ. 0
      RETURN
      END
      SUBROUTINE RAZ(TAB,N)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION TAB(1)
      DO 1 I=1,N
 1      TAB(I) = 0.D0
      RETURN
      END
      SUBROUTINE FILCOO(KPS,NOC,YZXB,NDX)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION YZXB(*), NDX(*)
      INCLUDE 'MAXNPT.H'
      PARAMETER (NTR=NPTMAX*9)
      COMMON/TRACKM/COOR(NPTMAX,9),NPTS,NPTR

      DIMENSION KXYL(9)
      SAVE KXYL

C                 Y  T  Z  P  time enrg dppInit,<s>, unused
      DATA KXYL / 2, 3, 4, 5, 7,   20,  11,      6,  1 /
CCCC                  Y  T  Z  P  time   dp/p dppInit unused
CCCC      DATA KXYL / 2, 3, 4, 5, 7,     1,   11,     2*1 /
C                          RF  RF
C                  Y  T  Z phi dp  dppInit unused
C      DATA KXYL / 2,3,4,5,18, 19, 11,     2*1 /

C----------- Current coordinates
          II = 0
C----------- Initial coordinates
          IF(KPS.EQ. 0) II = 10

          COOR(NOC,1)=YZXB(KXYL(1)+II )
          COOR(NOC,2)=YZXB(KXYL(2)+II )
          COOR(NOC,3)=YZXB(KXYL(3)+II )
          COOR(NOC,4)=YZXB(KXYL(4)+II )
          COOR(NOC,5)=YZXB(KXYL(5)+II )
          COOR(NOC,6)=YZXB(KXYL(6) )
          COOR(NOC,7)=YZXB(KXYL(7) )  ! dp_p|Init
          COOR(NOC,8)=YZXB(KXYL(8) )  ! average s
      RETURN
      END
      SUBROUTINE HEADER(NL,N,IPRNT,BINARY,*)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      LOGICAL BINARY
      CHARACTER*80 TXT80
c      WRITE(6,FMT='(/,A,I2,A)') ' Now reading  ',N,'-line  file  header'
      IF(.NOT.BINARY) THEN
        READ(NL,FMT='(A80)',ERR=99,END=99) TXT80
        if(IPRNT.eq.1) 
     >        WRITE(6,FMT='(A)') TXT80
        READ(NL,FMT='(A80)',ERR=99,END=99) TXT80
        if(IPRNT.eq.1) 
     >        WRITE(6,FMT='(A)') TXT80
      ELSE
        READ(NL,ERR=99,END=89) TXT80
        if(IPRNT.eq.1) 
     >        WRITE(6,FMT='(A)') TXT80
        READ(NL,ERR=99,END=89) TXT80
        if(IPRNT.eq.1) 
     >        WRITE(6,FMT='(A)') TXT80
      ENDIF
      IF(.NOT.BINARY) THEN
        DO 1 I=3, N
           READ(NL,FMT='(A)',ERR=99,END=89) TXT80
           if(IPRNT.eq.1) 
     >           WRITE(6,FMT='(A)') TXT80
 1      CONTINUE
      ELSE
        DO 2 I=3, N
           READ(NL,          ERR=99,END=89) TXT80
           if(IPRNT.eq.1) 
     >           WRITE(6,FMT='(A)') TXT80
 2      CONTINUE
      ENDIF
      RETURN
 89   CONTINUE
      WRITE(6,*) 'END of file reached while reading data file header'
      RETURN 1
 99   CONTINUE
      WRITE(6,*) '*** READ-error occured while reading data file header'
      WRITE(6,*) '        ... Empty file ?'
      RETURN 1
      END
      SUBROUTINE SPEPR(NLOG,KPR,NT,NPTS,YM,YPM,YNU,PMAX,NC0)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION YM(*), YPM(*), YNU(*), PMAX(*), NC0(*)

      CHARACTER*12 HVL(3)
      CHARACTER*2 YC(3), YPC(3)
      CHARACTER TIT(3)*4, REP
      CHARACTER TXTP*5,TXTL*14

      DATA YC / 'Y', 'Z', 'X' /
      DATA YPC / 'Y''', 'Z''', 'D' /
      DATA HVL / 'Horizontal', 'Vertical', 'Longitudinal' /
      DATA TIT/'NuY=','NuZ=','NuX='/
 
      IF(NT.EQ.-1) THEN
        WRITE(TXTP,FMT='(A5)') '* all'
      ELSE
        WRITE(TXTP,FMT='(I5)') NT
      ENDIF
      CALL READC3(KL1,KL2)
      IF(KL1.EQ.-1) THEN
        WRITE(TXTL,FMT='(A5)') '* all'
      ELSE
        WRITE(TXTL,FMT='(I5,A4,I5)') KL1,' to ',KL2
      ENDIF
      WRITE(*,101) TXTP,TXTL,NPTS 
 101  FORMAT(/,' Part',A5,'  at Lmnt ',A5,' ; ',I6,' PNTS') 

      DO 1 JNU = 1, 3
        WRITE(*,FMT='(A,''  motion :'')') HVL(JNU)
        WRITE(*,FMT=
     >  '(10X,''Center at '',2A,''  ='',1P,2E12.4,'' (MKSA)'')') 
     >  YC(JNU), YPC(JNU), YM(JNU), YPM(JNU)
        WRITE(*,179) TIT(JNU),YNU(JNU),1.D0-YNU(JNU),PMAX(JNU),NC0(JNU)
 179    FORMAT(1X,A4,1P,'/[1-]',G14.6,'/',G14.6,'   Ampl. =',G12.4,
     >        ',   ',I4,' bins')
 1    CONTINUE

      IF(KPR.EQ.1) THEN   
 20     WRITE(*,*)
        WRITE(*,*) '  PRINT IN tunes.log (Y/N)?' 
        READ(*,FMT='(A1)',ERR=20) REP 
        IF(REP .NE. 'N' .AND. REP .NE. 'n') REP = 'y'
      ELSEIF(KPR.EQ.2) THEN
        REP = 'y'
      ENDIF
 
      IF(REP.EQ. 'y') THEN

        WRITE(*,*) '  Tunes will be printed in tunes.log'
        WRITE(*,*) '---------------------------------------------------'
        WRITE(*,*) 
        WRITE(NLOG,101) NT,NPTS 

        DO 10 JNU = 1, 3
          WRITE(NLOG,FMT='(A,''  motion :'')') HVL(JNU)
          WRITE(NLOG,FMT=
     >    '(10X,''Center at '',2A,''  ='',1P,2E12.4,'' (MKSA)'')') 
     >    YC(JNU), YPC(JNU), YM(JNU), YPM(JNU)
          WRITE(NLOG,179) 
     >         TIT(JNU),YNU(JNU),1.D0-YNU(JNU),PMAX(JNU),NC0(JNU)
C----------  This is to flush the write statements...
             CALL FLUSH2(NLOG,.FALSE.)
 10     CONTINUE

      ENDIF

      RETURN
      END
      SUBROUTINE LPSIMP
     >(IUN,YNU,BORNE,U,KT1,kt2,HV,npass,kpa,kpb,kla,energ,nptin,sav)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION YNU(*), BORNE(*), U(*)
      character HV*(*)
      dimension nptin(*)
      INCLUDE 'MAXNPT.H'
      PARAMETER (NTR=NPTMAX*9)
      COMMON/TRACKM/COOR(NPTMAX,9),NPTS,NPTR
      LOGICAL OKKT5
      INCLUDE 'MXVAR.H'
      DIMENSION YZXB(MXVAR)
      save xm,xpm,ym,ypm,zm,zpm
      dimension sigx2(3), sigxp2(3), sigxxp(3) 
      save sigx2, sigxp2, sigxxp 

      IF(NPTS.EQ.NPTR) THEN 
        WRITE(IUN,179) XM, XPM
     >  ,(U(I),I=1,3),COOR(npass,5)/(npass-1), COOR(1,6)
     >  ,KT2-kt1,YM, YPM,kpa,kpb,energ, zm, zpm,(nptin(I),I=1,3)
     >  ,(sqrt(sigx2(I)),I=1,3),(sqrt(sigxp2(I)),I=1,3)
     >  ,(sqrt(sigxxp(I)),I=1,3),COOR(npass,7),kla,sav
!!     >      ,  xK, xiDeg,' ',HV
        WRITE(*,179) XM, XPM
     >  ,(U(I),I=1,3),COOR(npass,5)/(npass-1), COOR(1,6)
     >  ,KT2-kt1,YM, YPM,kpa,kpb,energ, zm, zpm,(nptin(I),I=1,3)
     >  ,(sqrt(sigx2(I)),I=1,3),(sqrt(sigxp2(I)),I=1,3)
     >  ,(sqrt(sigxxp(I)),I=1,3),COOR(npass,7),kla,sav
      ENDIF
 179  FORMAT(1P,7(1x,E14.6),1x,I6,2(1x,E14.6),2(1x,i8),3(1x,E14.6),
     >3(1x,i6),10(1x,E14.6),1x,i6,1x,e14.6)

!! 179    FORMAT(1P,6G14.6,2I4,2G12.4,2a)
      RETURN

      entry lpsim2(xmi,xpmi,ymi,ypmi,zmi,zpmi)
      xm =  xmi
      xpm = xpmi
      ym =  ymi
      ypm = ypmi
      zm =  zmi
      zpm = zpmi
      return

      entry lpsim4(jj,x2,xp2,xxp)
      sigx2(jj) = x2
      sigxp2(jj) = xp2
      sigxxp(jj) = xxp
      return

      END
      FUNCTION DEBSTR(STRING)
      implicit double precision (a-h,o-z)
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
      FUNCTION FINSTR(STR)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INTEGER FINSTR
      CHARACTER * (*) STR
C     -----------------------------------
C     Renvoie dans FINSTR le rang du
C     dernier caractere non-blanc de STR.
C     Renvoie 0 si STR est vide ou blanc.
C     -----------------------------------

      FINSTR=LEN(STR)+1
1     CONTINUE
         FINSTR=FINSTR-1
         IF(FINSTR.EQ. 0) RETURN
         IF (STR(FINSTR:FINSTR).EQ. ' ') GOTO 1
      RETURN
      END
      FUNCTION STRCON(STR,STR2,
     >                         IS)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      LOGICAL STRCON
      CHARACTER STR*(*), STR2*(*)
C     ---------------------------------------------------------------
C     .TRUE. if the string STR contains the string STR2 at least once
C     IS = position of first occurence of STR2 in STR 
C     (i.e.,STR(IS:IS+LEN(STR2)-1)=STR2)
C     ---------------------------------------------------------------
      INTEGER DEBSTR,FINSTR
      LNG2 = LEN(STR2(DEBSTR(STR2):FINSTR(STR2)))
      IF(LEN(STR).LT.LNG2) GOTO 1
      DO I = DEBSTR(STR), FINSTR(STR)-LNG2+1
        IF( STR(I:I+LNG2-1) .EQ. STR2 ) THEN
          IS = I 
          STRCON = .TRUE.
          RETURN
        ENDIF
      ENDDO
 1    CONTINUE
      STRCON = .FALSE.
      RETURN
      END
      SUBROUTINE STRGET(STR,MSS,
     >                          NST,STRA)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      CHARACTER(*) STR, STRA(MSS)
C     ------------------------------------------------------
C     Extract substrings #1 up to #MSS, out of string STR. 
C     Strings are assumed spaced by (at least) one blank. 
C     They are saved in  array STRA, and their actual number 
C     (possibly < mss) is NST.
C     ------------------------------------------------------
      INTEGER FINSTR

      CHARACTER STR0*(300)

      if(len(str0).lt.len(str)) 
     >  stop ' SBR STRGET : Increase length of string str0'

      STR0 = STR
      IE = FINSTR(STR)
      NST = 0
      I2 = 1

 1    CONTINUE

        IF(STR(I2:I2) .EQ. ' '  .OR. 
     >     STR(I2:I2) .EQ. ',') THEN
          I2 = I2 + 1
          IF(I2 .LE. IE) GOTO 1
        ELSE
          I1 = I2
 2        CONTINUE
          I2 = I2 + 1
          IF(I2 .LE. IE) THEN
            IF(STR(I2:I2) .EQ. ' '  .OR. 
     >         STR(I2:I2) .EQ. ',') THEN
              IF(NST .LT. MSS) THEN
                NST = NST + 1
                STRA(NST) = STR(I1:I2-1)
                I2 = I2 + 1
                GOTO 1
              ENDIF
            ELSE
              GOTO 2
            ENDIF
          ELSE
            IF(STR(I2-1:I2-1) .NE. ' ' .AND.
     >         STR(I2-1:I2-1) .NE. ',') THEN
              IF(NST .LT. MSS) THEN
                NST = NST + 1
                STRA(NST) = STR(I1:I2-1)
              ENDIF
            ENDIF
          ENDIF
        ENDIF

      STR = STR0

      RETURN
      END
