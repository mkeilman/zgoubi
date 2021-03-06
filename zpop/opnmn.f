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
      SUBROUTINE OPNMN(IOPT,
     >                      NL,OKOPN,CHANGE,NOMFIC)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      CHARACTER(*) NOMFIC
      LOGICAL OKOPN, CHANGE

      COMMON/LUN/NDAT,NRES,NPLT,NFAI,NMAP,NSPN

      DIMENSION NF(6)
      CHARACTER  NDNAM*4
      INTEGER DEBSTR,FINSTR
      LOGICAL BINARY,EMPTY

      CHARACTER(80) OTHER
      SAVE OTHER, KTYP
     
      INCLUDE 'FILSPN.H'
      INCLUDE 'FILPLT.H'
      INCLUDE 'FILFAI.H'

      CHARACTER*20 FILPL2, FILFA2, FILSP2, NAMFIC

      CHARACTER(11) FRMT

      PARAMETER (I4=4)

      DATA OTHER, KTYP/ '...',2 /

      NF(1)=NPLT
      NF(2)=NFAI
      NF(3)=NSPN
      NF(4)=NPLT
      NF(5)=NFAI
      NF(6)=NSPN

        NAMFIC = FILFAI
        NAMFIC = NAMFIC(DEBSTR(NAMFIC):FINSTR(NAMFIC))
        BINARY=NAMFIC(1:2).EQ.'B_' .OR. NAMFIC(1:2).EQ.'b_'
        IF(BINARY) THEN 
          NAMFIC=NAMFIC(DEBSTR(NAMFIC)+2 :FINSTR(NAMFIC))
        ELSE
          NAMFIC='b_'//NAMFIC(DEBSTR(NAMFIC):FINSTR(NAMFIC))
        ENDIF
        FILFA2 = NAMFIC
        NAMFIC = FILPLT
        NAMFIC = NAMFIC(DEBSTR(NAMFIC):FINSTR(NAMFIC))
        BINARY=NAMFIC(1:2).EQ.'B_' .OR. NAMFIC(1:2).EQ.'b_'
        IF(BINARY) THEN 
          NAMFIC=NAMFIC(DEBSTR(NAMFIC)+2 :FINSTR(NAMFIC))
        ELSE
          NAMFIC='b_'//NAMFIC(DEBSTR(NAMFIC):FINSTR(NAMFIC))
        ENDIF
        FILPL2 = NAMFIC
        NAMFIC = FILSPN
        NAMFIC = NAMFIC(DEBSTR(NAMFIC):FINSTR(NAMFIC))
        BINARY=NAMFIC(1:2).EQ.'B_' .OR. NAMFIC(1:2).EQ.'b_'
        IF(BINARY) THEN 
          NAMFIC=NAMFIC(DEBSTR(NAMFIC)+2 :FINSTR(NAMFIC))
        ELSE
          NAMFIC='b_'//NAMFIC(DEBSTR(NAMFIC):FINSTR(NAMFIC))
        ENDIF
        FILSP2 = NAMFIC

      IF(IOPT.GE.1 .AND. IOPT.LE.6) THEN
        GOTO 10
      ELSEIF(IOPT.EQ.8) THEN
        OTHER=NOMFIC          
        GOTO 51
      ENDIF

 21   CONTINUE
      CALL HOMCLR

      WRITE(6,100) FILPLT, FILFAI, FILSPN, FILPL2, FILFA2, FILSP2, OTHER
 100  FORMAT(//,3X,60('*'),//,20X,' FILE  TO  OPEN:' ,//
     > /,8X,' 1: ',A,                     
     > /,8X,' 2: ',A,                    
     > /,8X,' 3: ',A,                    
     > /,8X,' 4: ',A,                     
     > /,8X,' 5: ',A,                    
     > /,8X,' 6: ',A,                    
     > /,8X,' 7: ',A,
     > /,8X,' 8: other...',                     
     > /,8X,' 9: EXIT',
     > /,3X,60('*'),/)
    
      WRITE(6,101) ' * Option  number : '
 101  FORMAT(A)
      READ(5,201,ERR=21) IOPT
 201  FORMAT(I2)

 10   CONTINUE
      IF(IOPT.EQ. 9) RETURN
      IF(IOPT.LT. 1 .OR. IOPT.GT. 9) GOTO 21

        IF(OKOPN) THEN
          CLOSE(NL)
          OKOPN = .FALSE.        
        ENDIF
        CHANGE=.TRUE.

        GOTO (1,2,3,4,5,6,7,8) IOPT

 1      CONTINUE
          KTYP = IOPT
          NOMFIC=FILPLT
        GOTO 40

 2      CONTINUE
          KTYP = IOPT
          NOMFIC=FILFAI
        GOTO 40

 3      CONTINUE
          KTYP = IOPT
          NOMFIC=FILSPN
        GOTO 40

 4      CONTINUE
          KTYP = IOPT
          NOMFIC=FILPL2
        GOTO 40

 5      CONTINUE
          KTYP = IOPT
          NOMFIC=FILFA2
        GOTO 40

 6      CONTINUE
          KTYP = IOPT
          NOMFIC=FILSP2
        GOTO 40

 7      CONTINUE
          NOMFIC=OTHER
          IOPT=KTYP
        GOTO 40

 8      CONTINUE
          WRITE(*,102) 
 102      FORMAT(/,'   NAME  OF  FILE  TO  OPEN:' ,/)
          READ(5,FMT='(A)',ERR=5) OTHER        
 51       IF(EMPTY(OTHER)) GOTO 5
          OTHER = OTHER(DEBSTR(OTHER):FINSTR(OTHER))

          NDNAM = OTHER(FINSTR(OTHER)-3:FINSTR(OTHER))
          IF    (NDNAM .EQ. '.plt' .OR. NDNAM .EQ. '.PLT') THEN
            IOPT = 1
          ELSEIF(NDNAM .EQ. '.fai' .OR. NDNAM .EQ. '.FAI') THEN
            IOPT = 2
          ELSEIF(NDNAM .EQ. '.spn' .OR. NDNAM .EQ. '.SPN') THEN
            IOPT = 3
          ELSE
 32         CONTINUE
            WRITE(6,103) ' Name of file misses suffix : ',OTHER
 103        FORMAT(/,2A,/,' Please  give  file  type :' ,//
     >      , /,8X,' 1: .plt '                     
     >      , /,8X,' 2: .fai '                     
     >      , /,8X,' 3: .spn ',/)
            READ(5,201,ERR=32) IOPT
            IF(IOPT.LT. 1 .OR. IOPT.GT. 3) GOTO 32
          ENDIF
          NOMFIC=OTHER
          KTYP=IOPT

 40     CONTINUE
        BINARY=NOMFIC(1:2).EQ.'B_' .OR. NOMFIC(1:2).EQ.'b_'
        CALL READC8(BINARY)
        IF(BINARY) THEN 
          FRMT='UNFORMATTED'
        ELSE
          FRMT='FORMATTED'
        ENDIF
        NL=NF(KTYP)
        CLOSE(NL)
        OPEN(UNIT=NL, FILE=NOMFIC,STATUS='OLD',FORM=FRMT,ERR=98)
        WRITE(6,FMT='(/,4A)') ' OK, opened ',FRMT,' file  ',NOMFIC
        OKOPN = .TRUE.
        CALL REWIN2(NL,*49)
 49   RETURN

 98   WRITE(6,FMT='(/,2A)') ' Could  not  OPEN  file  ',NOMFIC
      OKOPN = .FALSE.
      NOMFIC = 'none'
      RETURN

      RETURN
      END
