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
      PARAMETER (I4=4)
      CHARACTER(20) STRA(I4)
      PARAMETER (MXPRM=1000)
      DIMENSION PARAM(MXPRM)
      CHARACTER(30) STRING
      LOGICAL OKKLE

      READ(NDAT,FMT='(A)') TXT300
      IF(STRCON(TXT300,'!',
     >                     II))
     >  TXT300 = TXT300(DEBSTR(TXT300):II-1)
      CALL STRGET(TXT300,I4,
     >                      NSR,STRA)
      IF(NSR.GT.I4) CALL ENDJOB('SBR RREBEL. TOO LARGE VALUE NSR=',NSR)
      READ(STRA(1),*,ERR=98) A(NOEL,1)
      NRBLT = NINT(A(NOEL,1))
      READ(STRA(2),*,ERR=98) A(NOEL,2)
      READ(STRA(3),*,ERR=98) A(NOEL,3)
      IA3 = NINT(A(NOEL,3))

      IF(STRCON(STRA(3),'.',
     >                      II)) THEN
        READ(STRA(3)(II+1:FINSTR(STRA(3))),*,ERR=98,END=98) IOP
      ENDIF

      IF(IOP .NE. 1 .AND. IOP .NE. 2) THEN
        IF(NSR .EQ. I4) THEN
          READ(STRA(4),*,ERR=77) IA4
          GOTO 78
 77       IA4 = 0
 78       CONTINUE
        ENDIF
      ELSE
        IA4 = 0
      ENDIF
      A(NOEL,4) = IA4

      IF    (IA4 .EQ. 1) THEN
C WILL 'REBELOTE' USING NEW VALUE FOR PARAMETER #KPRM IN ELEMENT #KLM. 
        READ(NDAT,*) NPRM
        A(NOEL,10) = NPRM
        READ(NDAT,FMT='(A)') TXT300
        IF(STRCON(TXT300,'!',
     >                        II))
     >    TXT300 = TXT300(DEBSTR(TXT300):FINSTR(TXT300))
        READ(TXT300,*) STRING
        IEL = 1
        OKKLE = .FALSE.
        DO WHILE(.NOT. OKKLE .AND. IEL .LE. NOEL)
          IF(STRING(DEBSTR(STRING):FINSTR(STRING)) .EQ. 
     >       KLE(IQ(IEL))(DEBSTR(KLE(IQ(IEL))):FINSTR(KLE(IQ(IEL))))) 
     >                                            OKKLE = .TRUE.
          IEL = IEL + 1
        ENDDO
C Two ways to define the element with parameter to be changed : either its keyword, or its number in the sequence 
        IF(OKKLE) THEN
          KLM = IEL - 1
C Keyword with parameter to be changed
          TA(NOEL,1) = STRING(DEBSTR(STRING):FINSTR(STRING))
          backspace(ndat)
          READ(ndat,*,ERR=79,END=79) STRING,KPRM,(PARAM(I),I=1,NRBLT)
          TA(NOEL,2) = ' '
          TA(NOEL,3) = ' '
        ELSE
          TA(NOEL,1) = ' '
          TA(NOEL,2) = ' '
          TA(NOEL,3) = ' '
          backspace(ndat)
          READ(ndat,*,ERR=79,END=79) KLM,KPRM,(PARAM(I),I=1,NRBLT)
        ENDIF
        
        goto 80

 79     CONTINUE
        WRITE(6,*)
     >  'SBR RREBEL. Stopped while reading list of parameter values.'
        CALL ENDJOB('Have NRBLT .le. number of parameter values.',-99)
 80     continue

        A(NOEL,20) = KLM
        A(NOEL,21) = KPRM
        IF(NRBLT .GT. MXPRM) 
     >    CALL ENDJOB('SBR RREBEL. TOO MANY DATA, # MUST BE .LE. NRBLT='
     >    ,NRBLT)
        CALL REBEL4(PARAM)
        NOELA = 1
        NOELB = NOEL
      ENDIF

      IF(STRCON(STRA(3),'.',
     >                      II)) THEN
        READ(STRA(3)(II+1:FINSTR(STRA(3))),*,ERR=98,END=98) IOP
        IF(IOP .GE. 1) THEN
          IF(IOP .EQ. 1) THEN
C GET LABEL, DEDUCE RELATED NOEL : MULTI-PASS TRACKING WILL LOOP OVER NOEL-REBELOTE   
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
C GET 2 LABELS, DEDUCE RELATED NOELS : MULTI-PASS TRACKING WILL LOOP OVER NOEL1-NOEL2
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
            CALL ENDJOB(' SBR RREBEL, NO SUCH OPTION IOP=',IOP)
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
      CALL ENDJOB(' SBR RREBEL, WRONG INPUT DATA / ELEMENT #',-99)
      RETURN

      END
