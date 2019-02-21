! Compile using pgf90  -mp -acc -fast comparison_call_ftn.f90
program main
  implicit none
  real*8,allocatable :: a(:,:), b(:,:), c(:,:)
  real*8:: x
  real:: t0, t1
  integer :: i, j, n, niter, ierr
  
  n = 10000; niter=1000
  allocate(a(n,n), b(n,n), c(n,n), stat=ierr)
  do i=1, n
     do j=1, n
        call random_number(x)
        a(i,j) = x
     end do
  end do
  b(:,:) = 0.0d0
  c(:,:) = 0.0d0
  call cpu_time(t0)
  call cpu_loop(a,b,n,niter)
  call cpu_time(t1)
  print *, "cpu = ", t1-t0 ! took 30.6 sec with 40 cores of xeon 6148 @ 2.4GHz
  call cpu_time(t0)
  call gpu_loop(a,c,n,niter)
  call cpu_time(t1)
  print *, "gpu = ", t1-t0 ! took 5.6 sec in v100
  x = 0.0
  do i=1, n
     do j=1, n
        x = x + dabs(b(i,j) - c(i,j))
     end do
  end do
  print *, "diff = ", x
  deallocate(a,b,c, stat=ierr)
end program main

subroutine cpu_loop(a,b,n,niter)
  implicit none
  integer:: n, niter, i, j,k
  real*8:: a(n,n), b(n,n), w0, w1, w2
  w0 = 1.01d0
  w1 = 1.02d0
  w2 = 0.98d0
  do k=1, niter
     !$omp parallel &
     !$omp default(shared) &
     !$omp private(i,j)
     !$omp do &
     !$omp schedule(static) 
     do i=2, n-1
        do j=2, n-1
           b(i,j) = w0*(a(i,j)   + a(i-1,j)   + a(i+1,j))+ &
                &   w1*(a(i,j+1) + a(i-1,j+1) + a(i+1,j+1)) + &
                &   w2*(a(i,j-1) + a(i-1,j-1) + a(i+1,j-1))
        end do
     enddo     
     !$omp end do
     !$omp end parallel
  end do
  return
end subroutine cpu_loop

subroutine gpu_loop(a,c,n,niter)
  implicit none
  integer::n, niter, i, j,k
  real*8:: a(n,n), c(n,n), w0, w1, w2
  w0 = 1.01d0
  w1 = 1.02d0
  w2 = 0.98d0
  !$acc data copy(c(:,:)) copyin(a(:,:))
  do k=1, niter
     !$acc kernels loop private(i,j)
     do i=2, n-1
        do j=2, n-1
           c(i,j) = w0*(a(i,j)   + a(i-1,j)   + a(i+1,j))+ &
                &   w1*(a(i,j+1) + a(i-1,j+1) + a(i+1,j+1)) + &
                &   w2*(a(i,j-1) + a(i-1,j-1) + a(i+1,j-1))
        end do
     enddo
  end do
  !$acc end data
  return
end subroutine gpu_loop

