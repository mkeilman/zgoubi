      implicit double precision (a-h,o-z)

C      parameter (lunR=11,lunW=12,lunDat=15,lunDa2=17,luntmp=14)
      character txt300*300, txt300c*300, let*1, txt4*4, txt4a*4, let1*1
      parameter (nCOmx=10001)
      dimension x(nCOmx),xp(nCOmx),z(nCOmx),
     >                   zp(nCOmx),s(nCOmx),d(nCOmx),let(nCOmx)
      character txtksy(10)*150, txt150*150
      character cmmnd*110
      character drctry*15, zgDatFile*50

      logical strcon, idluni

      character(30) tilde
      parameter (tilde = '/home/owl/fmeot/')
      character(300) exec, cmndZ, searchCO, searchCh
      parameter (exec = '/zgoubi/SVN/current/zgoubi/zgoubi')
      parameter 
     >  (searchCO='zgoubi/SVN/current/toolbox/searchCO/')
      parameter 
     >(searchCh='zgoubi/SVN/current/toolbox/searchChroma/')

      INTEGER DEBSTR,FINSTR
      character typ2*12
      parameter(pi=3.14159265359,c=2.99792458d8, deg2rd=pi/180.d0)
      parameter(zero=0.d0)

      data typ2 / 'intrinsic' /
      data am, q, G / 938.27203d6,1.602176487d-19,1.7928474d0 /
      data x0, xp0, y0, yp0, s0, dpp0 / 0.d0,0.d0,0.d0,0.d0,0.d0,0.d0 /
      data nTrj, ddp, Dx, Dxp / 5, 2.d-4, 0.d0, 0.d0 /
     
C  geneZGDat4Chrom.In is a copy of calcStrength.out 
      if (idluni(lunDa2)) then
        open(unit=lunDa2,file='geneZGDat4Chrom.In',err=25)
      endif
      read(lunDa2,*,end=20,err=20) x0, xp0, y0, yp0, s0, dpp0
      read(lunDa2,*,end=20,err=20) nTrj, ddp, Dx, Dxp

      write(*,*) ' Read from geneZGDat4Chrom.In, '
      goto 25

 20   continue
      rewind(lunDa2)
      write(lunDa2,*) x0, xp0, y0, yp0, s0, dpp0,
     > '  x0, xp0, y0, yp0, s0, dpp0'
      write(lunDa2,*) nTrj, ddp, Dx, Dxp,'  nTrj, ddp, Dx, Dxp'
      
 25   continue
      write(*,*) 'Reference trajectory : ',x0, xp0, y0, yp0, s0, dpp0
      write(*,*) '# trajectories,  d(dp/p), Dx, Dx'' : '
     >      ,nTrj, ddp, Dx, Dxp

      close(lunDa2)

      if(nTrj.lt.3) stop 'Need nTrj=3 at least, geneZGDat4Chrom.In'
     
C Now build zgoubi.dat from zgoubi_geneZGDat4Chrom-In.dat
      if (idluni(lunR)) then
        open(unit=lunR,file='zgoubi_geneZGDat4Chrom-In.dat'
     >                ,status='old',err=95)
        rewind(lunR)
      endif
      if (idluni(lunW)) then
        open(unit=lunW,file='zgoubi_searchCO-In.dat')
        rewind(lunW)
      endif

C Read in zgoubi_geneZGDat4Chrom-In.dat
C Read till BORO
        txt300 = ' '
        dowhile(
     >  .not. strcon(txt300(debstr(txt300):finstr(txt300)),'''OBJET''',
     >  7,IS)
     >  .and. 
     >  .not.strcon(txt300(debstr(txt300):finstr(txt300)),'''MCOBJET''',
     >  9,IS))
          read(lunR,fmt='(a)') txt300
          if(strcon(txt300(debstr(txt300):finstr(txt300)),'''MCOBJET''',
     >      9,IS)) then 
            write(lunW,fmt='(a)') '''OBJET'''
          else
            write(lunW,fmt='(a)') txt300(debstr(txt300):finstr(txt300))
          endif
        enddo 
          read(lunR,fmt='(a)') txt300     ! BORO
          write(lunW,*) txt300(debstr(txt300):finstr(txt300))
C Remove all the rest of objet
 2    continue
        read(lunR,fmt='(a)') txt300       
        if(txt300(debstr(txt300):debstr(txt300)).ne.'''') goto 2
        backspace(lunR)

C Create KOBJ=2 type of object --------------------
      write(lunW,*) '2'
      write(lunW,*) nTrj, '   1'
      k10 = nTrj/10
      kk = nTrj - 10*k10
      iTrj = -dble((nTrj-1)/2)
 3    continue
      dpp = dpp0 + dble(iTrj)*ddp
      write(lunW,fmt='(1p,4(1x,e14.6),a,1e14.6,3x,a3)') 
     > x0+Dx*dpp,xp0+Dx*dpp,y0,yp0,' 0. ',1.d0+dpp,'''a'''
      iTrj = iTrj + 1
      if(iTrj.le.dble((nTrj-1)/2)) goto 3     
      txt300 = '1 1 1 1 1 1 1 1 1 1 '
      do ii = 1, k10
        write(lunW,*) txt300(debstr(txt300):finstr(txt300))   
      enddo
      if(kk.ne.0) write(lunW,*) txt300(debstr(txt300):finstr(txt300))   
C--------------------------------------------------
C Place pick-ups here, used by searchCO
      txt300 = '''PICKUPS'''
      write(lunW,*) txt300(debstr(txt300):finstr(txt300))   
      txt300 = '   1        '
      write(lunW,*) txt300(debstr(txt300):finstr(txt300))   
      txt300 = '   #Start '
      write(lunW,*) txt300(debstr(txt300):finstr(txt300))   
      txt300 = '''MARKER''   #Start '
      write(lunW,*) txt300(debstr(txt300):finstr(txt300))

C Complete zgoubi.dat from content of zgoubi_geneZGDat4Chrom-In.dat
 1      continue
          read(lunR,fmt='(a)',end=13) txt300
          txt300 = txt300(debstr(txt300):132)

          if(strcon(txt300,'''FAISCEAU''',10,
     >                                           IS)) then 

          elseif(strcon(txt300,'''SPNTRK''',8,
     >                                       IS)) then 
            read(lunR,fmt='(a)') txt300
            read(lunR,fmt='(a)') txt300
            if(txt300(debstr(txt300):debstr(txt300)) .eq. '''') 
     >        write(lunW,*) txt300(debstr(txt300):finstr(txt300))

          elseif(strcon(txt300,'''PICKUPS''',9,
     >                                       IS)) then 
            read(lunR,fmt='(a)') txt300
            read(lunR,fmt='(a)') txt300

          elseif(strcon(txt300,'''SPNSTORE''',10,
     >                                       IS)) then 
            read(lunR,fmt='(a)') txt300
            read(lunR,fmt='(a)') txt300

          elseif(strcon(txt300,'''FAISTORE''',10,
     >                                       IS)) then 
            read(lunR,fmt='(a)') txt300
            read(lunR,fmt='(a)') txt300

          elseif(strcon(txt300,'''FAISCNL''',9,
     >                                       IS)) then 
            read(lunR,fmt='(a)') txt300

          elseif(strcon(txt300,'''SPNPRNL''',9,
     >                                       IS)) then 
            read(lunR,fmt='(a)') txt300

          elseif(strcon(txt300,'''MARKER''',8,
     >                                        IS)) then 
            txt300c = txt300(IS+8:132-8)
            txt300c = txt300c(debstr(txt300c):debstr(txt300c)+6)
            if(txt300c.eq.'#Start') then
            elseif(txt300c.eq.'#End') then
            else              
              write(lunW,*) txt300(debstr(txt300):finstr(txt300))
            endif

          elseif(strcon(txt300,'''CAVITE''',8,
     >                                        IS)) then
              write(lunW,*) txt300(debstr(txt300):finstr(txt300))
              read(lunR,fmt='(a)',end=13) txt300
              write(lunW,*) ' 0 '//txt300(debstr(txt300):finstr(txt300))
              read(lunR,fmt='(a)',end=13) txt300
              write(lunW,*) txt300(debstr(txt300):finstr(txt300))
              read(lunR,fmt='(a)',end=13) txt300
              write(lunW,*) txt300(debstr(txt300):finstr(txt300))

          elseif(strcon(txt300,'''REBELOTE''',10,
     >                                         IS)) then
            goto 11

          elseif(strcon(txt300,'''TWISS''',7,
     >                                         IS)) then
            read(lunR,fmt='(a)',end=13) txt300

          elseif(strcon(txt300,'''FIT''',5,
     >                                       IS)
     >      .or. strcon(txt300,'''FIT2''',6,
     >                                       IS)) then
            read(lunR,*,end=13) IV
            do ii = 1, iv
              read(lunR,fmt='(a)',end=13) txt300
            enddo
            read(lunR,*,end=13) IC
            do ii = 1, ic
              read(lunR,fmt='(a)',end=13) txt300
            enddo

          elseif(strcon(txt300,'''END''',5,
     >                                       IS)) then
            goto 11

          else            
              write(lunW,*) txt300(debstr(txt300):finstr(txt300))

          endif

        goto 1

 11     continue
              txt300 = '''MARKER''   #End'
              write(lunW,*) txt300(debstr(txt300):finstr(txt300))
              txt300 = '''REBELOTE'''
              write(lunW,*) txt300(debstr(txt300):finstr(txt300))
              txt300 = '99  0.2  99'
              write(lunW,*) txt300(debstr(txt300):finstr(txt300))
              txt300 = '''END'''
              write(lunW,*) txt300(debstr(txt300):finstr(txt300)) 

 13   continue
      write(*,*) ' '
      write(*,*) ' End of zgoubi_geneZGDat4Chrom-In.dat input file has'
     >,' been reached, file  zgoubi_searchCO-In.dat  completed.'
      write(*,*) ' ------------'
      write(*,*) ' '
      close(lunR)
      close(lunW)

C Get closed orbits
      if (idluni(lunR)) then
        open(unit=lunR,file='searchCO.In',status='old',err=26)
      endif
      read(lunR,*,err=26,end=26) kaseV
      read(lunR,*,err=26,end=26) precX, precXp 
      close(lunR)
      goto 27
 26   continue
      kaseV = 2
      precX = .001d0 
      precXp = .01d0 
 27   continue
      cmmnd = tilde(debstr(tilde):finstr(tilde))//
     >searchCO(debstr(searchCO):finstr(searchCO))//'searchCO'
      write(*,*) '---------------------------------------'
      write(*,*) cmmnd
      call system(cmmnd)

CC Run MATRIX tracking to get alpha and eta from orbit length and TOF using "tunesFromMatrix"
C      cmmnd = 'cp zgoubi_searchCO-Out_MATRIX.dat zgoubi.dat'
C      write(*,*) '---------------------------------------'
C      write(*,*) cmmnd
C      call system(cmmnd)
C      cmmnd = tilde(debstr(tilde):finstr(tilde))//'/zgoubi/SVN/current/zgoubi/zgoubi'
C      write(*,*) '---------------------------------------'
C      write(*,*) cmmnd
C      call system(cmmnd)
C      cmmnd = tilde(debstr(tilde):finstr(tilde))//'/zgoubi/SVN/current/toolbox/tunesFromMatrix/tunesFromMatrix'
C      write(*,*) '---------------------------------------'
C      write(*,*) cmmnd
C      call system(cmmnd)

cC Run multiturn tracking and compute tunes
c      cmmnd = 'cp zgoubi_searchCO-Out_TrkFourier.dat zgoubi.dat'
c      write(*,*) '---------------------------------------'
c      write(*,*) cmmnd
c      call system(cmmnd)
c      cmmnd = tilde(debstr(tilde):finstr(tilde))//'/zgoubi/SVN/current/zgoubi/zgoubi'
c      write(*,*) '---------------------------------------'
c      write(*,*) cmmnd
c      call system(cmmnd)
c      cmmnd = tilde(debstr(tilde):finstr(tilde))//'/zgoubi/SVN/current/toolbox/tunesFromFai/tunesFromFai'
c      write(*,*) '---------------------------------------'
c      write(*,*) cmmnd
c      call system(cmmnd)

C Create gnuplots from tracking results
      cmmnd = tilde(debstr(tilde):finstr(tilde))
     >//searchCh(debstr(searchCh):finstr(searchCh))
     >//'geneGnuPlots'
      write(*,*) '---------------------------------------'
      write(*,*) cmmnd
      call system(cmmnd)

C Write a log_Chroma.tex file containing the plots above and create log_Chroma.pdf
      cmmnd = tilde(debstr(tilde):finstr(tilde))
     >//searchCh(debstr(searchCh):finstr(searchCh))
     >//'geneTexLog'
      write(*,*) '---------------------------------------'
      write(*,*) cmmnd
      call system(cmmnd)

C Save a copy zgoubi_geneZGDat4Chrom-In.dat in ./Log'
      cmmnd = 'cp zgoubi_geneZGDat4Chrom-In.dat ./Log'
      write(*,*) '---------------------------------------'
      write(*,*) cmmnd
      call system(cmmnd)

C View log_Chroma.pdf
      cmmnd = 'okular ./Log_Chroma/log_Chroma.pdf'
      write(*,*) '---------------------------------------'
      write(*,*) cmmnd
      call system(cmmnd)

      stop

 95   write(*,*) 'Please supply zgoubi_geneZGDat4Chrom-In.dat '
      stop

 96   write(*,*) 'Please supply searchCO.In '
      stop
      end
      FUNCTION STRCON(STR,STRIN,NCHAR,
     >                                IS)
      implicit double precision (a-h,o-z)
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
      FUNCTION DEBSTR(STR)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INTEGER DEBSTR
      CHARACTER * (*) STR
C     -----------------------------------
C     Renvoie dans DEBSTR le rang du
C     premier caractere non-blanc de STR.
C     -----------------------------------
      DEBSTR=0
      LENGTH=LEN(STR)+1
1     CONTINUE
         DEBSTR=DEBSTR+1
         IF(DEBSTR.GE. LENGTH) RETURN
         IF (STR(DEBSTR:DEBSTR).EQ. ' ') GOTO 1
      RETURN
      END
      FUNCTION FINSTR(STRING)
      implicit double precision (a-h,o-z)
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
      subroutine readat(lunDat,
     >                   typ2,rJn2,circ,ah,gtr,Vp,phisD,am,q,G,ierr)
      implicit double precision (a-h,o-z)
      character typ2*(*)
      ierr = 0
      read(lunDat,fmt='(a)',err=99,end=98) typ2
      read(lunDat,*,err=99,end=98) rJn2
      read(lunDat,*,err=99,end=98) circ, ah
      read(lunDat,*,err=99,end=98) gtr
      read(lunDat,*,err=99,end=98) Vp, phisD
      read(lunDat,*,err=99,end=98) am, q, G
      return
 99   continue
      ierr = 1
      write(*,*) ' error during read in data file'
      return
 98   continue
      write(*,*) ' End of data file reached'
      return
      end
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
