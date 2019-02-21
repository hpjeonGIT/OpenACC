# OpenACC
Sample codes for OpenACC implementation

# How to compile using pgi compiler
- pgf90 -mp -fast -Minfo=accel -acc loop_omp_acc.f90
- pgcc -mp -fast -Minfo=accel -acc loop_omp_acc.c
# for v100 card
- pgcc -acc -mp -Minfo=acc -fast -ta=tesla:cc70 loop_omp_acc.c

# OpenMP
- Multiple threading parallelism in CPU
  - Only on a single node of SMP
  - Using the shared memory among multiple processors
  - Can be coupled with MPI/OpenACC
  - Can be coupled with vectorization
- Inject "sentinel" arround the loops
  - Tells the compiler the ROI for parallelism
  - Private/Shared variables for each thread
  - Single thread or synchronization using atomic or critical section
  - Reduce operation for scalar variables
    - No array or vectors
  - Nested loops or parallelism supported
    - Multiple steps of parallelism
- Mostly better than auto-parallelization
  - When the loop is complex
  
# Using OpenMP
- Inject sentinels in the top and bottom of the loop
  - Decide private/shared variables for the ones used inside the loop
- Compile the source code using 
  - -fopenmp for GCC
  - -fopenmp or -qopenmp for Intel compiler
- Configure the number of threads to use
  - export OMP_NUM_THREADS=8
  - a.out
- Rule of thumb
  - Mostly MPI parallelism is better than OpenMP or multiple-threading
  - But hybrid parallelism might be better than bare MPI when CPU density per NIC is high
  - Sweet-spot of OpenMP is 8-12 threads as of 2013-2018
  - Dont' guess, measure
- In Intel compiler: ifort -Ofast -qopenmp omp.f90
- In PGI compiler: pgf90 -fast -mp omp.f90

# OpenACC
- For GPGPU computing
  - -ta=multicore for CPU
    - OMP_NUM_THREADS may conflict with CGROUP
    - export MP_BLIST=0,1,2,3,4,5
- More abstract than CUDA
  - CUDA is extremely hard to use
  - Fortran/C/C++ supported
- PGI and GCC compiler
  - Can be coupled with OpenMP/MPI
- Similar feeling and look of OpenMP
  - OpenMP-style parallelism (or vectorization) on GPGPU
  - More explicit than OpenMP
    - Can configure which GPU will be used
  - Don't guess, measure

# Using OpenACC
- Compile the source code using 
  - -fopenacc for GCC
  - -acc for PGI compiler
    - -ta=tesla for GPU, -ta=multicore for CPU
- Monitor GPU status using command: nvidia-smi -l
- Ref:
  - http://web.stanford.edu/class/cme213/files/lectures/Lecture_14_openacc2017.pdf
  - https://www.pgroup.com/resources/docs/18.3/pdf/openacc18_gs.pdf
  - http://on-demand.gputechconf.com/gtc/2015/presentation/S5192-Jeff-Larkin.pdf
- As of 2018, derived data type might not be supported
- Use structure of array (SoA), not the array of the struture (AoS)
- Details
  - gang => thread block
  - worker => warp
  - vector => thread
- Limited multi-GPU support
  - One MPI rank per GPU is recommended
- No multiple-threading supported random number generation
- Reduction in acc routine is not supported

