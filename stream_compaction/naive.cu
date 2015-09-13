#include <cuda.h>
#include <cuda_runtime.h>
#include "common.h"
#include "naive.h"
#include<iostream>
int *dev_A;
int *dev_B;
int *dev_C;
namespace StreamCompaction {
namespace Naive {

// TODO: __global__

/**
 * Performs prefix-sum (aka scan) on idata, storing the result into odata.
 */
__global__ void Nscan(int n, int logn, int *Ain, int*Bout,int *Ctemp){//in;out;temp

	int thid = threadIdx.x;
	int offset; 
	Bout[0] = 0;
	Ctemp[0] = 0;
	for (int j = 0; j < n-1; j++){
		Ctemp[j + 1] = Ain[j];
	}

	//Ctemp[thid] = (thid > 0) ? Ain[thid - 1] : 0;
	for (int d = 1; d <= logn; d++){
		offset = 2;

		if (d == 1)offset = 1;
		if (d == 2)offset = 2;
		else 
			for (int i = 1; i < d-1; i++){
				offset *= 2; 
			}
		if (thid >= offset)//pow(2,d-1){d=1,off=1}{d=2,off=2}{d=3,off=4}off=pow(2,d-1){d=4,offset=8}
				Ctemp[thid] += Ctemp[thid - offset];
	}
	Bout[0] = 0;
    Bout[thid] = Ctemp[thid];

	}
void init(int *hst_A, int *hst_B,int n){

		int _size = n *sizeof(int);
		cudaMalloc((void**)&dev_A, _size);
		cudaMemcpy(dev_A, hst_A, _size, cudaMemcpyHostToDevice);

		cudaMalloc((void**)&dev_B, _size);
		cudaMemcpy(dev_B, hst_B, _size, cudaMemcpyHostToDevice);

		cudaMalloc((void**)&dev_C, _size);
	}
void scan(int n, int *odata, const int *idata) {
    // TODO
	int num;
	if (n % 2 != 0)
	{
		num = ilog2ceil(n);
		num = pow(2, num);
	}
	else num = n;
	int *_idata=new int[num];
	for (int i = 0; i < num; i++){
		_idata[i] = idata[i];
	}
	init(_idata, odata, num);
	
	//std::cout << ilog2ceil(4) << ilog2ceil(5);//2,3;	
	int logn = ilog2ceil(num);
	Nscan <<< 1, num >> >(num,logn,dev_A, dev_B,dev_C);

	cudaMemcpy(odata, dev_B, num* sizeof(int), cudaMemcpyDeviceToHost);//destination,source,
	cudaFree(dev_A);
	cudaFree(dev_B);
	cudaFree(dev_C);
	
    printf("2.1");
}

}
}
