C  ZGOUBI, a program for computing the trajectories of charged particles
C  in electric and magnetic fields
C  Copyright (C) 1988-2007  Fran�ois M�ot
C
C  This program is free software; you can redistribute it and/or modify
C  it under the terms of the GNU General Public License as published by
C  the Free Software Foundation; either version 2 of the License, or
C  (at your option) any later version.
C
C  This program is distributed in the hope that it will be useful,
C  but WITHOUT ANY WARRANTY; without even the implied warranty of
C  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
C  GNU General Public License for more details.
C
C  You should have received a copy of the GNU General Public License
C  along with this program; if not, write to the Free Software
C  Foundation, Inc., 51 Franklin Street, Fifth Floor,
C  Boston, MA  02110-1301  USA
C
C  Fran�ois M�ot <fmeot@bnl.gov>
C  Brookhaven National Laboratory      
C  C-AD, Bldg 911
C  Upton, NY, 11973
C  -------
      SUBROUTINE ERRORS
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C     ********************************
C     READS DATA FOR PROCEDURE 'ERRORS'
C     ********************************
      COMMON/CDF/ IES,LF,LST,NDAT,NRES,NPLT,NFAI,NMAP,NSPN,NLOG
      INCLUDE 'MXLD.H'
      COMMON/DON/ A(MXL,MXD),IQ(MXL),IP(MXL),NB,NOEL
      CHARACTER(80) TA
      PARAMETER (MXTA=45)
      COMMON/DONT/ TA(MXL,MXTA)
      COMMON/REBELO/ NRBLT,IPASS,KWRT,NNDES,STDVM

      CHARACTER(132) TXT132
      LOGICAL STRCON, OK
      CHARACTER(40) STRA(10)
 
      PARAMETER (KSIZ=10)
      CHARACTER(KSIZ) KLERR
      PARAMETER (LBLSIZ=10)
      CHARACTER(LBLSIZ) LBL1, LBL2
C                  XR, ZS... 
      CHARACTER(2) TYPERR
C                  A or R   G or U
      CHARACTER(1) TYPAR,   TYPDIS
      LOGICAL EMPTY
      INTEGER DEBSTR, FINSTR 

      DATA LBL1, LBL2 / 2*' ' /

C on/off switch  (1/0), number of lines to follow (each line sets a particular error)
      IOP = NINT(A(NOEL,1) )
      NBR = NINT (A(NOEL,2) )
      CALL REBELR(
     >            KREB3,KDUM,KDUM)
      ISEED = NINT (A(NOEL,3) )
      IF(KREB3 .EQ. 99) THEN
C Re-initialize the series to same seed, after REBELOTE, when multi-turn tracking.
        DUMMY = RNDM2(ISEED)
      ELSE
        IF(IPASS .EQ. 1) DUMMY = RNDM2(ISEED)
      ENDIF

      IF (IOP .EQ. 0) THEN 
C        Switch off all possible earlier error settings
        CALL MULTP4
      ENDIF

      IF(NRES.GT.0) THEN
        WRITE(NRES,FMT='(/25X,''--- SETTING ERRORS ---'',/)') 
        WRITE(NRES,FMT='(/15X,''On/off, number of sets, seed, start '',
     >  ''of the series :'',2I4,I8,1P,E12.4)') IOP, NBR, ISEED,RNDM() 
        WRITE(NRES,FMT='(/15X,''ERRORS TO BE INTRODUCED : '')')
        DO IRR = 1, NBR
          WRITE(NRES,FMT='(20X,A)')
     >    TA(NOEL,IRR)(DEBSTR(TA(NOEL,IRR)):FINSTR(TA(NOEL,IRR)))
        ENDDO
      ENDIF

      IF(NBR.GT.MXTA) CALL ENDJOB('SBR RERROR. NUMBER OF INSTRUCTIONS '
     >//' CANNOT EXCEED ',MXTA)

C EXAMPLE OF AN ERROR ASSIGNMENT LINE : 
C          MULTIPOL{lbl1,lbl2} 1, XR, R, G, center, sigma, cut
C {lbl1,lbl2} is optional, can be {,lbl2}, {lbl1}  
C 1 is the  pole # (dipole). can be 1-10 for dipole-20_pole
C XR is roll. Other possibilities : YR, ZR, XS, YS, ZS, BP (B_pole)
C R is for relative, A for absolute
C G for gaussian, U for uniform
C Case U : "sigma" stands for half-width
C cut is in units of sigma
      DO IRR = 1, NBR
        Txt132 = TA(NOEL,IRR)(debstr(TA(NOEL,IRR)):finstr(TA(NOEL,IRR)))
C         Get possible label1 and/or label2
        ok = strcon(txt132,'{',
     >                         is)
        if(ok) then 
          READ(txt132(1:is-1),*) klerr
        else
          READ(txt132,*) klerr
        endif
        if(klerr.eq.'MULTIPOL') then
          txt132 = txt132(9:finstr(txt132))
          if(ok) then 
            ok = strcon(txt132,'{',
     >                             is)
            ok = strcon(txt132,'}',
     >                             is2)
            ok = strcon(txt132(is:is2),',',
     >                                     is3)
            if(is+1.lt.is2-1) then
              if(.not. empty(txt132(is+1:is2-1))) 
     >             read(txt132(is+1:is2-1),*) lbl1
            endif
            if(ok) then
              if(.not. empty(txt132(is3+1:is2-1))) 
     >          read(txt132(2:is2+1),*) lbl2
            endif
            txt132 = txt132(is2+1:finstr(txt132))
          endif
C          Get the rest of the arguments
          txt132 = txt132(debstr(txt132):finstr(txt132))
          CALL STRGET(TXT132,99,
     >                          NSTR,STRA)
C          write(*,fmt='(20a)') ' sbr errors ',(stra(ii),ii=1,nstr)

          READ(STRA(1),*) IPOL     ! Pole to which the error applies (1-10)
          READ(STRA(2),*) TYPERR   ! Error type : BP (B_pole), XR,YR,ZR,XS,YS.ZS
          READ(STRA(3),*) TYPAR    ! Relative or absolute : R, A
          READ(STRA(4),*) TYPDIS   ! Type of density : G or U,  or 0 to switch off ERRORS
          IF(TYPDIS.EQ.'0') THEN
            CALL MULTP4
          ELSE
            READ(STRA(5),*) ERRCEN
            READ(STRA(6),*) ERRSIG   ! sigma for G, half-width for U
            read(stra(7),*) errcut   ! in units of errsig for G, unused for U
            call MULTP2(irr,ipol,typerr,typar,typdis,
     >                      errcen,errsig,errcut,lbl1,lbl2)          
          endif
        endif
      ENDDO

      RETURN
      END
