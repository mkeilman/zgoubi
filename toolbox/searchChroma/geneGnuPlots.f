      character*120 cmmnd
      logical okGnu, makAlf, makEta, makChro

C Write a gnuplot file for alpha plot, and execute it
      okGnu= makAlf()
      cmmnd = 'gnuplot < ./gnuplot_alfa.cmd'
      write(*,*) '---------------------------------------'
      write(*,*) cmmnd
      call system(cmmnd)

C Write a gnuplot file for eta plot, and execute it
      okGnu= makEta()
      cmmnd = 'gnuplot < ./gnuplot_eta.cmd'
      write(*,*) '---------------------------------------'
      write(*,*) cmmnd
      call system(cmmnd)

C Write a gnuplot file for dQ-dp/p plot, and execute it
      okGnu= makChro()
      cmmnd = 'gnuplot < ./gnuplot_dQdp.cmd'
      write(*,*) '---------------------------------------'
      write(*,*) cmmnd
      call system(cmmnd)

cC Write a gnuplot file for monitoring xxp and zzp plots, and execute it
c      okGnu= makMon()
c      cmmnd = '~/zgoubi/SVN/current/toolbox/b_fai2Fai/fromBFai2Fai'
c      write(*,*) '---------------------------------------'
c      write(*,*) cmmnd
c      call system(cmmnd)
c      cmmnd = 'mv fromBFai2Fai.out zgoubi.fai'
c      write(*,*) '---------------------------------------'
c      write(*,*) cmmnd
c      call system(cmmnd)
c      cmmnd = 'gnuplot < ./gnuplot_Mon.cmd'
c      write(*,*) '---------------------------------------'
c      write(*,*) cmmnd
c      call system(cmmnd)

C Terminate
      cmmnd = 'mkdir -p ./Log_Chroma'
      write(*,*) '---------------------------------------'
      write(*,*) cmmnd
      call system(cmmnd)
      cmmnd = 'cp  *eps ./Log_Chroma'
      write(*,*) '---------------------------------------'
      write(*,*) cmmnd
      call system(cmmnd)
 
      stop
      end
      function makChro()
      logical makChro
      open(unit=8,file='gnuplot_dQdp.cmd')
      write(8,fmt='(a)') 'set xlabel "dp/p" font "roman,18"'
      write(8,fmt='(a)') 'set ylabel "Frac. Q_x, Q_y" font "roman,18"'
      write(8,fmt='(2a)') 'set title "Tunes (fractional) versus dp/p"'
     > ,' font "roman,20"'
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'set grid'
      write(8,fmt='(a)') 'set xtics font "roman,12"'
      write(8,fmt='(a)') 'set ytics font "roman,12"'
      write(8,fmt='(a)') ' '
      write(8,fmt='(2a)') 'Qx(x) = Qx0 + Qx1*x + Qx2*x*x + Qx3*x*x*x '
C     > ,'+ Qx4*x*x*x*x'
      write(8,fmt='(2a)') 'Qy(x) = Qy0 + Qy1*x + Qy2*x*x + Qy3*x*x*x'
C     > ,' + Qy4*x*x*x*x'
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'fit_limit=1e-12'
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'fit Qx(x) \'
      write(8,fmt='(2a)') '     "tunesFromMatrix.out" u ($13-1):($3)   '
     > ,'  via Qx0, Qx1, Qx2, Qx3'  !, Qx4'
      write(8,fmt='(a)') 'fit Qy(x) \'
      write(8,fmt='(2a)') '     "tunesFromMatrix.out" u ($13-1):($4)   '
     > ,'  via Qy0, Qy1, Qy2, Qy3'  !, Qy4'
      write(8,fmt='(a)') ' '
      write(8,fmt='(2a)') 'plot "tunesFromMatrix.out" u ($13-1):($3)   '
     > ,' w p pt 10 ps 1.9  tit "tracking, Q_x", \'
      write(8,fmt='(2a)') '     "tunesFromMatrix.out" u ($13-1):($4)   '
     > ,' w p pt 11 ps 1.9  tit "tracking, Q_y", \'
      write(8,fmt='(a)') '     Qx(x) w l lw 1.5 tit "fit, Q_x",\'
      write(8,fmt='(a)') '     Qy(x) w l lw 1.5 tit "fit, Q_y" '
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'pause 3'
      write(8,fmt='(a)') ' '
      write(8,fmt='(2a)') 'set terminal postscript eps blacktext color'
     > ,' enh size 8.3cm,4cm "Times-Roman" 12 '
      write(8,fmt='(a)') ' set output "gnuplot_Chroma.eps" '
      write(8,fmt='(a)') ' replot '
      write(8,fmt='(a)') ' set terminal X11 '
      write(8,fmt='(a)') ' unset output '
      write(8,fmt='(a)') ' '

      write(8,fmt='(a)') 'show var '
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'system "rm -f gnuplot_dQdp.Out" '
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'set print "| cat >> gnuplot_dQdp.Out" '
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 
     >     'print Qx0, Qx1, Qx2,  "   Qx'', Qx'''', Qx'''''' '
C     >     'print Qx0, Qx1, Qx2, Qx3, "   Qx'', Qx'''', Qx'''''' '
      write(8,fmt='(a)') 
     >     'print Qy0, Qy1, Qy2,  "   Qy'', Qy'''', Qy'''''' '
C     >     'print Qy0, Qy1, Qy2, Qy3, "   Qy'', Qy'''', Qy'''''' '
 
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'exit '
      close(8)
      makChro = .true.
      return
      end
      function makMon()
      logical makMon
      open(unit=8,file='gnuplot_Mon.cmd')
      write(8,fmt='(a)') 'reset'
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'set xlabel "x (10^{-2}m)" font "roman,18"'
      write(8,fmt='(a)') 'set ylabel "x'' (10^{-3}rad)" font "roman,18"'
      write(8,fmt='(a)') 
     >  'set y2label "\epsilon_x/\pi (m.rad)" font "roman,18" '
      write(8,fmt='(2a)') 'set title "Horizontal phase-space"'
     > ,' font "roman,20"'
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'set xtics font "roman,12"'
      write(8,fmt='(a)') 'set ytics font "roman,12"'
      write(8,fmt='(a)') 'set y2tics font "roman,12"'
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'set logscale y2 10 '
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'set grid'
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'plot \'
      write(8,fmt='(2a)') '"zgoubi.fai" u ($10):($11) '
     >,' w p pt 10 ps 1.3  tit "x-x''",\'
      write(8,fmt='(2a)')'"tunesFromFai.out" u ($1*1e2):($7) axes x1y2'
     >,'   w p pt 10 ps 1.5  tit "emittance" ,\'
      write(8,fmt='(2a)')'"tunesFromFai.out" u ($1*1e2):($7) axes x1y2'
     >,'  w l lw 1.3  notit'
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'pause 3 '
      write(8,fmt='(a)') ' '
      write(8,fmt='(2a)') 'set terminal postscript eps blacktext color'
     > ,' enh size 8.3cm,4cm "Times-Roman" 12 '
      write(8,fmt='(a)') ' set output "gnuplot_xxp.eps" '
      write(8,fmt='(a)') ' replot '
      write(8,fmt='(a)') ' set terminal X11 '
      write(8,fmt='(a)') ' unset output '
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'set xlabel "y (10^{-2}m)" font "roman,18"'
      write(8,fmt='(a)') 'set ylabel "y'' (10^{-3}rad)" font "roman,18"'
      write(8,fmt='(a)') 
     >  'set y2label "\epsilon_y/\pi (m.rad)" font "roman,18" '
      write(8,fmt='(2a)') 'set title "Vertical phase-space"'
     > ,' font "roman,20"'
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'set xtics font "roman,12"'
      write(8,fmt='(a)') 'set ytics font "roman,12"'
      write(8,fmt='(a)') 'set y2tics font "roman,12"'
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'set logscale y2 10 '
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'plot \'
      write(8,fmt='(2a)') '"zgoubi.fai" u ($12):($13) '
     >,' w p pt 10 ps 1.3  tit "y-y''",\'
      write(8,fmt='(2a)')'"tunesFromFai.out" u ($13*1e2):($8) axes x1y2'
     >,'   w p pt 10 ps 1.5  tit "emittance" ,\'
      write(8,fmt='(2a)')'"tunesFromFai.out" u ($13*1e2):($8) axes x1y2'
     >,'  w l lw 1.3  notit'
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'pause 3 '
      write(8,fmt='(a)') ' '
      write(8,fmt='(2a)') 'set terminal postscript eps blacktext color'
     > ,' enh size 8.3cm,4cm "Times-Roman" 12 '
      write(8,fmt='(a)') ' set output "gnuplot_yyp.eps" '
      write(8,fmt='(a)') ' replot '
      write(8,fmt='(a)') ' set terminal X11 '
      write(8,fmt='(a)') ' unset output '
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'exit '
      close(8)
      makMon = .true.
      return
      end
      function makAlf()
      logical makAlf
      open(unit=8,file='gnuplot_alfa.cmd')
      write(8,fmt='(a)') '# Momentum compaction'
      write(8,fmt='(a)') 'set xlabel "dp/p" font "roman,18"'
      write(8,fmt='(a)') 'set ylabel "L (m)" font "roman,18"'
      write(8,fmt='(2a)') 'set title "Orbit length versus dp/p"'
     > ,' font "roman,20"'
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'set grid'
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'set xtics font "roman,12"'
      write(8,fmt='(a)') 'set ytics font "roman,12"'
      write(8,fmt='(a)') ' '
      write(8,fmt='(2a)') 'L(x) = L0 + L1*x + L2*x*x + L3*x*x*x '
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') ' L0 = 807.09'
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'fit_limit=1e-12'
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'fit L(x) \'
      write(8,fmt='(2a)') '  "tunesFromMatrix.out" '
     > //' u ($13 -1.):($11 /100.)'
     > //'  via L0, L1, L2, L3 '
      write(8,fmt='(a)') ' '
      write(8,fmt='(2a)') 'plot "tunesFromMatrix.out" '
     > //' u ($13 -1.):($11 /100.)'
     > //' w p pt 10 ps 1.9  tit "tracking", \'
      write(8,fmt='(a)') '     L(x) w l lw 1.5 tit "fit" '
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'pause 3'
      write(8,fmt='(a)') ' '
      write(8,fmt='(2a)') 'set terminal postscript eps blacktext color'
     > //' enh size 8.3cm,4cm "Times-Roman" 12 '
      write(8,fmt='(a)') ' set output "gnuplot_alfa.eps" '
      write(8,fmt='(a)') ' replot '
      write(8,fmt='(a)') ' set terminal X11 '
      write(8,fmt='(a)') ' unset output '
      write(8,fmt='(a)') ' '

      write(8,fmt='(a)') 'show var '
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'system "rm -f gnuplot_alfa.Out" '
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'set print "| cat >> gnuplot_alfa.Out" '
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') ' alfa = L1/L0'
      write(8,fmt='(a)') ' alfa1 = L2/L0'
      write(8,fmt='(a)') ' alfa2 = L3/L0'
      write(8,fmt='(a)') ' gtr = 1./sqrt(alfa)'
      write(8,fmt='(a)') ' print " " '
      write(8,fmt='(a)') ' print "Momentum compaction : " ' 
      write(8,fmt='(a)') ' print L0, gtr, alfa, alfa1, alfa2, '
     >//' " :  L0, gamma_tr, alpha, alpha_1, alpha_2 " '
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') ' show var'
      write(8,fmt='(a)') 'exit '
      close(8)
      makAlf = .true.
      return
      end
      function makEta()
      logical makEta
      open(unit=8,file='gnuplot_eta.cmd')
      write(8,fmt='(a)') '# Phase slip factor eta'
      write(8,fmt='(a)') 'set xlabel "dp/p" font "roman,18"'
      write(8,fmt='(a)') 'set ylabel "T_{rev} (\mu-s)" font "roman,18"'
      write(8,fmt='(2a)') 'set title "T_{rev} versus dp/p"'
     > ,' font "roman,20"'
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'set grid'
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'set xtics font "roman,12"'
      write(8,fmt='(a)') 'set ytics font "roman,12"'
      write(8,fmt='(a)') ' '
      write(8,fmt='(2a)') 'T(x) = T0 + T1*x + T2*x*x + T3*x*x*x '
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') ' T0 = ',807.09/3e8 
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'fit_limit=1e-12'
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'fit T(x) \'
      write(8,fmt='(2a)') '  "tunesFromMatrix.out" '
     > //' u ($13 -1.):($10)'
     > //'  via T0, T1, T2, T3 '
      write(8,fmt='(a)') ' '
      write(8,fmt='(2a)') 'plot "tunesFromMatrix.out" '
     > //' u ($13 -1.):($10)'
     > //' w p pt 10 ps 1.9  tit "tracking", \'
      write(8,fmt='(a)') '     T(x) w l lw 1.5 tit "fit" '
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'pause 3'
      write(8,fmt='(a)') ' '
      write(8,fmt='(2a)') 'set terminal postscript eps blacktext color'
     > //' enh size 8.3cm,4cm "Times-Roman" 12 '
      write(8,fmt='(a)') ' set output "gnuplot_eta.eps" '
      write(8,fmt='(a)') ' replot '
      write(8,fmt='(a)') ' set terminal X11 '
      write(8,fmt='(a)') ' unset output '
      write(8,fmt='(a)') ' '

      write(8,fmt='(a)') 'show var '
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'system "rm -f gnuplot_eta.Out" '
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') 'set print "| cat >> gnuplot_eta.Out" '
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') ' eta = -T1/T0'
      write(8,fmt='(a)') ' eta1 = -T2/T0'
      write(8,fmt='(a)') ' eta2 = -T3/T0'
      write(8,fmt='(a)') ' print " " '
      write(8,fmt='(a)') ' print "Momentum compaction : " ' 
      write(8,fmt='(a)') ' print T0, eta, eta1, eta2, '
     >//' " :  T0, eta, eta_1, eta_2 " '
      write(8,fmt='(a)') ' '
      write(8,fmt='(a)') ' show var'
      write(8,fmt='(a)') 'exit '
      close(8)
      makEta = .true.
      return
      end
