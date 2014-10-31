#include <mex.h>
#include <vector>

void mexFunction(int num_outputs, mxArray ** outputs,
                 int num_inputs, const mxArray ** inputs)
{
    if (num_inputs != 5)
    {
        mexErrMsgTxt("Expected 5 input arguments.");
    }
    if (num_outputs != 3)
    {
        mexErrMsgTxt("Expected 3 output argument.");
    }
    
    const mxArray * input_indices1 = inputs[0];
    const mxArray * input_indices2 = inputs[1];
    const mxArray * input_max_index = inputs[2];
    const mxArray * input_mat_height = inputs[3];
    const mxArray * input_common_segments = inputs[4];
    
    const int num_indices1 = mxGetN(input_indices1);
    const int num_indices2 = mxGetN(input_indices2);
    const int num_common = mxGetN(input_common_segments);
    
    const char * indices1_ptr = (const char *)mxGetData(input_indices1);
    const char * indices2_ptr = (const char *)mxGetData(input_indices2);
    const double * max_index_ptr = (const double *)mxGetData(input_max_index);
    const double * mat_height_ptr = (const double *)mxGetData(input_mat_height);
    const char * common_segments_ptr = (const char *)mxGetData(input_common_segments);
    
    const int num_bins = static_cast<int>(*max_index_ptr);
    const int mat_height = static_cast<int>(*mat_height_ptr);
    
    std::vector<std::vector<int> > bins1;
    std::vector<std::vector<int> > bins2;
    bins1.resize(num_bins);
    bins2.resize(num_bins);
    
    std::vector<bool> common_bins;
    common_bins.resize(num_bins);
    
    for (int i = 0; i < num_bins; ++i)
    {
        common_bins[i] = false;
    }
    
    for (int i = 0; i < num_common; ++i)
    {
        const char bin = common_segments_ptr[i];
        common_bins[bin] = true;
    }
    
    mxArray * output_near_common1 = mxCreateNumericMatrix(0, 0, mxLOGICAL_CLASS, mxREAL);
    mxSetM(output_near_common1, 1);
    mxSetN(output_near_common1, num_indices1);
    mxSetData(output_near_common1, mxMalloc(sizeof(bool) * num_indices1));
    bool * output_near_common1_ptr = (bool *)mxGetData(output_near_common1);
    
    for (int i = 0; i < num_indices1; ++i)
    {
        const char bin = indices1_ptr[i];
        if (bin >= 0)
        {
            /*if (bin < 0 || bin >= num_bins)
            {
                mexPrintf("%d / %d\n", bin, num_bins);
                mexErrMsgTxt("Bin out of range.");
            }*/
            bins1[bin].push_back(i + 1);
            
            if (common_bins[bin])
            {
                output_near_common1_ptr[i] = true;
            }
            else
            {
                output_near_common1_ptr[i] = false;
            }
        }
        else
        {
            output_near_common1_ptr[i] = false;
        }
    }
    
    mxArray * output_near_common2 = mxCreateNumericMatrix(0, 0, mxLOGICAL_CLASS, mxREAL);
    mxSetM(output_near_common2, 1);
    mxSetN(output_near_common2, num_indices2);
    mxSetData(output_near_common2, mxMalloc(sizeof(bool) * num_indices2));
    bool * output_near_common2_ptr = (bool *)mxGetData(output_near_common2);
    
    for (int i = 0; i < num_indices2; ++i)
    {
        const char bin = indices2_ptr[i];
        if (bin >= 0)
        {
            /*if (bin < 0 || bin >= num_bins)
            {
                mexPrintf("%d / %d\n", bin, num_bins);
                mexErrMsgTxt("Bin out of range.");
            }*/
            bins2[bin].push_back(i + 1);
            if (common_bins[bin])
            {
                output_near_common2_ptr[i] = true;
            }
            else
            {
                output_near_common2_ptr[i] = false;
            }
        }
        else
        {
            output_near_common2_ptr[i] = false;
        }
    }
    
    int num_results = 0;
    for (int i = 0; i < num_bins; ++i)
    {
        if (bins1[i].size() > 0 && bins2[i].size() > 0)
        {
            num_results += bins1[i].size() * bins2[i].size();
        }
    }
    
    mxArray * output_indices = mxCreateNumericMatrix(0, 0, mxINT32_CLASS, mxREAL);
    mxSetM(output_indices, num_results);
    mxSetN(output_indices, 1);
    mxSetData(output_indices, mxMalloc(sizeof(int) * num_results));
    
    int * output_ptr = (int *)mxGetData(output_indices);
    
    int idx = 0;
    for (int b = 0; b < num_bins; ++b)
    {
        const int size1 = bins1[b].size();
        const int size2 = bins2[b].size();
        if (size1 > 0 && size2 > 0)
        {
            for (int j = 0; j < size2; ++j)
            {
                for (int i = 0; i < size1; ++i)
                {
                    output_ptr[idx] = bins1[b][i] + (bins2[b][j] - 1) * mat_height;
                    ++idx;
                }
            }
        }   
    }
    
    outputs[0] = output_indices;
    outputs[1] = output_near_common1;
    outputs[2] = output_near_common2;
}
