#include <cuda.h>
#include <cuda_runtime.h>
#include "common.h"
#include "efficient.h"
#include <iostream>
int *dev_A1;
int *dev_B1;

namespace StreamCompaction {
namespace Efficient {

// TODO: __global__

/**
 * Performs prefix-sum (aka scan) on idata, storing the result into odata.
 */
__global__ void Uscan(int p1, int p2, int *od){
		int thid = threadIdx.x*2*p1;
		//od[thid + p1 - 1] = id[thid + p1 - 1];
		//od[thid + p2 - 1] = id[thid + p2 - 1];

		od[thid + p2 - 1] += od[thid + p1 - 1];
		
	}
__global__ void put0(int * odata, int n)
	{
				odata[n - 1] = 0;
			}

__global__ void Dscan(int p1,int p2,int *od){

		int thid = threadIdx.x*2*p1;
			
		//od[thid + p1 - 1] = id[thid + p1 - 1];
		//od[thid + p2 - 1] = id[thid + p2 - 1];
		//if (thid == n) { od[n - 1] = 0; }
		int t = od[thid +p1 - 1];//
		od[thid + p1 - 1] = od[thid + p2 - 1];
		od[thid + p2 - 1] += t;
		}


	
void init(int n, const int *hst_A){

	int _size = n*sizeof(int);
	cudaMalloc((void**)&dev_A1, _size);
	cudaMemcpy(dev_A1, hst_A, _size, cudaMemcpyHostToDevice);


}


void scan(int n, int *odata, const int *idata) {
    // TODO

	//dev_A1,dev_B1
	int p1,p2;
	int num;
	if (n % 2 != 0)
	{
		num = ilog2ceil(n);
		num = pow(2, num);
	}
	else num = n;
	int *_idata = new int[num];
	init(num, idata);
	float ms=0;
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start);
	cudaEventRecord(stop);
	cudaEventSynchronize(stop);

	cudaEventElapsedTime(&ms, start, stop);
	for (int d = 0; d <= ilog2ceil(num) - 1; d++){
		p1 = pow(2, d);
		p2 = pow(2, d + 1);
		Uscan << <1, 512 >> >(p1, p2, dev_A1);
	}
	put0 << <1, 1 >> >(dev_A1, num);
	for (int d = ilog2ceil(num) - 1; d >= 0; d--){
		p1 = pow(2, d);
		p2 = pow(2, d + 1);
		Dscan << <1, 512 >> >(p1, p2, dev_A1);
	
	}
	cudaEventSynchronize(stop);

	cudaEventElapsedTime(&ms, start, stop);
	printf("\t time of 3.1 efficient function1: %f ms\n", ms);
	cudaMemcpy(odata, dev_A1, num* sizeof(int), cudaMemcpyDeviceToHost);//destination,source,
	cudaFree(dev_A1);

    printf("3.1\n");
}

/**
 * Performs stream compaction on idata, storing the result into odata.
 * All zeroes are discarded.
 *
 * @param n      The number of elements in idata.
 * @param odata  The array into which to store elements.
 * @param idata  The array of elements to compact.
 * @returns      The number of elements remaining after compaction.
 */ 
int *dev_idata;
int *dev_odata;
int *dev_indices;
int *dev_bool;
int *dev_boolb;

int compact(int n, int *odata, const int *idata) {
    // TODO
	int num;
	if (n % 2 != 0)
	{
		num = ilog2ceil(n);
		num = pow(2, num);
	}
	else num = n;

	int _size = num*sizeof(int);

	cudaMalloc((void**)&dev_bool, _size);
	cudaMalloc((void**)&dev_boolb, _size);
	cudaMalloc((void**)&dev_odata, _size);
	cudaMalloc((void**)&dev_idata, _size);
	cudaMemcpy(dev_idata, idata, _size, cudaMemcpyHostToDevice);

	int p1, p2;
	int hst;
	int last;
	//step 1

	Common::kernMapToBoolean <<< 1, n >>>(n, dev_bool, dev_idata);
	Common::kernMapToBoolean << < 1, n >> >(n, dev_boolb, dev_idata);//back_up
	//cudaMemcpy(&hst, &dev_idata[6],sizeof(int), cudaMemcpyDeviceToHost);
	//std::cout << hst;
   //Step 2 

	for (int d = 0; d <= ilog2ceil(num) - 1; d++){
			p1 = pow(2, d);
			p2 = pow(2, d + 1);
			Uscan <<<1, num >> >(p1, p2, dev_boolb);//change end to n
				}
	put0 <<<1, 1 >> >(dev_boolb, num);
	//cudaMemcpy(&hst, &dev_idata[6], sizeof(int), cudaMemcpyDeviceToHost);
	//std::cout << hst << "ss1";
	for (int d = ilog2ceil(num) - 1; d >= 0; d--){
			p1 = pow(2, d);
			p2 = pow(2, d + 1);
			Dscan <<<1, num >> >(p1, p2, dev_boolb);
			}


	//???????????my dev_idata changed its value here...have no idea why.
	cudaMemcpy(dev_idata, idata, _size, cudaMemcpyHostToDevice);
    ////???????????????????????/////////////
	//cudaMemcpy(&hst, &dev_idata[6], sizeof(int), cudaMemcpyDeviceToHost);
	//std::cout << hst << "ss2";
    //Step 3 : Scatter
	//cudaMemcpy(&hst, &dev_idata[2],sizeof(int), cudaMemcpyDeviceToHost);
	//std::cout << hst;
	cudaMemcpy(&last, &(dev_boolb[num - 1]), sizeof(int), cudaMemcpyDeviceToHost);
	//cudaMalloc((void**)&dev_odata, last*sizeof(int));

	Common::kernScatter <<<1, num >> >(last, dev_odata, dev_idata, dev_bool, dev_boolb);

	cudaMemcpy(odata, dev_odata, last*sizeof(int), cudaMemcpyDeviceToHost);
	
	printf("3.2\n");
    return last;
}

}
}
