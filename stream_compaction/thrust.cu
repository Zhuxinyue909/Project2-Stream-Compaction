#include <cuda.h>
#include <cuda_runtime.h>
#include <thrust/device_vector.h>
#include <thrust/host_vector.h>
#include <thrust/scan.h>
#include "common.h"
#include "thrust.h"

namespace StreamCompaction {
namespace Thrust {

/**
 * Performs prefix-sum (aka scan) on idata, storing the result into odata.
 */
void scan(int n, int *odata, const int *idata) {
    // TODO use `thrust::exclusive_scan`
    // example: for device_vectors dv_in and dv_out:
    // thrust::exclusive_scan(dv_in.begin(), dv_in.end(), dv_out.begin());

	thrust::device_vector<int> dv_in,dv_out;
	for (int i = 0; i < n; i++){
		dv_in.push_back(idata[i]);
		dv_out.push_back(0);
	}
	thrust::exclusive_scan(dv_in.begin(), dv_in.end(), dv_out.begin());
	thrust::copy(dv_out.begin(), dv_out.end(), odata);


	printf("4.1");

		
}



}

}

