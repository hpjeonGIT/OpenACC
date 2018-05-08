#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
double rand_double() { return ((double) rand())/((double) RAND_MAX); }
int main(int argc, char *argv[])
{
  double t0,t1;uint N,i,j;double *restrict a,*restrict r,*restrict e,x,sum_omp,sum_acc,sum_loc;long npair;
  N = 20000;
  a = malloc(N*sizeof *a); r = malloc(N*sizeof *r); e = malloc(N*sizeof *e);
   
  for (i=0;i<N;i++) {    
    a[i] = rand_double(); 
    r[i] = 0.0; e[i] = 0.0;
  }

  // OpenMP loop
  npair = 0;
  sum_omp = 0.0;
  t0 = omp_get_wtime(); //clock();
#pragma omp parallel for private(i,j) default(shared) reduction(+:npair,sum_omp)\
  schedule(static) 
  for (i=0;i<N;i++) {
    for (j=0;j<N;j++) {
      npair += 1;
      r[i] += exp(a[i] + a[j]);
      e[i] += log(a[i] + a[j]);
      sum_omp += r[i]*0.1 + e[i]*0.2;
    }
  }
  t1 = omp_get_wtime();
  printf("# OMP wall time = %6.4f %ld %f\n", 
	 (t1-t0), npair, sum_omp);


  // OpenACC loop
  for (i=0;i<N;i++) {    
    r[i] = 0.0; e[i] = 0.0;
  }
  npair = 0;
  sum_acc = 0.0;
  t0 = omp_get_wtime();
#pragma acc data copyin(a[0:N]) copy(r[0:N],e[0:N])
#pragma acc kernels 
#pragma acc loop  reduction(+:npair, sum_acc)  
  for (i=0;i<N;i++) {
    sum_loc = 0.0;
    for (j=0;j<N;j++) {
      npair += 1;
      r[i] += exp(a[i] + a[j]);
      e[i] += log(a[i] + a[j]);
      sum_loc += r[i]*0.1 + e[i]*0.2;
    }
    sum_acc += sum_loc;
  }
  t1 = omp_get_wtime();
  printf("# ACC wall time = %6.4f %ld %f\n", 
	 (t1-t0), npair, sum_acc);
  free(a); free(r); free(e);
  return 0;
}
