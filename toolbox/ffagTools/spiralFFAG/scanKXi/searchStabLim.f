C Starting from initial coordinates near closed orbits, as read from input file 
C zgoubi_StabLim-In.dat (e.g., a copy of zgoubi_geneMap-Out.dat or zgoubi_searchCO-Out.dat), 
C will search stability limits. 
C zgoubi.dat is presumed to contain stable trajectories, which will be pushed to 
C extreme amplitude
      parameter (lunR=11,lunW=12,lunIn=15)
      character txt132*132, txt6*6, let*1, namFil*30
      parameter (nTrajmx=99)
      dimension x(nTrajmx),xp(nTrajmx),z(nTrajmx),
     >                   zp(nTrajmx),s(nTrajmx),d(nTrajmx),let(nTrajmx)
      dimension storb(6,nTrajmx)
      logical ok, result, strcon, first
      character*2 HV, HVIn
      logical okFAI, okREB
      data okFAI / .true. /
C H=pure H, Hz=H+small z, V=vertical 
      data HV / 'Hz' /
      data lunData / 7 /
C      prec : cm
      data prec / 1.e-1 /
      data ok, first, okREB / .false., .true., .false. /

      call system('mv -f searchStabLim-tunes.out 
     >                    searchStabLim-tunes.out_old')
      open(unit=8,file='searchStabLim-tunes.out')
      write(8,*) ' XXNU,ZZNU, (U(I),I=1,3),COOR(KT,6),KT,NPTS,K,xi,HV'
      close(8)

      open(unit=lunData,file='searchStabLim.data')

 111  continue

C---------- Input data ------------------
      read(lunData,*,err=999,end=998) HVIn, precIn,nTurn,kTrkIn
c      close(lunData)
      HV = HVIn
      prec = precIn
      kTrk = kTrkIn
 66   continue
      write(6,*) '  H/V, precision (cm)  : ',HV, prec
C----------------------------------------

      result = .false.

      call system('mv -f zgoubi.dat zgoubi.dat-copy')
c      call system('rm -f zgoubi.dat')

C zgoubi_StabLim-In.dat is supposed to contain stable trajectories 
C - these could be output from prior searchCO procedure - 
C these will be starting point for search of stability limit
C
      open(unit=lunR,file='zgoubi_StabLim-In.dat')

      jo = 1
      jok = 0
 2    continue
 
        open(unit=lunW,file='zgoubi.dat')
        rewind(lunW)
        rewind(lunR)

C Read till "KOBJ"
        do i=1,4
          read(lunR,fmt='(a)') txt132
          write(lunW,*) txt132
        enddo
C Read till "IMAX IMAXT"
          read(lunR,*) nTraj, imaxt
          if(nTraj.gt.nTrajmx) stop ' Too many trajectories...'
          txt132 = ' 1  1'
          write(lunW,*) txt132
C Read all initial traj from zgoubi_StabLim-In.dat, supposed to be stable
        do i=1,nTraj
          read(lunR,*) x(i),xp(i),z(i),zp(i),s(i),d(i),let(i)
        enddo
C Retains only one initial traj at a time
C and sets z to nul
        if    (HV .eq. 'H') then
          z(jo) = 0.
        elseif(HV .eq. 'Hz') then
          z(jo) = 1.e-4
        elseif(HV .eq. 'V') then
          z(jo) = 0.
        endif
        zp(jo) = 0.
        write(lunW,fmt='(1p,4e14.6,e9.1,e12.4,4a,i4)') 
     >    x(jo),xp(jo),z(jo),zp(jo),s(jo),d(jo),' ','''',let(jo),'''',jo
        write(6,*) 
        write(6,*) ' ---------    New trajectory :'
        write(6,fmt='(1p,4e14.6,e9.1,e12.4,4a,i4)') 
     >    x(jo),xp(jo),z(jo),zp(jo),s(jo),d(jo),' ','''',let(jo),'''',jo
        write(6,*)
C Completes zgoubi.dat with the rest of zgoubi_StabLim-In.dat
 1      continue
          read(lunR,fmt='(a)',end=10) txt132
C           skip storage, so to save on CPU time :

          if(.not. okFAI) then
            if    (strcon(txt132,'FAISTORE',8,
     >                                        IS) ) then 
              read(lunR,fmt='(a)',end=62) txt132
              read(lunR,fmt='(a)',end=62) txt132
              read(lunR,fmt='(a)',end=62) txt132
            elseif(strcon(txt132,'FAISCNL',7,
     >                                       IS) ) then 
              read(lunR,fmt='(a)',end=62) txt132
              read(lunR,fmt='(a)',end=62) txt132
            endif
          endif
          if    (strcon(txt132,'REBELOTE',8,
     >                                        IS) ) then 
            okREB = .true.
            write(lunW,*) txt132   
            read(lunR,fmt='(a)',end=62) txt132
            write(txt6,*) nTurn
            txt132 = txt6//'  0.2  99'
            write(lunW,*) txt132
            txt132 = '''END'''
            write(lunW,*) txt132
            goto 10
          endif
          if    (strcon(txt132,'''END''',5,
     >                                     IS) ) then 
            if(.not. okREB) then
              txt132 = '''REBELOTE'''
              write(lunW,*) txt132
              write(txt6,*) nTurn
              txt132 = txt6//'  0.2  99'
              write(lunW,*) txt132
              txt132 = '''END'''
              write(lunW,*) txt132
              goto 10
            endif
          endif

          write(lunW,*) txt132   

        goto 1

 10     continue
        close(lunW)

        call stabLim(HV,prec,jo,x(jo),xp(jo),z(jo),zp(jo),s(jo),d(jo),
     >                  xst,xpst,zst,zpst,sst,dst,kex,ok)

        if(ok) then 
c          call system('~/zgoubi/struct/ffag/tools/spiralFFAG/geneFieldMa
c     >p/tunesFromFai')          
c              pause
c          call system('cat tunes.out >> searchStabLim-tunes.out')
c              pause
c          call system('rm -f cat tunes.out')
          jok = jok + 1
          write(6,*) 
          write(6,*) '---------  Found ',jok,' extreme stable orbits,',
     >      ' now #',jo,' :'
          write(6,fmt='(1p,4e14.6,e9.1,e12.4)') 
     >                          xst,xpst,zst,zpst,sst,dst
          write(6,*)
          storb(1,jok) = xst
          storb(2,jok) = xpst
          storb(3,jok) = zst
          storb(4,jok) = zpst
          storb(5,jok) = sst
          storb(6,jok) = dst
        endif
        result = result .or. ok        

        write(*,*) ' jo / nTraj :    ', jo,' / ',nTraj
        if(jo.ge. nTraj) goto 60
        jo = jo+1

      goto 2

 60   continue
      close(lunR)

Create zgoubi_StabLim-Out.dat_HV containing limit orbits
      namFil = 'zgoubi_StabLim-Out.dat'//'_'//HV
      open(unit=lunW,file=namFil)
      open(unit=lunR,file='zgoubi_StabLim-In.dat')
C Read/write till "KOBJ"
        do i=1,4
          read(lunR,fmt='(a)') txt132
          write(lunW,fmt='(a)') txt132
        enddo
C Read/write "IMAX IMAXT"
        read(lunR,fmt='(a)') txt132
        write(lunW,fmt='(i3,a)') jok,'  1'
C Write stab Lim coordinates
        do j=1,jok
          read(lunR,fmt='(a)') txt132
          write(lunW,fmt='(1p,4e14.6,e9.1,e12.4,4a,i4)') 
     >    storb(1,j), storb(2,j), storb(3,j), storb(4,j),
     >     storb(5,j), storb(6,j),' ','''',let(j),''' ',j
        enddo
        do j=1,nTraj-jok
          read(lunR,fmt='(a)') txt132
        enddo
C Completes zgoubi_StabLim-Out.dat_HV with the rest of zgoubi_StabLim-In.dat
 61   continue
        read(lunR,fmt='(a)',end=62) txt132
        write(lunW,*) txt132   
        if(strcon(txt132,'REBELOTE',8,
     >                                IS)) then 
          read(lunR,fmt='(a)',end=62) txt132
            write(txt6,*) nTurn
            txt132 = txt6//'  0.2  99'
          write(lunW,*) txt132
        endif
      goto 61
 62   close(lunR)
      close(lunW)

      write(*,*) ' '
      write(*,*) '--------------'
      write(*,fmt='(2a,i2,a,i2,a)') ' New file ',namFil,
     >' contains the ',jok,
     >' traj. below (over ',nTraj,' trajectories launched) :'
      do j=1,jok
        write(*,fmt='(1p,4e14.6,e9.1,e12.4,4a,i4)') 
     >  storb(1,j), storb(2,j), storb(3,j), storb(4,j),
     >  storb(5,j), storb(6,j),' ','''',let(j),''' ',j
      enddo
      write(*,*) ' '
      if(first) then
        call system('mv -f searchStabLim.out  searchStabLim.out_old')
        first = .false.
      endif
C Read xK,xiDeg from  scanKXi.out 
      open(unit=34,name='tempKXi.dum',err=55)
      read(34,*,end=55) xK,xiDeg
      close(34)
 55   continue

      open(unit=33,file='searchStabLim.temp')
      WRITE(33,*) 
     >   '% Stab. limit coordinates 1-6, tag, traj#, K, xi'
      do j=1,jok
        write(33,fmt='(1p,4e14.6, e9.1, e12.4, 4a, i4, 2e12.4,a,a2)') 
     >  storb(1,j), storb(2,j), storb(3,j), storb(4,j),
     >  storb(5,j), storb(6,j),' ','''',let(j),''' ',j ,xK,xiDeg,' ',HV
      enddo
      write(33,*) ' '
      close(33)
      call system('cat searchStabLim.temp >> searchStabLim.out')
      call system('rm searchStabLim.temp')

          open(unit=34,file='tempHV.dum')
          write(34,*) HV
          close(34)
      if    (HV .eq. 'V') then
          call system('cp -f zgoubi_StabLim-Out.dat_V zgoubi.dat')
      elseif(HV .eq. 'H') then
          call system('cp -f zgoubi_StabLim-Out.dat_H zgoubi.dat')
      elseif(HV .eq. 'Hz') then
          call system('cp -f zgoubi_StabLim-Out.dat_Hz zgoubi.dat')
      endif

        if(kTrk.eq.1) then
          call system('~/zgoubi/source/zgoubi')
          call system('~/zgoubi/struct/ffag/tools/spiralFFAG/geneFieldMa
     >p/tunesFromFai')          
          call system('cat tunesFromFai.out >> searchStabLim-tunes.out')
          call system('rm -f tunesFromFai.out')
        endif

      goto 111   
C----- Loop on HV

      goto 99

 999  continue
      write(*,*) ' *** Error upon reading lunData '
      goto 99

 998  continue
      write(*,*) ' *** End of file lunData reached'
      goto 99

 99   continue
      close(lunData)
      stop
      end
      FUNCTION STRCON(STR,STRIN,NCHAR,
     >                                IS)
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
      subroutine stabLim(HV,prec,jo,xco,xpco,zco,zpco,s,d,
     >                      xst,xpst,zst,zpst,sst,dst,kex,ok)
      character*(*) HV
      logical lost, ok, first
      parameter (lunR=13,lunW=14)
      character txt132*132, let*1
      data first / .true. /
      data let / 'i' /

      ok = .false.
      lost = .false.

C du stands for dx or dz (cm)
      du = 5.   !!cm 
          if(HV .eq. 'V') then
            zco = zco + du
            zst = zco 
            xst = xco
          elseif(HV .eq. 'H' .or. HV .eq. 'Hz') then
            xco = xco + du
            xst = xco 
            zst = zco
          endif
      xpst = xpco
      zpst = zpco
      sst = s
      dst = d

 2    continue

C----------------------- Rebuild zgoubi.dat with new traj. -------------
        call system('cp -f zgoubi.dat searchStabLim.temp2')
        close(lunR)
        close(lunW)
        open(unit=lunR,file='searchStabLim.temp2')
        open(unit=lunW,file='zgoubi.dat')
C Read/write till "KOBJ"
          do i=1,4
            read(lunR,fmt='(a)') txt132
            write(lunW,fmt='(a)') txt132
          enddo
C Read/write "IMAX IMAXT"
          read(lunR,fmt='(a)') txt132
          write(lunW,fmt='(a)') '1  1'
C Write best co coordinates
          read(lunR,fmt='(a)') txt132
          write(lunW,fmt='(1p,4e14.6,e9.1,e12.4,4a,i4)') 
     >      xst,xpst,zst,zpst,sst,dst,' ','''',let,''' ',jo
          write(*,fmt='(1p,a,4e14.6,e9.1,e12.4)') 
     >    'Initial object :', xco,xpco,zco,zpco,sst,dst
          write(*,fmt='(1p,a,4e14.6,e9.1,e12.4,4a,i4)') 
     >    'New object :', xst,xpst,zst,zpst,sst,dst,' ','''','A','''',jo
C Completes zgoubi.dat with the rest of searchStabLim.temp2
 19       continue
          read(lunR,fmt='(a)',end=10) txt132
          write(lunW,fmt='(a)') txt132   
        goto 19 
 10     continue
        close(lunR)
        close(lunW)
C-----------------------------------------------------------------------

C Run zgoubi with single traj
        call system('~/zgoubi/source/zgoubi')
    
C Get initial Traj coord from zgoubi.res
        call getRes(
     >              lost)

C      write(*,*) ' x,xp,z,zp,s,d,lost : ',xst,xpst,zst,zpst,sst,dst,lost

        if(lost) then
          write(6,*) 
          write(6,*) '-----  Particle # ',jo,' lost, back to previous '
          write(6,*) '         du -> -du =',-du
          write(6,*)

          if(HV .eq. 'V') then
            zco = zco - du
            zst = zco 
            xst = xco
          elseif(HV .eq. 'H' .or. HV .eq. 'Hz') then
            xco = xco - du
            xst = xco 
            zst = zco
          endif

                write(*,*) ' HV, xst, zst :', hv, xst, zst

          du = du/2. 
          if (du.le.prec) then
            ok = .true.
            lost = .true.
            call system('mv -f b_zgoubi-temp.fai b_zgoubi.fai')
            goto 99
          endif
          lost = .false.
          call system('mv -f b_zgoubi.fai b_zgoubi-temp.fai')
        endif      

        write(6,*) '-----  Particle # ',jo,', increase initial ',
     >                                         HV,' position...'
        write(6,*) '  du = ', du
          if(HV .eq. 'V') then
            zco = zco + du
            zst = zco 
            xst = xco
          elseif(HV .eq. 'H' .or. HV .eq. 'Hz') then
            xco = xco + du
            xst = xco 
            zst = zco
          endif

        iter = iter+1
c        if(iter.le.10) then
           goto 2
c        else
c           ok = .false.
c           goto 99
c        endif

 99   continue
      write(*,*) ' x,xp,z,zp,du,lost : ',xst,xpst,zst,zpst,du,lost
      call system('rm searchStabLim.temp2')
      return
      end
      subroutine getRes(
     >                  lost)
C Get initial Traj coord, and average orbit, from zgoubi.res
      character let*(*)
      logical lost
C Read pick-ups from last pass in zgoubi.res, and cumulates in readPU.out
C This software assumes use of REBELOTE with writes inhibited - so that PU readouts 
C are written in zgoubi.res at first and last pass only. 

      character txt132*132

      logical strcon
      integer debstr, finstr
      data lunR / 15 /

      open(unit=lunR,name='zgoubi.res') 

 12   continue
      read(lunR,fmt='(a)',end=18,err=19) txt132

      if(strcon(txt132,'lost',4,
     >                          IS)) then
          goto 11
      else
        goto 12
      endif

 11   continue
        write(*,*) '****  Found  part. lost, with x, z =',x, z
        write(6,*)  ' ' 
        lost = .true.
      goto 99

 18   continue
      lost = .false.
      write(*,*) ' sbr getRes * End of read, no loss *   '
      goto 99

 19   continue
      lost = .false.
      write(*,*) ' sbr getRes * End of readPU upon read error *   '

 99   close(lunR)
      return
      end
      subroutine gotoEnd(lunOut,
     >                          nTrajRun)
      character*20 txt
      logical strcon

        write(6,*) '  Now go to End of readPU.out'

      nTrajRun = 0
C On cherche 'Closed'
 10   read(lunOut,fmt='(A)',end=98,err=99) txt
C      write(6,*) ' txt : ', txt
      if(strcon(txt,'% Closed',8,
     >                         IS)) then 
        nTrajRun = nTrajRun + 1 
C        write(6,*) '   gotoEnd,  nTrajRun = ', nTrajRun
      endif
      goto 10

      return

 98   write(6,*) '  * End of readPU/gotoEnd upon EOFile lunOut *    '
      return
 99   write(6,*) '  * End of readPU/gotoEnd upon read error in lunOut *'
      return
      end
