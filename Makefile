CFLAGS = -g -DGFORTRAN4
#
# Case of gfortran compiler, next two lines
#FC=gfortran
#FFLAGS=-O4 -Wall -fno-automatic -pedantic
#
######## 
# Case of ifort compiler, next two lines
FC=ifort
### check : check array boundary errors
FFLAGS= -xHOST -O3 -ip -traceback -check -static -save
#FFLAGS= -xHOST -O3 -ip -traceback -check         -save
#FFLAGS= -xHOST -O3 -ip -traceback        -static -save
#FFLAGS= -xHOST -O3 -ip                   -static -save
#FFLAGS= -xHOST -O3 -ip -traceback        -static -save
######## case OWL : 
# Note : the -static option includes local libs (-lm etc.) into executable. Pb with that on cscomputers
#FC=/opt/intel/bin/ifort
#FFLAGS= -xHOST -O4 -ip  -save
#FFLAGS= -xHOST -O4 -ip -traceback -save
#FFLAGS= -xHOST -O4 -ip -traceback -check -save

.POSIX:

all :
	cd modules ;  make CFLAGS="$(CFLAGS)" FC="$(FC)" FFLAGS="$(FFLAGS)"
	cd common ; rm libzg.a || true  ; make CFLAGS="$(CFLAGS)" FC="$(FC)" FFLAGS="$(FFLAGS)"
	cd coupling ; make CFLAGS="$(CFLAGS)" FC="$(FC)" FFLAGS="$(FFLAGS)"
	cd zgoubi ; make CFLAGS="$(CFLAGS)" FC="$(FC)" FFLAGS="$(FFLAGS)"

clean :
	$(RM) *~
	cd modules ;  make clean
	cd common ;  make clean
	cd coupling ; make clean
	cd zgoubi ;  make clean

 