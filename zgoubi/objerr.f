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
C  Fran�ois M�ot <meot@lpsc.in2p3.fr>
C  Service Acc�lerateurs
C  LPSC Grenoble
C  53 Avenue des Martyrs
C  38026 Grenoble Cedex
C  France
      SUBROUTINE OBJERR(NRES,IER,MXT,TXT)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      CHARACTER*(*) TXT
      WRITE(   *,*)
      WRITE(   *,*) ' *** ERROR in object definition : '
      WRITE(NRES,*) ' *** ERROR in object definition : '
      WRITE(   *,*) TXT
      WRITE(NRES,*) TXT
      IF(IER .EQ. 1) THEN
        WRITE(   *,*) '   Only  non-zero  dp/p  allowed...'
        WRITE(NRES,*) '   Only  non-zero  dp/p  allowed...'
      ELSEIF(IER .EQ. 2) THEN
        WRITE(6,*) '          MAX # OF PARTICLES IS ',MXT
        CALL REBELR(KREB3,KREB31)
        IF(KREB31 .NE. 0) THEN
          WRITE(6,*) '  CHECK APPROPRIATE USE OF ''REBELOTE'''
          WRITE(NRES,*) '          MAX  # OF PARTICLES IS ',MXT
          WRITE(NRES,*) '  CHECK APPROPRIATE USE OF ''REBELOTE'''
        ELSE
          WRITE(6,*) '  MAY WE SUGGEST THE USE OF ''REBELOTE'''
          WRITE(NRES,*) '          MAX  # OF PARTICLES IS ',MXT
          WRITE(NRES,*) '  MAY WE SUGGEST THE USE OF ''REBELOTE'''
        ENDIF
      ENDIF
      RETURN
      END