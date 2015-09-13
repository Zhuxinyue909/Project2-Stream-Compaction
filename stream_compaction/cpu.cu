#include <cstdio>
#include "cpu.h"
#include<math.h>
#include<iostream>
namespace StreamCompaction {
	namespace CPU {

		/**
		 * CPU scan (prefix sum).
		 */
		void scan(int n, int *odata, const int *idata) {//b,a
			// TODO
			odata[0] = 0;
			if (n > 1){
				for (int i = 1; i < n; i++){
					odata[i] = idata[i - 1] + odata[i - 1];
				}
			}
			std::cout << "1.1";

		}

		/**
		 * CPU stream compaction without using the scan function.
		 *
		 * @returns the number of elements remaining after compaction.
		 */
		int compactWithoutScan(int n, int *odata, const int *idata) {
			// TODO
			//int *p = odata;
			
			int count = 0;
			for (int i = 0; i < n; i++){
				if (idata[i] != 0){
					odata[count] = idata[i];
					count++;
				}
			
			}
			std::cout << "1.2"<<std::endl;
			return count;
		}

		/**
		 * CPU stream compaction using scan and scatter, like the parallel version.
		 *
		 * @returns the number of elements remaining after compaction.
		 */
		int compactWithScan(int n, int *odata, const int *idata) {
			// TODO
			int t = 0;
			int *temp = new int[n];
			int *scan = new int[n];
			for (int i = 0; i < n; i++){ temp[i] = 0; scan[i] = 0;}
			for (int i = 0; i < n; i++){
				if (idata[i] != 0){
					temp[i] = 1;			
				}
				else {
					temp[i] = 0;		
				}
			}
			for (int i = 1; i < n; i++){
				scan[i] = temp[i - 1] + scan[i - 1];	
			}
			
			int index = 0;
			for (int i = 0; i < n-1; i++){
				if (scan[i] != scan[i + 1]){
					t = scan[i];
					odata[index] = idata[i];
					index++;
				}

			}
			std::cout << "1.3"<<std::endl;
			return scan[n - 1];
		
		}
	}
}
	//scan
	/*scan[0] = 0;
	for (int i = 0; i < n; i++){
		scan[i] = temp[i - 1] + scan[i - 1];
	}
	//scatter
	for (int i = 0; i < n; i++){
		if (scan[i] != scan[i + 1]){
			t = scan[i];
			*odata = idata[t];
			*odata++;
		}
		else continue;
	
	}
    return scan[n-1];
}

}*/

