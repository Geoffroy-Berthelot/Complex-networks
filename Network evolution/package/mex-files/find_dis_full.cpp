/* NETWORK FILE: find distance between two nodes (int version)  -----
 *
 *  Short CPP-file
 *  Try to find the distance between two nodes, alt. if there is a path between them.
 *  This is a 32bit version, wich limits N_0 = 2^32 ~ 4.2 * 10^9 Nodes
 *  For larger N_0, change type: uint32_t to uint64_t for example
 *  Using char array and the adjacency matrix as a int type ('A_type')
 *  Usage is:
 *  find_dis_double(uint32(adjm), in, out);
 *  where :
 *  'adjm' is the adjacency matrix, a MATLAB type, which sould be cast as an 'A_type' before use.
 *  'in' is the starting node
 *  'out' is the ending node
 */
#include "math.h"
#include "matrix.h"
#include "mex.h"    //--This one is required by matlab
#include <stdlib.h>
#include <stdint.h>
#include <cstdlib>
#include <string.h>
#include <cmath>

typedef uint8_t A_type;     // type of the adjacency matrix 'A' 
// should match the type of the one used in the Matlab file 'one network simulation.m'
typedef uint32_t int_type;  // type of the integers (which also determine N0)

/****************************************************************************/
/* Functions definitions                                                    */
/****************************************************************************/
void get_node_from_idx(const int_type, const int_type, int_type *);

/****************************************************************************/
/* Core Program                                                             */
/****************************************************************************/
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) 
{
    /***********************************
     *DECLARATIONS AND INITS
     ***********************************/
    //mxArray *A;
    int verbose = 0;    //if you want the function to be wordy.
    char *visited_nodes_idx;
    A_type    *A;
    int_type  *visited_nodes_in, *visited_nodes_out,
              size=0, size_old=0, size_new=0,
              size2=0, size2_old=0, size2_new=0,
              cpt,
              idx, nrows, i, j, k, d=0,
              in_idx, out_idx, node, cur_node;
    /*define output:*/
    double *output;
    bool is_found;

    //Check input parameters
    if (nrhs != 3)
       mexErrMsgTxt("Wrong number of inputs arguments: 3 arguments are required.");
    
    /*******************************
     * Gather Inputs and Outputs & Alloc. structures:
     *******************************/
    A           = (A_type *) mxGetData( prhs[0] );
    nrows       = mxGetN( (mxArray*) prhs[0] );
    in_idx      = mxGetScalar( prhs[1] );
    out_idx     = mxGetScalar( prhs[2] );
    
    if(verbose) {
        //print input argument (for debug):
        mexPrintf("in_idx = %d\n", in_idx);
        mexPrintf("out_idx = %d\n", out_idx);
        mexPrintf("nrows A = %d\n", nrows);
        mexPrintf("A[0] = %d\n", A[0]);
    }

    /*******************************
     * Build outputs
     *******************************/
    plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
    output = mxGetPr( plhs[0] );

     /*************************
     * Security checks: 
     *************************/   
    // if nodes are identical, then exit:
    if( in_idx == out_idx ) {
        output[0] = -1.0;
        return;
    }    
    
    // we check for input/output nodes being <= 0 (because MATLAB uses 1-based indexing)
    // similarly, we check for nodes greater than N0:
    if( in_idx <= 0 || in_idx > nrows || out_idx <= 0 || out_idx > nrows ) {
        output[0] = -1.0;
        return;
    }

    /*************************
     * Allocate and initialize arrays
     *************************/
    // The strategy is to avoid searching for nodes.
    // Thus, we use arrays of 'marked' nodes in order to know which node 
    // is in what list / array (i.e. visited_nodes_idx).
    // Build the array of visited nodes (can possibly contains all nodes)
    visited_nodes_in = (int_type *) malloc( (nrows-1) * sizeof(int_type) );
    visited_nodes_out = (int_type *) malloc( (nrows-1) * sizeof(int_type) );
    // nrows-1 because we don't include out_node (we exit before including it in the array)
    
    //array of visited nodes indexes:
    visited_nodes_idx = (char *) malloc( nrows * sizeof(char) );
    memset(visited_nodes_idx, '\0', nrows * sizeof(char) ); //set all values to '0'
    
    // Perform initializations: 
    // C/C++ uses 0-based indexing, and Matlab uses 1-based indexing:
    in_idx = in_idx -1;
    out_idx = out_idx -1;
    
    visited_nodes_in[ size++ ] = in_idx;    // append input node
    visited_nodes_out[ size2++ ] = out_idx; // append output node
   
    //mark them as already visited:
    visited_nodes_idx[ in_idx ] = 1;    //visited_nodes index array.
    visited_nodes_idx[ out_idx ] = 2;    //visited_nodes index array.
    
    /*************************
     * Algorithm
     *************************/
    is_found = 0;
    
    while( is_found == 0 ) {

        // ----- INPUT NODE direction
        // for all nodes in the current distance, we collect the connected nodes:
        size_new = size;
        cpt = 0;
        for(k = size_old; k < size; k++) {
            
            cur_node = visited_nodes_in[ k ]; 
            
            //then browse the connected nodes and collect them in the 'buffer'
            for(i=0; i < nrows; i++) {
                // Find nodes connected to the current node 'cur_node':
                idx = cur_node + i*nrows; //get linear index
                
                //will count the number of connected nodes and put them in the buffer array:
                if( A[ idx ] == 1 ) {

                    //get node from linear index:
                    get_node_from_idx(idx, nrows, &node);
                 
                    if( visited_nodes_idx[ node ] == '2' || node == out_idx ) {
                        output[0] = (double) d;

                        // free memory and return.
                        free( visited_nodes_idx );
                        free( visited_nodes_out );
                        free( visited_nodes_in );
                        return;
                    } else
                        // if this node was not already visited:
                        if( visited_nodes_idx[ node ] == '\0' )
                        {
                            // Not visited, thus we push it in the neighbors list:
                            visited_nodes_in[ size_new++ ] = node; //insert this new visited node
                            visited_nodes_idx[ node ] = '1';  //alter visited node array accordingly (mark '1' for INPUT direction)
                            cpt++;
                        }
                }
            }
        }

        if(cpt == 0) // no more neighbords: we didn't find the targeted node thus we exit.
            break;

        //update sizes:
        size_old = size;
        size = size_new;
        
        // ----- OUTPUT NODE direction
        // for all nodes in the current distance, we collect the connected nodes:
        size2_new = size2;
        cpt = 0;
        for(k = size2_old; k < size2; k++) {
            
            cur_node = visited_nodes_out[ k ]; 
            
            //then browse the connected nodes and collect them in the 'buffer'
            for(i=0; i < nrows; i++) {
                // Find nodes connected to the current node 'cur_node':
                idx = cur_node + i*nrows; //get linear index
                
                //will count the number of connected nodes and put them in the buffer array:
                if( A[ idx ] == 1 ) {

                    //get node from linear index:
                    get_node_from_idx(idx, nrows, &node);

                    if( visited_nodes_idx[ node ] == '1' ) {
                        output[0] = (double) d+1; //we remove 1 since \Delta = 0 means a direct link between the source and drain.

                        // free memory and return.
                        free( visited_nodes_idx );
                        free( visited_nodes_out );
                        free( visited_nodes_in );
                        return;
                    } else
                        // if this node was not already visited:
                        if( visited_nodes_idx[ node ] == '\0' )
                        {
                            // Not visited, thus we push it in the visited node list:
                            visited_nodes_out[ size2_new++ ] = node; //insert this new visited node
                            visited_nodes_idx[ node ] = '2';  //alter visited node array accordingly
                            cpt++;
                        }
                }
            }
        }
        
        if(cpt == 0) // no more neighbords: we didn't find the targeted node thus we exit.
            break;        

        //update sizes:
        size2_old = size2;
        size2 = size2_new;
        
        //and we update the distance:
        d = d + 2;
    }
    
    //to check: if we browsed all nodes and did not found the requested node, then we send a particular value (=-1)
    if( is_found == 0 )
        output[0] = -1.0; //means there is no connection between the two nodes.
    else
        output[0] = (double) d-1; //we remove 1 since \Delta = 0 means a direct link between the source and drain.
    
    // free memory and return.
    free( visited_nodes_idx );
    free( visited_nodes_out );
    free( visited_nodes_in );

    return;
}


/************************
 * returns node index from linear index 
 * (modulo and 0-based)
 ************************/
void get_node_from_idx(const int_type idx, const int_type nrows, int_type *node) {
    *node = (idx - idx % nrows) / nrows;
}
