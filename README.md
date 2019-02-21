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

