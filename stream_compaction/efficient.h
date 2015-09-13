#pragma once

namespace StreamCompaction {
namespace Efficient {
    void scan(int n, int *odata, const int *idata);
	void init(int n,const int*b);
    int compact(int n, int *odata, const int *idata);
}
}
