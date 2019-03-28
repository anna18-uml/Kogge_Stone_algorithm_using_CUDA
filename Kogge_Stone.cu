#include<stdio.h>
#include<iostream>
#include<math.h>

__global__ void add(int *a,int len)
{
    __shared__ int mem[1954];
    int tid =blockDim.x*blockIdx.x+threadIdx.x;
    int n=1;
    for(;tid<len && tid<16384*n;tid=tid+16384)
    {
    __syncthreads();
    for(int i=0;i<logf(len);i++)
    {
            
            int j=powf(2,i);
            a[tid+j]=a[tid]+a[tid+j];          //sum of elements   for depth of logflen
        
    }
    mem[n]=a[16384*n];    
    a[tid]+=mem[n];
     __syncthreads();
    n++;
    }
}
int main(void)
{
    int len=32000000;
    int *a_d;
    int *a=(int *)malloc(sizeof(int)*len);
    for(int i=0;i<len;i++)
    {
        a[i]=rand()%10;
    }
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaMalloc((int **)&a_d,sizeof(int)*len);
    cudaMemcpy(a_d,a,sizeof(int)*len,cudaMemcpyHostToDevice);
    dim3 threadsPerBlock(32,4);
    dim3 blocksPerGrid(32,4);
    cudaEventRecord(start);
    add<<<blocksPerGrid,threadsPerBlock>>>(a_d,len);
    cudaMemcpy(a,a_d,sizeof(int)*len,cudaMemcpyDeviceToHost);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    cudaDeviceSynchronize();
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds,start,stop);
    printf("Elapsed time is : %f millisec\n\n",milliseconds);    
    cudaFree(a_d);
    
}
