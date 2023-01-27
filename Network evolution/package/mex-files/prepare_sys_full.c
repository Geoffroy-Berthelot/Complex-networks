/* NETWORK FILE: prepare linear system (int version) -----
 *
 *  Short C-file
 *  Prepare the linear system before solving.
 *  The adjacency matrix should be casted as an uint32 type before use.
 *  
 */
#include "math.h"
#include "matrix.h"
#include "mex.h"   //--This one is required by matlab
#include <stdlib.h>
#include <stdint.h>

typedef uint8_t A_type;     // type of the adjacency matrix 'A' 
// should match the type of the one used in the Matlab file 'one network simulation.m'
typedef uint32_t int_type;  // type of the integers (which also determine N0)

/****************************************************************************/
/* Core Program                                                             */
/****************************************************************************/
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) 
{
    /***********************************
     *DECLARATIONS AND INITS
     ***********************************/
    int_type i, j, k, nrows, dim, inflow_idx;
    int verbose = 0; //if you want the function to be wordy.
    A_type *A;
    double *D, *P, *S, sum;
    //inflow_idx is the index of inflow node
    //A is the Adjacency matrix
    //D is the euclidean matrix

    //Check input parameters
    if (nrhs != 2)
       mexErrMsgTxt("Wrong number of inputs arguments: 2 arguments are required.");
    
    /*******************************
     * Gather Inputs and Outputs & Alloc structures:
     *******************************/
    //Get network structure:
    inflow_idx = (int_type) mxGetPr(mxGetField(prhs[0],0,"inflow"))[0];
    inflow_idx = inflow_idx -1; //because C indexing starts at 0!
    A = mxGetPr(mxGetField(prhs[0],0,"adjm"));
    D = mxGetPr(mxGetField(prhs[0],0,"dis_eucl"));
    nrows = (int_type)*mxGetPr(prhs[1]); //gather size (square lattice: nrows == ncols)
    
    if(verbose) {
        //print input argument (for debug):
        mexPrintf("inflow_idx = %d\n", inflow_idx+1);
        mexPrintf("nrows (A,D) = %d\n", nrows);
        mexPrintf("ncols (A,D) = %d\n", nrows);
        mexPrintf("A[1] = %d\n", A[0]);
    }
    
    //Build outputs (also serves as a Prealloc):
    plhs[0] = mxCreateDoubleMatrix(nrows, nrows, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(nrows, 1, mxREAL);
    P = mxGetPr(plhs[0]);
    S = mxGetPr(plhs[1]);
    
    //START PREPARATION ALGORITHM:
    for(i=0; i < nrows; i++) {
        sum = 0; //reset sum
        //for this particular 'i' node, perform operation on connected nodes:
        for(j=0; j < nrows; j++) {
            if( A[i*nrows+j] == 1 ) {
                if(j == inflow_idx) {
                    //if this node is connected to the inflow node:
                    S[i] = -1 / D[i*nrows+j]; //assign to output S.
                    //do not assign any value to P
                    sum += 1 / D[i*nrows+j];
                } else {
                    //This is a 'standard' node, with no connection to the inflow node!
                    //P[i*nrows+j] = 1 / D[i*nrows+j]; //assign 1/d to P[i,j] //to transpose
                    P[j*nrows+i] = 1 / D[i*nrows+j]; //assign 1/d to P[i,j]
                    sum += 1 / D[i*nrows+j];
                }
            }
        }
        //assign sum to node P[i,i]:
        P[i*nrows+i] = -sum;
    }
    return;
}

