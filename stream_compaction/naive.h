#pragma once

namespace StreamCompaction {
namespace Naive {
    void scan(int n, int *odata, const int *idata);
	void init(int *hst_idata,int *hst_odata,int n);
	//int *dev_A;
	//int *dev_B;
}
}
