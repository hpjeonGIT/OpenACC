program main
    use omp_lib
    implicit none
    integer :: n        ! size of the vector
    real*8,allocatable :: a(:), r(:), e(:)
    real*8:: x, sum_omp, sum_acc, sum_loc
    integer*8 :: i, j, ierr, npair
    real:: t0,t1

    n = 1000
    allocate(a(n), r(n), e(n), stat=ierr)
    do i=1, n
       call random_number(x)
       a(i) = x
    end do
    r(:) = 0.0d0
    e(:) = 0.0d0
    npair = 0
    sum_omp = 0.0d0
    t0 = omp_get_wtime()
    !$omp parallel do  default(shared) private(i,j) reduction(+:npair,sum_omp)&
    !$omp schedule(static) 
    do i=1, n
       do j=1,n
          npair = npair + 1
          r(i) = r(i)+dexp(a(i) + a(j))
          e(i) = e(i)+dlog(a(i) + a(j))
          sum_omp = sum_omp + r(i)*0.1d0 + e(i)*0.2d0
       end do
    enddo
    !$omp end parallel do
    ! 
    t1 = omp_get_wtime()
    print *, "OMP took", t1 -t0, npair,sum_omp
    !
    r(:) = 0.0d0
    e(:) = 0.0d0
    npair = 0
    sum_acc = 0.0d0
    t0 = omp_get_wtime()
    !$acc data copyin(a(1:n)) copy(r(1:n),e(1:n))
    !$acc kernels 
    !$acc loop reduction(+:npair, sum_acc)
    do i=1, n
       sum_loc = 0.0
       do j=1,n
          npair = npair + 1
          r(i) = r(i)+dexp(a(i) + a(j))
          e(i) = e(i)+dlog(a(i) + a(j))
          sum_loc = sum_loc + r(i)*0.1d0 + e(i)*0.2d0          
       end do
       sum_acc = sum_acc + sum_loc
    enddo
    !$acc end kernels
    !$acc end data
    ! 

    t1 = omp_get_wtime()
    print *, "ACC took", t1 -t0, npair,sum_acc
    deallocate(a,r,e,stat=ierr)
end program
