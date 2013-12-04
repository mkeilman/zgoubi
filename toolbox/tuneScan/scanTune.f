      implicit double precision (a-h,o-z)

      parameter (lunR=11,lunW=12)
      character txt132*132, let*1, txt132c*132, cmnd*132
      parameter (nCOmx=10001, maxIter=20)
      dimension x(nCOmx),xp(nCOmx),z(nCOmx),
     >                   zp(nCOmx),s(nCOmx),d(nCOmx),let(nCOmx)
      dimension clorb(7,nCOmx)
      character cmmnd*110

      logical ok, strcon, first, idluni
      data ok, first / .false., .true. /

      integer debstr, finstr

      logical reb, empty

      character(10) fam(3)
C 3 data per family, 2 families
      dimension scal(3,2)
      logical firstH, firstV

      character txtStep*40, txtSample*40       

      data txtStep, txtSample / ' 0.02  stepSize',    
     > '.001 .001 .001 .001 0. .001   ' /

      data fam /  'QH_', 'QV_', ' '  /
      data nstp / 10 /
      data scal(1,1),scal(2,1) / .8d0, 1.2d0 /
      data scal(1,2),scal(2,2) / 1.d0, 1.d0  /
      data firstH, firstV / .true., .true. /

C Requested precision on co (cm, mrad)
C Careful here :  PREC MUST BE COMPATIBLE with precision on x and xp as read in zgoubi.res
      data precX, precXp / .01d0, .01d0 /     ! zgoubi units cm, mrad
C      data precX, precXp / .0001d0, .001d0 /
      data  kaseV / 2 /
      data  dpp / 1.d-3 /

      cmnd = 'mv -f scanTunes.out_cat scanTunes.out_cat_old'
      write(*,*) '++++++ ',cmnd
      call system(cmnd)
      cmnd = 'mv -f scanTunes.spectra_cat scanTunes.spectra_cat_old'
      write(*,*) '++++++ ',cmnd
      call system(cmnd)

      if (idluni(lunIn)) then
        open(unit=lunIn,file='scanTune.In',err=25)
        read(lunIn,*,err=24,end=24) fam(1), fam(2)
C Field variation, relative to read one : 
        read(lunIn,*,err=24,end=24) 
     >   nstp,  scal(1,1),scal(2,1), scal(1,2),scal(2,2)
        goto 26
 24    continue
        rewind(lunIn)
        write(lunIn,*) 'QH_','QV_','  ** Created by scanTune **'      
        write(lunIn,*) '10  .8  1.2  0.7  1.1',
     >       '  #steps, range family #1, range family #2'
 26     continue
 25     continue
        close(lunIn)
      endif

      scal(3,1) =(scal(2,1)-scal(1,1))/dble(nstp)
      scal(3,2) =(scal(2,2)-scal(1,2))/dble(nstp)

      cl9 = 2.99792458D8 / 1.d9

      do istp = 1, nstp
        scal1 = scal(1,1) + dble(istp-1) * scal(3,1)
        scal2 = scal(1,2) + dble(istp-1) * scal(3,2)
        write(68,*) 'scal1 = ',scal1
        write(68,*) 'scal2 = ',scal2
 
        close(lunW)
        close(lunR)
        open(unit=lunR,file='zgoubi_scanTune-In.dat')

        jo = 1
        jok = 0
 2      continue

        rewind(lunR)
        open(unit=lunW,file='zgoubi.dat')
        rewind(lunW)

C Read till "KOBJ"
        read(lunR,fmt='(a)') txt132
        write(lunW,fmt='(a)') 
     >  'Data generated by scanTune '
        read(lunR,fmt='(a)') txt132
        write(lunW,*) txt132(debstr(txt132):finstr(txt132))
        read(lunR,fmt='(a)') txt132
        write(lunW,*) txt132(debstr(txt132):finstr(txt132))
        read(txt132,*) BORO
        write(*,*) ' Reference rigidity BRho = ',BORO/1000.d0,' T.m' 
        read(lunR,*) XOBJ
        KOBJ = INT(XOBJ)
        if(KOBJ .eq. 2 ) then 
          write(lunW,*) KOBJ
C Read till "IMAX IMAXT"
          read(lunR,*) nCO, imaxt
          if(nCO.gt.nCOmx) stop ' Too many co''s...'
          if(nCO.lt.1) stop ' No  co in zgoubi_scanTune-In.dat !!'
          txt132 = ' 1  1'
          write(lunW,*) txt132(debstr(txt132):finstr(txt132))
C Read all initial traj present in zgoubi_scanTune-In.dat
          do i=1,nCO
            read(lunR,*) x(i),xp(i),z(i),zp(i),s(i),d(i),let(i)
          enddo
C Retains only one
          write(lunW,fmt='(1p,4e14.6,e9.1,e14.7,4a,i4)') 
     >    x(jo),xp(jo),z(jo),zp(jo),s(jo),d(jo),' ','''',let(jo),'''',jo
          write(6,*) 
          write(6,*) ' ---------    New trajectory :'
          write(6,fmt='(1p,4e14.6,e9.1,e14.7,4a,i4)') 
     >    x(jo),xp(jo),z(jo),zp(jo),s(jo),d(jo),' ','''',let(jo),'''',jo
          write(6,*)
C write first line with "1's" 
          read(lunR,fmt='(a)',end=10) txt132
          write(lunW,*) txt132(debstr(txt132):finstr(txt132))   
        else
 27       continue
          read(lunR,fmt='(a)') txt132
          txt132 = txt132(debstr(txt132):finstr(txt132))
          if(txt132(1:1) .eq. '''') then 
            backspace(lunR)
            KOBJ = 2
            write(lunW,*) KOBJ
            nCO = 1
            imaxt = 1
            write(lunW,*) nCO, imaxt
            x(1)= 0.d0
            xp(1)= 0.d0
            z(1)= 0.d0
            zp(1)= 0.d0
            s(1)= 0.d0
            d(1)= 1.d0
            let(1)= 'o'
            x(2)= 0.d0
            xp(2)= 0.d0
            z(2)= 0.d0
            zp(2)= 0.d0
            s(2)= 0.d0
            d(2)= 1.d0 + dpp
            let(2)= 'p'
            write(lunW,fmt='(1p,4e14.6,e9.1,e14.7,4a,i4)') 
     >    x(jo),xp(jo),z(jo),zp(jo),s(jo),d(jo),' ','''',let(jo),'''',jo
            write(6,*) 
            write(6,*) ' ---------    New trajectory :'
            write(6,fmt='(1p,4e14.6,e9.1,e14.7,4a,i4)') 
     >    x(jo),xp(jo),z(jo),zp(jo),s(jo),d(jo),' ','''',let(jo),'''',jo
            write(6,*)
C write line with a "1" 
            write(lunW,*) ' 1 '
          else
            goto 27
          endif
        endif

        txt132    = '''PICKUPS'''
        write(lunW,*) txt132(debstr(txt132):finstr(txt132))   
        txt132    = ' 1'
        write(lunW,*) txt132(debstr(txt132):finstr(txt132))   
        txt132    = ' #Start'
        write(lunW,*) txt132(debstr(txt132):finstr(txt132))   
        txt132    =  '''MARKER''   #Start '
        write(lunW,*) txt132(debstr(txt132):finstr(txt132))   

            firstH = .true.
            firstV = .true.

C Completes zgoubi.dat with the rest of zgoubi_scanTune-In.dat
 1      continue
          read(lunR,fmt='(a)',end=10) txt132
          if(strcon(txt132,'1 1 1 1 1 1 1 1 1 1',19,
     >                                              IS)) then 
C           do not write possible subsquent lines of "1's"

          elseif(strcon(txt132,'''PICKUPS''',9,
     >                                      IS)) then 
            read(lunR,fmt='(a)',end=10) txt132
            read(lunR,fmt='(a)',end=10) txt132

          elseif(strcon(txt132,'''OPTICS''',8,
     >                                       IS)) then 
            read(lunR,fmt='(a)') txt132

          elseif(strcon(txt132,'''MARKER''',8,
     >                                    IS)) then 
            if(strcon(txt132,'#Start',6,
     >                                    IS)) then 
            endif

          elseif(strcon(txt132,'''PARTICUL''',10,
     >                                           IS)) then 
            write(lunW,*) txt132(debstr(txt132):finstr(txt132))               
            read(lunR,fmt='(a)',end=10) txt132
            write(lunW,*) txt132(debstr(txt132):finstr(txt132))               
            read(txt132,*) am,q
            write(6,*) ' particle mass and charge : ', am, q
            P0 = BORO*CL9

c          elseif(strcon(txt132,fam(1)(debstr(fam(1)):finstr(fam(1))),
c     >                              1+finstr(fam(1))-debstr(fam(1)),
c     >                                           IS)) then 
          elseif(firstH .and. strcon(txt132,'QH_',
     >                                3,
     >                                           IS)) then 
            write(lunW,*) txt132(debstr(txt132):finstr(txt132))               
            read(lunR,fmt='(a)',end=10) txt132
            write(lunW,*) txt132(debstr(txt132):finstr(txt132))               
            read(lunR,fmt='(a)',end=10) txt132
            read(txt132,*) scalin
            write(68,*) ' H ',scalin , scal1, scalin * scal1
            write(lunW,*) scalin * scal1

            firstH = .false.

c          elseif(strcon(txt132,fam(2)(debstr(fam(2)):finstr(fam(2))),
c     >                              1+finstr(fam(2))-debstr(fam(2)),
c     >                                           IS)) then 
          elseif(firstV .and. strcon(txt132,'QV_',
     >                                 3,
     >                                           IS)) then 
            write(lunW,*) txt132(debstr(txt132):finstr(txt132))               
            read(lunR,fmt='(a)',end=10) txt132
            write(lunW,*) txt132(debstr(txt132):finstr(txt132))               
            read(lunR,fmt='(a)',end=10) txt132
            read(txt132,*) scalin
            write(68,*) ' V ',scalin , scal2, scalin * scal2
            write(lunW,*) scalin * scal2

            firstV = .false.

          elseif(strcon(txt132,'''TWISS''',7,
     >                                       IS)) then
            read(lunR,fmt='(a)',end=10) txt132

          elseif(strcon(txt132,'''FIT''',5,
     >                                       IS)
     >      .or. strcon(txt132,'''FIT2''',6,
     >                                       IS)) then
            read(lunR,*,end=10) IV
            do ii = 1, iv
              read(lunR,fmt='(a)',end=10) txt132
            enddo
            read(lunR,*,end=10) IC
            do ii = 1, ic
              read(lunR,fmt='(a)',end=10) txt132
            enddo

          elseif(strcon(txt132,'''REBELOTE''',10,
     >                                         IS)) then
            goto 10

          elseif(strcon(txt132,'''END''',5,
     >                                       IS)) then
            goto 10

          elseif(strcon(txt132,'''FIN''',5,
     >                                       IS)) then
            goto 10

          else
C                write(*,*)  txt132(debstr(txt132):finstr(txt132))
                write(lunW,*) txt132(debstr(txt132):finstr(txt132))               

          endif

        goto 1

 10     continue
              txt132 = '''REBELOTE'''
              write(lunW,*) txt132(debstr(txt132):finstr(txt132))
              txt132 = '9   0.2  99'
C              txt120 = '29   0.1  99'
              write(lunW,*) txt132(debstr(txt132):finstr(txt132))
              txt132 = '''END'''
              write(lunW,*) txt132(debstr(txt132):finstr(txt132))
        close(lunW)

        call avrorb(jo,maxIter,kaseV, 
     >                xav,xpav,zav,zpav,sav,dav,tav,kex,ok,precX,precXp)
 
        if(ok) then 
          jok = jok + 1
          write(6,*) 
          write(6,fmt='(a,i4,a,a,2f9.4,a,a,i4,a)') 
     >    ' ---------    Found ',jok,' average orbits ',
     >    '(precision dx, dx'' : ',precX,precXp,' cm, mrad) ; ',
     >    '  now c.o. #',jo,' :'
C          write(6,fmt='(1p,2e14.6,2e9.1,e9.1,e12.4,e14.6)') 
          write(6,fmt='(1p,4e14.6,e9.1,e12.4,e14.6)') 
     >                          xav,xpav,zav,zpav,sav,dav,tav
          write(6,*)
          clorb(1,jok) = xav
          clorb(2,jok) = xpav
          if(kaseV.eq.0) then
            clorb(3,jok) = .0
            clorb(4,jok) = .0 
          elseif(kaseV.eq.1) then
            clorb(3,jok) = .0001 !!!!!zav
            clorb(4,jok) = .0 !!!!zpav
          elseif(kaseV.eq.2) then
            clorb(3,jok) = zav
            clorb(4,jok) = zpav
          else
          endif
          clorb(5,jok) = .0 !!!sav
          clorb(6,jok) = dav
          clorb(7,jok) = tav
        endif

        write(6,*) ' jo / nCO :    ', jo,' / ',nCO
        if(jo.ge. nCO) goto 60
C        jo = jo+1
C      goto 2

 60   continue
      close(lunR)
      close(lunW)

      if(jok.eq.0) stop ' ScaTune : No closed orbit found, sorry.'


Create  zgoubi_scanTune_Trk.dat  containing computed closed orbits + epsilon
      open(unit=lunR,file='zgoubi.dat')
      open(unit=lunW,file='zgoubi_scanTune_Trk.dat')
C Read/write till "KOBJ"
        read(lunR,fmt='(a)') txt132
        write(lunW,fmt='(a)') 
     >  'Data generated by scanTune '
        do i=1,2
          read(lunR,fmt='(a)') txt132
          write(lunW,fmt='(a)') txt132(debstr(txt132):finstr(txt132))
        enddo
        read(lunR,*) KOBJ
        write(lunW,fmt='(a)') ' 2 '
C Read rest of OBJET data
 29     continue
          read(lunR,fmt='(a)') txt132
          txt132 = txt132(debstr(txt132):finstr(txt132))
          if(txt132(1:1) .ne. '''') goto 29
          backspace(lunR)
C Write "IMAX IMAXT"
        write(lunW,fmt='(i3,a)') jok,'  1'
C Write all co coordinates (clorb(i,j)) into zgoubi_scanTune_Trk.dat
        do j=1,jok
          pj = p0 * clorb(6,j)
          Tj = sqrt(pj*pj+am*am) - am
          xx = clorb(1,j) + .01   !cm
          if (abs(xx).lt.1d-3) xx=1d-3 
          zz = clorb(3,j) + .01   !cm
          if (abs(zz).lt.1d-3) zz=1d-3 
          write(lunW,fmt='(1p,4e14.6,e9.1,e16.8,4a,f12.2,a)') 
     >    xx, clorb(2,j), zz, clorb(4,j),
     >    clorb(5,j), clorb(6,j),' ','''',let(j),''' ',Tj/10.,' MeV'
        enddo
C Create lines of 1s
      k10 = jok/10
      kk = jok - 10*k10
      txt132 = '1 1 1 1 1 1 1 1 1 1 '
      do ii = 1, k10
        write(lunW,*) txt132(debstr(txt132):finstr(txt132))   
      enddo
      if(kk.ne.0) write(lunW,*) txt132(debstr(txt132):finstr(txt132))   

      txt132 = '''FAISTORE'''
      write(lunW,*) txt132(debstr(txt132):finstr(txt132))   
      txt132 = '     b_zgoubi.fai  #Start '
      write(lunW,*) txt132(debstr(txt132):finstr(txt132))   
      txt132 = '  1 '
      write(lunW,*) txt132(debstr(txt132):finstr(txt132))   
      txt132 = '''MARKER''     #Start '
      write(lunW,*) txt132(debstr(txt132):finstr(txt132))

C Completes zgoubi_scanTune_Trk.dat with the rest of zgoubi_scanTune-In.dat
 18   continue
          read(lunR,fmt='(a)',end=13) txt132
          txt132 = txt132(debstr(txt132):132)

          if(strcon(txt132,'''SPNTRK''',8,
     >                                       IS)) then 
            read(lunR,fmt='(a)') txt132
            read(lunR,fmt='(a)') txt132
            if(txt132(debstr(txt132):debstr(txt132)) .eq. '''') 
     >      write(lunW,*) txt132(debstr(txt132):finstr(txt132))

          elseif(strcon(txt132,'''OPTICS''',8,
     >                                       IS)) then 
            read(lunR,fmt='(a)') txt132

          elseif(strcon(txt132,'''PICKUPS''',9,
     >                                       IS)) then 

            read(lunR,fmt='(a)') txt132
            read(lunR,fmt='(a)') txt132

          elseif(strcon(txt132,'''SPNPRNL''',9,
     >                                       IS)) then 
            read(lunR,fmt='(a)') txt132

          elseif(strcon(txt132,'''SPNSTORE''',10,
     >                                       IS)) then 
            read(lunR,fmt='(a)') txt132
            read(lunR,fmt='(a)') txt132

          elseif(strcon(txt132,'''FAISCNL''',9,
     >                                       IS)) then 
            read(lunR,fmt='(a)') txt132

          elseif(strcon(txt132,'''FAISTORE''',10,
     >                                       IS)) then 
            read(lunR,fmt='(a)') txt132
            read(lunR,fmt='(a)') txt132

          elseif(strcon(txt132,'''MARKER''',8,
     >                                        IS)) then 
            txt132c = txt132(IS+8:132-8)
            txt132c = txt132c(debstr(txt132c):debstr(txt132c)+6)
            if(txt132c.eq.'#Start') then
            elseif(txt132c.eq.'#End') then
            else              
              write(lunW,*) txt132(debstr(txt132):finstr(txt132))
            endif

          elseif(strcon(txt132,'''CAVITE''',8,
     >                                        IS)) then
              write(lunW,*) txt132(debstr(txt132):finstr(txt132))
              read(lunR,*,end=13) xcav
              write(lunW,*) ' 0 ', xcav
              read(lunR,fmt='(a)',end=13) txt132
              write(lunW,*) txt132(debstr(txt132):finstr(txt132))
              read(lunR,fmt='(a)',end=13) txt132
              write(lunW,*) txt132(debstr(txt132):finstr(txt132))

          elseif(strcon(txt132,'''REBELOTE''',10,
     >                                         IS)) then
            read(lunR,fmt='(a)',end=13) txt132

          elseif(strcon(txt132,'''TWISS''',7,
     >                                       IS)) then 
            read(lunR,fmt='(a)') txt132

          elseif(strcon(txt132,'''END''',5,
     >                                       IS)) then

            goto 11
          elseif(strcon(txt132,'''FIN''',5,
     >                                       IS)) then

            goto 11
          else
            
              write(lunW,*) txt132(debstr(txt132):finstr(txt132))
          endif

        goto 18

 11     continue
              txt132 = '''MARKER''   #End'
              write(lunW,*) txt132(debstr(txt132):finstr(txt132))
              txt132 = '''REBELOTE'''
              write(lunW,*) txt132(debstr(txt132):finstr(txt132))
              txt132 = '299  0.2  99'
              write(lunW,*) txt132(debstr(txt132):finstr(txt132))
              txt132 = '''END'''
              write(lunW,*) txt132(debstr(txt132):finstr(txt132)) 

 13   continue
      write(*,*) ' '
      write(*,*) ' End of  input file  zgoubi_scanTune-In.dat  reached,'
     >,' file   zgoubi_scanTune_Trk.dat completed.'
      write(*,*) ' ------------'
      write(*,*) ' '
      close(lunR)
      close(lunW)

      write(*,*) ' '
      write(*,*) '--------------'
      write(*,fmt='(a,i2,a,i2,a)') 
     >'zgoubi_scanTune_Trk.dat contains ',
     >jok,' co''s below (over ',nCO,' trajectories launched) :'
      zj = 0.d0
      phij = 0.d0
      do j=1,jok
        pj = p0 * clorb(6,j)
        Tj = sqrt(pj*pj+am*am) - am
C        write(6,fmt='(1p, 2e14.6, 2e9.1, e16.8,
        write(6,fmt='(1p, 4e14.6, e16.8,
     >        e14.6, 4a, f12.2, a)') 
C     >        2e12.4, 4a, f12.2, a)') 
     >  clorb(1,j), clorb(2,j), clorb(3,j), clorb(4,j),
     >  clorb(5,j), clorb(6,j),    !!!!!!!clorb(7,j),
     >        ' ','''',let(j),''' ',Tj/10.,' MeV'
      enddo
      write(*,*) ' '

C----------------------------------------------------
      write(*,*) ' '
      write(*,*) '--------------------- '
      write(*,*) 'Track for further FT'
      cmnd = 'rm -f  zgoubi.dat'
      write(*,*) '++++++ ',cmnd
      call system(cmnd)
      cmnd = 'cp -f zgoubi_scanTune_Trk.dat zgoubi.dat'
      write(*,*) '++++++ ',cmnd
      call system(cmnd)
      call system('~/zgoubi/source/zgoubi')
      cmnd = 'mv -f zgoubi.res zgoubi_scanTune_Trk.res'
      write(*,*) '++++++ ',cmnd
      call system(cmnd)
      cmnd = '~/zgoubi/struct/tools/b_fai2Fai/fromBFai2Fai'
      write(*,*) '++++++ ',cmnd
      call system(cmnd)
      cmnd = 'mv -f fromBFai2Fai.out  zgoubi.fai'
      write(*,*) '++++++ ',cmnd
      call system(cmnd)
C Get tunes
      cmnd = '~/zgoubi/struct/tools/tunesFromFai/tunesFromFai'
      write(*,*) '++++++ ',cmnd
      call system(cmnd)
      cmnd = 'cat tunesFromFai.out >> scanTunes.out_cat'
      write(*,*) '++++++ ',cmnd
      call system(cmnd)
C Save spectra
      cmnd = 'cat tunesFromFai_spctra.Out >> scanTunes.spectra_cat'
      write(*,*) '++++++ ',cmnd
      call system(cmnd)

      enddo

      write(*,*) ' '
      write(*,*) 'Job "searchCO" ended, hopefully well... '
      write(*,*) ' '
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
      subroutine avrorb(jo,maxIter,kaseV, 
     >                xav,xpav,zav,zpav,sav,d,tav,kex,ok,precX,precXp)
      implicit double precision (a-h,o-z)
      logical existCO, convCO ,ok
      parameter (lunR=13,lunW=14)
      character txt132*132, let*1

      integer debstr, finstr

      pi = 4. * atan(1.)

      dx = 0.   !cm
      ddx = 0.1
      dxp = .0  ! mrad
      ddxp = 1.
      ddr = sqrt(ddx * ddx + ddxp * ddxp)
      iter = 1
      dz = 0.
      ddz = 0.1
      dzp = .0
      ddzp = 1.
      ddrz = sqrt(ddz * ddz + ddzp * ddzp)
 2    continue

C Run zgoubi with single traj
      call system('~/zgoubi/source/zgoubi')

C Get initial Traj coord, and average orbit, from zgoubi.res
      call getPUs_Av(
     >          x,xp,z,zp,s,d,t,let,xav,xpav,zav,zpav,sav,tav,kex)
      existCO = kex.eq.1
      if(existCO) then
        iter = 1
        write(6,*) 
        write(6,*) ' --------------------------------'
        write(6,*) ' -----  CO #',jo,' does exist...'
        write(6,*) ' --------------------------------'
        write(6,*)
        convCO = (abs(x-xav).le.precX) .and. (abs(xp-xpav).le.precXp) 
        if(kaseV.eq.2)
     >   convCO = convCO .and. 
     >     (abs(z-zav).le.precX) .and. (abs(zp-zpav).le.precXp) 
c        write(*,*) '  convergence : ',abs(x-xav), abs(xp-xpav)
c        write(*,*) '                ',abs(z-zav), abs(zp-zpav),convco
        if (convCO) then
          ok = .true.
          goto 99
        else
          write(6,fmt='(a,i6,a,1p,2e12.4,a)') 
     >    ' ------------ now seeking precision on CO #',jo,
     >    ',   precision dx, dx'' : ',precX,precXp,' cm, mrad'
          write(6,fmt='(2(a,I2))') '     iteration # ',iter,'/',maxIter
          write(6,*)
          xn = xav
          xpn = xpav 
          zn = zav
          zpn = zpav
          sn = s
        endif
      else
        write(6,*) ' '
        write(6,*) ' ------------------------------------------------'
        write(6,*) ' -----  Could not find CO #',jo,' trying again...'
        write(6,*) ' ------------------------------------------------'
        write(6,*) ' '
        write(6,fmt='(2(a,I2))') '        iteration # ',iter,'/',maxIter
        write(6,*)
        tta =  float(iter) * 2. * pi / 8.
        dx = float(iter) * ddr *cos(tta)
        xn = x + dx
        dxp = float(iter) * ddr *sin(tta)
        xpn = xp + dxp
        dz = float(iter) * ddrz *cos(tta)
        zn = z + dz
        dzp = float(iter) * ddrz *sin(tta)
        zpn = zp + dzp
        sn = s
      endif      
      call system('rm -f  searchCO.temp2')
      call system('cp -f zgoubi.dat searchCO.temp2')
      close(lunR)
      close(lunW)
      open(unit=lunR,file='searchCO.temp2')
      open(unit=lunW,file='zgoubi.dat')
C Read/write till "KOBJ"
        do i=1,4
          read(lunR,fmt='(a)') txt132
          write(lunW,fmt='(a)') txt132(debstr(txt132):finstr(txt132))
        enddo
C Read/write "IMAX IMAXT"
        read(lunR,fmt='(a)') txt132
        write(lunW,fmt='(a)') '1  1'
C Write best co coordinates
        read(lunR,fmt='(a)') txt132
C        write(lunW,fmt='(1p,2e14.6,2e9.1,e9.1,e16.8,4a,i4)') 
        write(lunW,fmt='(1p,4e14.6,e9.1,e16.8,4a,i4)') 
     >    xn,xpn,zn,zpn,sn,d,' ','''',let,''' ',jo
C        write(*,fmt='(1p,a,2e14.6,2e9.1,e9.1,e16.8,4a,i4)') 
        write(*,fmt='(1p,a,4e14.6,e9.1,e16.8,4a,i4)') 
     >   ' New object : ', xn,xpn,zn,zpn,sn,d,' ','''','A','''',jo
C Completes zgoubi.dat with the rest of searchCO.temp2
 1    continue
        read(lunR,fmt='(a)',end=10) txt132
        write(lunW,fmt='(a)') txt132(debstr(txt132):finstr(txt132))   
      goto 1

 10   continue
      close(lunR)
      close(lunW)
      iter = iter+1
      if(iter.le.maxIter) then
         goto 2
      else
         ok = .false.
         goto 99
      endif

 99   continue
C      call system('rm searchCO.temp2')
      return
      end
      subroutine getPUs_Av(
     >        xn,xpn,zn,zpn,sn,dn,tn,let,xav,xpav,zav,zpav,sav,tav,kex)
      implicit double precision (a-h,o-z)
C Get initial Traj coord, and average orbit, from zgoubi.res
      character let*(*)
C Read pick-ups from last pass in zgoubi.res, and cumulates in readPU.out
C This software assumes use of REBELOTE with writes inhibited - so that PU readouts 
C are written in zgoubi.res at pass1 and last pass only. 

      character txt132*132

      logical strcon, pass1
      integer debstr, finstr
      data lunR / 15 /

      open(unit=lunR,file='zgoubi.res') 

      pass1 = .true.

 10   continue

      if(pass1) then
C On cherche la 1ere traj.
        read(lunR,*,end=18,err=19) txt132
        if(strcon(txt132,'OBJET',5,
     >                          IS)) then 
          read(lunR,*,end=18,err=19) txt132
          read(lunR,*,end=18,err=19) txt132
          read(lunR,*,end=18,err=19) txt132
C Read trajectory
          read(lunR,*) xn,xpn,zn,zpn,sn,dn,let
c          write(*,*) '****** OBJET : ',xn,xpn,zn,zpn,s,d,' ',let
        else
          goto 10
        endif
      endif

 12   continue
C On cherche 'PU_average'
      read(lunR,*,end=18,err=19) txt132
c      write(*,*) '                now txt132 is : ', txt132
      if(strcon(txt132,'PU_average',10,
     >                      IS)) then 
        if(pass1) then
          pass1=.false.
          goto 12
        else
          goto 11
        endif
      else
        goto 12
      endif

 11   continue
        write(6,*) ' Now reading PU contents, writing to readPU.out...'
        read(lunR,*,end=18,err=19) txt132

C read units are :                 cm  mrd  cm  mrd  cm      mu_s
        read(lunR,*,end=18,err=19) xav,xpav,zav,zpav,sav,dav,tav

 90     continue
        write(6,*)  ' ' 
        write(6,*)  '----------' 
        write(*,*) '  Objet was : ',xn, xpn, zn, zpn, dn
        write(*,*) '  PU gives  : ',xav,xpav,zav,zpav,sav,dav,tav
        write(6,*)  ' ' 
        write(6,*)  ' ' 
        kex = 1
c             pause
      goto 99

 18   continue
      kex = 0
c      write(*,*) ' sbr getPUs * End of readPU upon EOFile *    '
      goto 99

 19   continue
      kex = 0
c      write(*,*) ' sbr getPUs * End of readPU upon read error *   '
 99   close(lunR)
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
      subroutine readat(lunIn,fname,
     >                              kaseV,ierr)
      implicit double precision (a-h,o-z)

      include "READAT.H"

      return
      end

      FUNCTION EMPTY(STR)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      LOGICAL EMPTY
      CHARACTER*(*) STR
C     -----------------------------------------------------
C     .TRUE. if STR is either empty or contains only blanks
C     -----------------------------------------------------

      INTEGER FINSTR
      EMPTY = FINSTR(STR) .EQ. 0
      RETURN
      END