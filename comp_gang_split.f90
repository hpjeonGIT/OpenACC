program main
    implicit none
    integer :: n        ! size of the vector
    real*8,allocatable :: a(:), r(:), e(:)
    real*8:: x, sumr, sume
    integer*8 :: i, j, ierr, npair
    real:: t0,t1
    n = 100000
    ! n= 100000, 0.44/0.15 sec each
    ! n= 1000000, 15.35/14.97 sec each
    allocate(a(n), r(n), e(n), stat=ierr)
    do i=1, n
       call random_number(x)
       a(i) = x
    end do
    r(:) = 0.0d0
    e(:) = 0.0d0
    npair = 0
    call cpu_time(t0)
    !$acc data copyin(a) copy(r,e)
    !$acc kernels 
    !$acc loop gang private(sumr,sume) reduction(+:npair)
    do i=1, n
       sumr = 0.0
       sume = 0.0
       !$acc loop vector reduction(+:sumr,sume,npair)
       do j=1,n
          npair = npair + 1
          sumr = sumr + dexp(a(i) + a(j))
          sume = sume + dlog(a(i) + a(j))
       end do
       r(i) = sumr
       e(i) = sume
    enddo
    !$acc end kernels
    !$acc end data
    ! 
    deallocate(a,r,e,stat=ierr)
    call cpu_time(t1)
    print*, t1 -t0, npair

    !!!!!!!! Another run
    allocate(a(n), r(n), e(n), stat=ierr)
    do i=1, n
       call random_number(x)
       a(i) = x
    end do
    r(:) = 0.0d0
    e(:) = 0.0d0
    npair = 0
    call cpu_time(t0)
    !$acc data copyin(a) copy(r,e)
    !$acc kernels 
    !$acc loop  private(sumr,sume) reduction(+:npair)
    do i=1, n
       sumr = 0.0
       sume = 0.0
       do j=1,n
          npair = npair + 1
          sumr = sumr + dexp(a(i) + a(j))
          sume = sume + dlog(a(i) + a(j))
       end do
       r(i) = sumr
       e(i) = sume
    enddo
    !$acc end kernels
    !$acc end data
    ! 
    deallocate(a,r,e,stat=ierr)
    call cpu_time(t1)
    print*, t1 -t0, npair

!ava02.corning.com> time ./a.out
!   0.6320531                  10000000000
!   0.2809992                  10000000000


end program
