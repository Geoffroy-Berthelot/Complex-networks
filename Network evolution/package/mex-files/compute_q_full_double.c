/* NETWORK FILE: compute flow for each node (double version) -----
 *
 *  Short C-file
 *  Prepare the linear system before solving.
 *  
 */
#include "math.h"
#include "matrix.h"
#include "mex.h"   //--This one is required by matlab
#include <stdlib.h>


/****************************************************************************/
/* Core Program                                                             */
/****************************************************************************/
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) 
{
    /***********************************
     *DECLARATIONS AND INITS
     ***********************************/
    int i, j, k, nrows, dim, inflow_idx;
    int verbose = 0; //if you want the function to be wordy.
    double *A, *D, *M, *S, sum, *F;
    //inflow_idx is the index of inflow node
    //A is the Adjacency matrix
    //D is the euclidean matrix

    //Check input parameters
    if (nrhs != 3)
       mexErrMsgTxt("Wrong number of inputs arguments: 3 arguments are required.");
    
    /*******************************
     * Gather Inputs and Outputs & Alloc structures:
     *******************************/
    //Get network structure:
    inflow_idx = (int) mxGetPr(mxGetField(prhs[0],0,"inflow"))[0];
    inflow_idx = inflow_idx -1; //because C indexs starts at 0!
    A = mxGetPr(mxGetField(prhs[0],0,"adjm"));
    D = mxGetPr(mxGetField(prhs[0],0,"dis_eucl"));
    nrows = (int)*mxGetPr(prhs[1]); //gather size (square lattice: nrows == ncols)
    F = mxGetPr(prhs[2]); //F vector (size == nrows)
    
    if(verbose) {
        //print input argument (for debug):
        mexPrintf("inflow_idx = %d\n", inflow_idx+1);
        mexPrintf("nrows (A,D) = %d\n", nrows);
        mexPrintf("ncols (A,D) = %d\n", nrows);
        mexPrintf("A[1] = %f\n", A[0]);
        mexPrintf("F[3] = %f\n", F[3]);
    }
    
    //Build outputs (also serves as a Prealloc):
    plhs[0] = mxCreateDoubleMatrix(nrows, nrows, mxREAL);
    M = mxGetPr(plhs[0]);
    
    //START GATHERING THE FLUXs:
    for(i=0; i < nrows; i++) {
        sum = 0; //reset sum
        //for this particular 'i' node, perform operation on connected nodes:
        for(j=0; j < nrows; j++) {
            if( A[i*nrows+j] == 1.0 ) {
                //-(F(1) - F(2)) / netw.dis_eucl(1,2)
                //Get q value:
                M[j*nrows+i] = -(F[i] - F[j]) / D[i*nrows+j];
            }
        }
    }
    return;
}

