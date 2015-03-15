#!/bin/sh
#
# Shell script to creat the pup_f.f90 file.
#  Used to avoid duplicate copy-and-paste codein pup_f.f90.

cat > pup_f.f90 << END_OF_HEADER
!   DO NOT EDIT THIS FILE, GENERATE IT FROM RUNNING pup_f.f90.sh
    module pupmod
      implicit none

      interface
        function fpup_issizing(p)
          INTEGER :: p
          logical fpup_issizing
        end function
        function fpup_ispacking(p)
          INTEGER :: p
          logical fpup_ispacking
        end function
        function fpup_isunpacking(p)
          INTEGER :: p
          logical fpup_isunpacking
        end function
        function fpup_isdeleting(p)
          INTEGER :: p
          logical fpup_isdeleting
        end function
        function fpup_isuserlevel(p)
          INTEGER :: p
          logical fpup_isuserlevel
        end function

        subroutine fpup_char(p, d)
          INTEGER :: p
          CHARACTER :: d
        end subroutine
        subroutine fpup_short(p, d)
          INTEGER :: p
          INTEGER (KIND=2) :: d
        end subroutine
        subroutine fpup_int(p, d)
          INTEGER :: p
          INTEGER (KIND=4) :: d
        end subroutine
        subroutine fpup_long(p, d)
          INTEGER :: p
          INTEGER (KIND=8) :: d
        end subroutine
        subroutine fpup_real(p, d)
          INTEGER :: p
          REAL (KIND=4)  :: d
        end subroutine
        subroutine fpup_double(p, d)
          INTEGER :: p
          REAL (KIND=8)  :: d
        end subroutine
        subroutine fpup_logical(p, d)
          INTEGER :: p
          LOGICAL :: d
        end subroutine
      end interface

END_OF_HEADER

for t in chars ints longs reals doubles logicals
do
  echo "      interface fpup_${t}" >> pup_f.f90
  if test $t = "chars" 
  then
  echo "       module procedure fpup_${t}_0" >> pup_f.f90
  fi
  for i in  1 2 3 4 5 6 7
  do
  echo "       module procedure fpup_${t}_${i}" >> pup_f.f90
  done
  echo "      end interface fpup_${t}" >> pup_f.f90
  echo >> pup_f.f90
done

cat >> pup_f.f90 << END_OF_HEADER
      interface pup
        module procedure pi,pia1d,pia2d,pia3d,pia4d,pia5d,pia6d,pia7d
        module procedure pc,pca1d,pca2d,pca3d,pca4d,pca5d,pca6d,pca7d
        module procedure ps,psa1d,psa2d,psa3d,psa4d,psa5d,psa6d,psa7d
        module procedure pr,pra1d,pra2d,pra3d,pra4d,pra5d,pra6d,pra7d
        module procedure pd,pda1d,pda2d,pda3d,pda4d,pda5d,pda6d,pda7d
        module procedure pl,pla1d,pla2d,pla3d,pla4d,pla5d,pla6d,pla7d
      end interface
      interface apup
        module procedure apia1d,apia2d,apia3d,apia4d,apia5d,apia6d,apia7d
        module procedure apca1d,apca2d,apca3d,apca4d,apca5d,apca6d,apca7d
        module procedure apsa1d,apsa2d,apsa3d,apsa4d,apsa5d,apsa6d,apsa7d
        module procedure apra1d,apra2d,apra3d,apra4d,apra5d,apra6d,apra7d
        module procedure apda1d,apda2d,apda3d,apda4d,apda5d,apda6d,apda7d
        module procedure apla1d,apla2d,apla3d,apla4d,apla5d,apla6d,apla7d
      end interface
      contains
      function pup_issz(p)
        INTEGER :: p
        logical pup_issz
        pup_issz = fpup_issizing(p)
      end function
      function pup_ispk(p)
        INTEGER :: p
        logical pup_ispk
        pup_ispk = fpup_ispacking(p)
      end function
      function pup_isupk(p)
        INTEGER :: p
        logical pup_isupk
        pup_isupk = fpup_isunpacking(p)
      end function
      function pup_isdel(p)
        INTEGER :: p
        logical pup_isdel
        pup_isdel = fpup_isdeleting(p)
      end function
      function pup_isul(p)
        INTEGER :: p
        logical pup_isul
        pup_isul = fpup_isuserlevel(p)
      end function

      subroutine fpup_complex(p,c)
        INTEGER p
        complex c
        call fpup_real(p,REAL(c))
        call fpup_real(p,AIMAG(c))
      end subroutine

      subroutine fpup_complexes(p,c,size)
        INTEGER p
        complex,pointer,dimension(:) :: c
        integer size
        integer i
        do i = 1, size, 1
          call fpup_complex(p,c(i))
        end do
      end subroutine

      subroutine fpup_doublecomplex(p,c)
        INTEGER p
        double complex c
        call fpup_double(p,DBLE(c))
        call fpup_double(p,DIMAG(c))
      end subroutine

      subroutine fpup_doublecomplexes(p,c,size)
        INTEGER p
        double complex,pointer,dimension(:) :: c
        integer size
        integer i
        do i = 1, size, 1
          call fpup_doublecomplex(p,c(i))
        end do
      end subroutine


      subroutine fpup_chars_0(p, d, c)
        INTEGER :: p
        CHARACTER(LEN=*)     d
        INTEGER :: c
        call fpup_charsg(p, d, c)
      end subroutine
END_OF_HEADER

for data in "chars/character" "shorts/integer(kind=2)" "ints/integer(kind=4)" "longs/integer(kind=8)" "reals/real(kind=4)" "doubles/real(kind=8)" "logicals/logical"
do
 pupname=`echo $data | awk -F/ '{print $1}'`
 typename=`echo $data | awk -F/ '{print $2}'`
 for i in 1 2 3 4 5 6 7
 do
  echo "       subroutine fpup_${pupname}_${i}(p, d, c)" >> pup_f.f90
  echo "        INTEGER :: p" >> pup_f.f90
  echo -n "        ${typename}, intent(inout), dimension(:" >> pup_f.f90
  n=1
  while [ $n -lt $i ]
  do
    echo -n ",:" >> pup_f.f90
    n=`expr $n + 1`
  done
  echo ") :: d" >> pup_f.f90
  echo "        INTEGER :: c" >> pup_f.f90
  echo "        call fpup_${pupname}g(p, d, c)"  >> pup_f.f90
  echo "       end subroutine" >> pup_f.f90
 done
 echo >> pup_f.f90
done

#
# Create pup routines for each data type:
#   The "p" routines just copy the data.
#   The "ap" routines also allocate and free the buffer.
#
for data in "int/ints/i/integer" "short/shorts/s/integer(kind=2)" "char/chars/c/character" "real/reals/r/real(kind=4)" "double/doubles/d/real(kind=8)" "logical/logicals/l/logical"
do
	pupname=`echo $data | awk -F/ '{print $1}'`
	pupnames=`echo $data | awk -F/ '{print $2}'`
	cname=`echo $data | awk -F/ '{print $3}'`
	fname=`echo $data | awk -F/ '{print $4}'`
	echo "Making pup routines for data type $pupname/$cname/$fname"
	cat >> pup_f.f90 << END_OF_DATATYPE


      subroutine p${cname}(p, i)
        INTEGER :: p
        $fname, intent(inout) :: i
        call fpup_${pupname}(p, i)
      end subroutine
      
      subroutine p${cname}a1d(p, arr)
        INTEGER :: p
        $fname, intent(inout), dimension(:) :: arr
        call fpup_${pupnames}(p, arr, size(arr))
      end subroutine
      subroutine p${cname}a2d(p, arr)
        INTEGER :: p
        $fname, intent(inout), dimension(:,:) :: arr
        call fpup_${pupnames}(p, arr, size(arr))
      end subroutine
      subroutine p${cname}a3d(p, arr)
        INTEGER :: p
        $fname, intent(inout), dimension(:,:,:) :: arr
        call fpup_${pupnames}(p, arr, size(arr))
      end subroutine
      subroutine p${cname}a4d(p, arr)
        INTEGER :: p
        $fname, intent(inout), dimension(:,:,:,:) :: arr
        call fpup_${pupnames}(p, arr, size(arr))
      end subroutine
      subroutine p${cname}a5d(p, arr)
        INTEGER :: p
        $fname, intent(inout), dimension(:,:,:,:,:) :: arr
        call fpup_${pupnames}(p, arr, size(arr))
      end subroutine
      subroutine p${cname}a6d(p, arr)
        INTEGER :: p
        $fname, intent(inout), dimension(:,:,:,:,:,:) :: arr
        call fpup_${pupnames}(p, arr, size(arr))
      end subroutine
      subroutine p${cname}a7d(p, arr)
        INTEGER :: p
        $fname, intent(inout), dimension(:,:,:,:,:,:,:) :: arr
        call fpup_${pupnames}(p, arr, size(arr))
      end subroutine

      subroutine ap${cname}a1d(p, arr)
        INTEGER :: p
        $fname, pointer, dimension(:) :: arr
        integer :: n(1)
        IF (fpup_isunpacking(p)) THEN
          CALL fpup_ints(p,n,1)
          ALLOCATE(arr(n(1)))
        ELSE
          n(1)=SIZE(arr,DIM=1)
          CALL fpup_ints(p,n,1)
        END IF
        call fpup_${pupnames}(p, arr, n(1))
        IF (fpup_isdeleting(p)) THEN
          deallocate(arr)
        END IF
      end subroutine

      subroutine ap${cname}a2d(p, arr)
        INTEGER :: p
        $fname, pointer, dimension(:,:) :: arr
        integer :: n(2)
        IF (fpup_isunpacking(p)) THEN
          CALL fpup_ints(p,n,2)
          ALLOCATE(arr(n(1),n(2)))
        ELSE
          n(1)=SIZE(arr,DIM=1)
          n(2)=SIZE(arr,DIM=2)
          CALL fpup_ints(p,n,2)
        END IF
        call fpup_${pupnames}(p, arr, size(arr))
        IF (fpup_isdeleting(p)) THEN
          deallocate(arr)
        END IF
      end subroutine

      subroutine ap${cname}a3d(p, arr)
        INTEGER :: p
        $fname, pointer, dimension(:,:,:) :: arr
        integer :: n(3)
        IF (fpup_isunpacking(p)) THEN
          CALL fpup_ints(p,n,3)
          ALLOCATE(arr(n(1),n(2),n(3)))
        ELSE
          n(1)=SIZE(arr,DIM=1)
          n(2)=SIZE(arr,DIM=2)
          n(3)=SIZE(arr,DIM=3)
          CALL fpup_ints(p,n,3)
        END IF
        call fpup_${pupnames}(p, arr, size(arr))
        IF (fpup_isdeleting(p)) THEN
          deallocate(arr)
        END IF
      end subroutine

      subroutine ap${cname}a4d(p, arr)
        INTEGER :: p
        $fname, pointer, dimension(:,:,:,:) :: arr
        integer :: n(4)
        IF (fpup_isunpacking(p)) THEN
          CALL fpup_ints(p,n,4)
          ALLOCATE(arr(n(1),n(2),n(3),n(4)))
        ELSE
          n(1)=SIZE(arr,DIM=1)
          n(2)=SIZE(arr,DIM=2)
          n(3)=SIZE(arr,DIM=3)
          n(4)=SIZE(arr,DIM=4)
          CALL fpup_ints(p,n,4)
        END IF
        call fpup_${pupnames}(p, arr, size(arr))
        IF (fpup_isdeleting(p)) THEN
          deallocate(arr)
        END IF
      end subroutine

      subroutine ap${cname}a5d(p, arr)
        INTEGER :: p
        $fname, pointer, dimension(:,:,:,:,:) :: arr
        integer :: n(5)
        IF (fpup_isunpacking(p)) THEN
          CALL fpup_ints(p,n,5)
          ALLOCATE(arr(n(1),n(2),n(3),n(4),n(5)))
        ELSE
          n(1)=SIZE(arr,DIM=1)
          n(2)=SIZE(arr,DIM=2)
          n(3)=SIZE(arr,DIM=3)
          n(4)=SIZE(arr,DIM=4)
          n(5)=SIZE(arr,DIM=5)
          CALL fpup_ints(p,n,5)
        END IF
        call fpup_${pupnames}(p, arr, size(arr))
        IF (fpup_isdeleting(p)) THEN
          deallocate(arr)
        END IF
      end subroutine

      subroutine ap${cname}a6d(p, arr)
        INTEGER :: p
        $fname, pointer, dimension(:,:,:,:,:,:) :: arr
        integer :: n(6)
        IF (fpup_isunpacking(p)) THEN
          CALL fpup_ints(p,n,6)
          ALLOCATE(arr(n(1),n(2),n(3),n(4),n(5),n(6)))
        ELSE
          n(1)=SIZE(arr,DIM=1)
          n(2)=SIZE(arr,DIM=2)
          n(3)=SIZE(arr,DIM=3)
          n(4)=SIZE(arr,DIM=4)
          n(5)=SIZE(arr,DIM=5)
          n(6)=SIZE(arr,DIM=6)
          CALL fpup_ints(p,n,6)
        END IF
        call fpup_${pupnames}(p, arr, size(arr))
        IF (fpup_isdeleting(p)) THEN
          deallocate(arr)
        END IF
      end subroutine

      subroutine ap${cname}a7d(p, arr)
        INTEGER :: p
        $fname, pointer, dimension(:,:,:,:,:,:,:) :: arr
        integer :: n(7)
        IF (fpup_isunpacking(p)) THEN
          CALL fpup_ints(p,n,7)
          ALLOCATE(arr(n(1),n(2),n(3),n(4),n(5),n(6),n(7)))
        ELSE
          n(1)=SIZE(arr,DIM=1)
          n(2)=SIZE(arr,DIM=2)
          n(3)=SIZE(arr,DIM=3)
          n(4)=SIZE(arr,DIM=4)
          n(5)=SIZE(arr,DIM=5)
          n(6)=SIZE(arr,DIM=6)
          n(7)=SIZE(arr,DIM=7)
          CALL fpup_ints(p,n,7)
        END IF
        call fpup_${pupnames}(p, arr, size(arr))
        IF (fpup_isdeleting(p)) THEN
          deallocate(arr)
        END IF
      end subroutine

END_OF_DATATYPE

done


echo "    end module" >> pup_f.f90

