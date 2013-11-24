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
C  Upton, NY, 11973, USA
C  -------
      SUBROUTINE RREBEL(LABEL,kle)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C     ***************************************
C     READS DATA FOR FIT PROCEDURE WITH 'FIT'
C     ***************************************
      CHARACTER(*) KLE(*)
      INCLUDE 'MXLD.H'
      CHARACTER(*) LABEL(MXL,2)
      COMMON/CDF/ IES,LF,LST,NDAT,NRES,NPLT,NFAI,NMAP,NSPN,NLOG
      COMMON/DON/ A(MXL,MXD),IQ(MXL),IP(MXL),NB,NOEL
      CHARACTER(80) TA
      PARAMETER (MXTA=45)
      COMMON/DONT/ TA(MXL,MXTA)

      CHARACTER TXT300*300, TXTA*8, TXTB*8
      INTEGER DEBSTR, FINSTR
      LOGICAL STRCON
      CHARACTER(80) STRA(3)
      DIMENSION PARAM(mxd)
      character(30) string
      logical okkle

      READ(NDAT,FMT='(A)') TXT300
      TXT300 = TXT300(DEBSTR(TXT300):FINSTR(TXT300))
      I4 = 4
      CALL STRGET(TXT300,I4,
     >                      NSR,STRA)

      READ(STRA(1),*,ERR=98) A(NOEL,1)
      nrblt = nint(A(NOEL,1))
      READ(STRA(2),*,ERR=98) A(NOEL,2)
      READ(STRA(3),*,ERR=98) A(NOEL,3)
      IA3 = NINT(A(NOEL,3))
C      A(NOEL,3) = IA3

      IF(STRCON(STRA(3),'.',
     >                      II)) THEN
        READ(STRA(3)(II+1:FINSTR(STRA(3))),*,ERR=98,END=98) IOP
      ENDIF

      IF(iop .ne. 1 .and. iop .ne. 2) then
        if(nsr .ge. 4) then
          READ(STRA(4),*,ERR=77) IA4
          goto 78
 77       ia4 = 0
 78       continue
        endif
      else
        ia4 = 0
      endif
      a(noel,4) = ia4

      IF    (IA4 .EQ. 1) THEN
C Will 'rebelote' (given A(NOEL,3)=99) using new value for parameter #KPRM in element #KLM
        READ(NDAT,FMT='(A)') TXT300
        TXT300 = TXT300(DEBSTR(TXT300):FINSTR(TXT300))
        READ(txt300,*) string
        okkle = .false.
        iel = 1
        okkle = .false.
        do while(.not. okkle .and. iel .le. noel)
          if(string(debstr(string):finstr(string)) .eq. 
     >       kle(iq(iel))(debstr(kle(iq(iel))):finstr(kle(iq(iel))))) 
     >                                            okkle = .true.
C            write(*,*) ' '
C            write(*,*) ' rrebel ',iel,okkle, kle(iel), string
          iel = iel + 1
        enddo
        if(okkle) then
          klm = iel - 1
          ta(noel,1) = string(debstr(string):finstr(string))
          READ(txt300,*) string,kprm,(param(i),i=1,nrblt)
          ta(noel,2) = ' '
          ta(noel,3) = ' '
        else
          ta(noel,1) = ' '
          ta(noel,2) = ' '
          ta(noel,3) = ' '
          READ(txt300,*) klm,kprm,(param(i),i=1,nrblt)
        endif

        a(noel,10) = klm
        a(noel,11) = kprm
        do i = 1, nrblt
          J = 20 + 20*((I-1)/20)
          if(J +I -1 .gt. mxd) 
     >      call endjob('SBR rrebel. Too many data, # must be .le. MXD='
     >      ,mxd)
          A(NOEL,J +I -1) = PARAM(I) 
C          write(*,*) ' rrebel ', J +I -1, A(NOEL,J +I -1)
        enddo   
C             read(*,*)
        NOELA = 1
        NOELB = NOEL
      ENDIF

      IF(STRCON(STRA(3),'.',
     >                      II)) THEN
        READ(STRA(3)(II+1:FINSTR(STRA(3))),*,ERR=98,END=98) IOP
        IF(IOP .GE. 1) THEN
          IF(IOP .EQ. 1) THEN
C Get Label, deduce related NOEL : multi-pass tracking will loop over NOEL-REBELOTE   
            READ(TXT300,*) DUM,DUM,DUM,TXTA
            DO JJ = 1, NOEL
              IF(LABEL(JJ,1).EQ.TXTA) THEN
                NOELA = JJ
                GOTO 12
              ENDIF
            ENDDO           
            NOELA = 1
 12         CONTINUE
            NOELB = NOEL
          ELSEIF(IOP .EQ. 2) THEN
C Get 2 Labels, deduce related NOELs : multi-pass tracking will loop over NOEL1-NOEL2
            READ(TXT300,*) DUM,DUM,DUM,TXTA,TXTB
            DO JJ = 1, NOEL
              IF(LABEL(JJ,1).EQ.TXTA) THEN
                NOELA = JJ
                GOTO 11
              ENDIF
            ENDDO           
            NOELA = 1
 11         CONTINUE
            DO JJ = 1, NOEL
              IF(LABEL(JJ,1).EQ.TXTB) THEN
                NOELB = JJ
                GOTO 10
              ENDIF
            ENDDO           
            NOELB = NOEL
 10         CONTINUE
          ELSE
            CALL ENDJOB(' SBR RREBEL, no such option IOP=',IOP)
          ENDIF
        ELSE
          NOELA = 1
          NOELB = NOEL
        ENDIF
      ELSE
        NOELA = 1
        NOELB = NOEL
      ENDIF

      CALL REBEL6(NOELA, NOELB)

      RETURN

 98   CONTINUE
      CALL ENDJOB(' SBR RREBEL, wrong input data / element #',-99)
      RETURN

      END
