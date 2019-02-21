program main
  implicit none
  real*8,allocatable :: a(:,:), b(:,:), c(:,:), d(:,:)
  real*8:: x
  real:: t0, t1
  integer :: i, j, n, niter, ierr, npiece
  
  n = 10000;
  allocate(a(n,n), b(n,n), c(n,n), d(n,n), stat=ierr)
  do i=1, n
     do j=1, n
        call random_number(x)
        a(i,j) = x
     end do
  end do
  b(:,:) = 0.0d0
  c(:,:) = 0.0d0
  d(:,:) = a(:,:)

  niter=100; npiece=5
  call cpu_time(t0)
  do i=1, niter*npiece
     call every_loop(a,b,n)
  end do
  call cpu_time(t1)
  print *, "every loop = ", t1-t0 ! takes 400 sec at v100

  call cpu_time(t0)
  do i=1, npiece
     call chunk_loop(d,c,n,niter)
  end do
  call cpu_time(t1)
  print *, "every 100 loop = ", t1-t0 ! takes 8.2 sec at v100


  x = 0.0
  do i=1, n
     do j=1, n
        x = x + dabs(b(i,j) - c(i,j))
     end do
  end do
  print *, "diff = ", x
  deallocate(a,b,c,d, stat=ierr)
end program main


subroutine chunk_loop(a,c,n,niter)
  implicit none
  integer::n, niter, i, j,k
  real*8:: a(n,n), c(n,n), w0, w1, w2
  w0 = 1.01d0
  w1 = 1.02d0
  w2 = 0.98d0
  !$acc data copy(c(:,:),a(:,:))
  do k=1, niter
     !$acc kernels loop  private(i,j)
     do i=2, n-1
        do j=2, n-1
           c(i,j) = w0*(a(i,j)   + a(i-1,j)   + a(i+1,j))+ &
                &   w1*(a(i,j+1) + a(i-1,j+1) + a(i+1,j+1)) + &
                &   w2*(a(i,j-1) + a(i-1,j-1) + a(i+1,j-1))
        end do
     enddo
     !$acc kernels loop private(i,j) 
     do i=2, n-1
        do j=2, n-1
           a(i,j) = w0*(c(i,j)   + c(i-1,j)   + c(i+1,j))+ &
                &   w1*(c(i,j+1) + c(i-1,j+1) + c(i+1,j+1)) + &
                &   w2*(c(i,j-1) + c(i-1,j-1) + c(i+1,j-1))
        end do
     enddo
  end do
  !$acc end data
  return
end subroutine chunk_loop


subroutine every_loop(a,c,n)
  implicit none
  integer::n, i, j,k
  real*8:: a(n,n), c(n,n), w0, w1, w2
  w0 = 1.01d0
  w1 = 1.02d0
  w2 = 0.98d0
  !$acc data copy(c(:,:),a(:,:))
  !$acc kernels loop  private(i,j)
  do i=2, n-1
     do j=2, n-1
        c(i,j) = w0*(a(i,j)   + a(i-1,j)   + a(i+1,j))+ &
             &   w1*(a(i,j+1) + a(i-1,j+1) + a(i+1,j+1)) + &
             &   w2*(a(i,j-1) + a(i-1,j-1) + a(i+1,j-1))
     end do
  enddo
  !$acc kernels loop private(i,j) 
  do i=2, n-1
     do j=2, n-1
        a(i,j) = w0*(c(i,j)   + c(i-1,j)   + c(i+1,j))+ &
             &   w1*(c(i,j+1) + c(i-1,j+1) + c(i+1,j+1)) + &
                &   w2*(c(i,j-1) + c(i-1,j-1) + c(i+1,j-1))
     end do
  enddo
  !$acc end data
  return
end subroutine every_loop
