//
//  Kernels.metal
//  Metal
//
//  Created by Marrony Neris on 10/30/15.
//  Copyright © 2015 Marrony Neris. All rights reserved.
//

#include <metal_stdlib>
#include <metal_compute>

using namespace metal;

//[[ thread_position_in_grid ]]      = global_id
//[[ thread_position_in_threadgroup ]]
//[[ thread_index_in_threadgroup ]]  = local_id
//[[ threadgroup_position_in_grid ]] = group_id
//[[ threads_per_grid ]]             = global_size
//[[ threads_per_threadgroup ]]      = local_size
//[[ threadgroups_per_grid ]]        =
//[[ thread_execution_width ]]

kernel void kernel_map(uint global_idx [[ thread_position_in_grid ]],
                       constant int* input [[ buffer(0) ]],
                       device int* output [[ buffer(1) ]]) {
    int value = input[global_idx];
    
    output[global_idx] = value * value;
}

kernel void kernel_reduce(uint2 global_id [[ thread_position_in_grid ]],
                        uint local_id [[ thread_index_in_threadgroup ]],
                        uint2 block_size [[ threads_per_threadgroup ]],
                        uint2 group_id [[ threadgroup_position_in_grid ]],
                        uint2 group_size [[ threadgroups_per_grid ]],
                        uint2 global_size [[ threads_per_grid ]],
                        device int* input [[ buffer(0) ]],
                        device int* output [[ buffer(1) ]]) {
    
    for(uint i = block_size.x/2; i > 0; i >>= 1) {
        if(local_id < i)
            input[global_id.x] += input[global_id.x + i];

        //threadgroup_barrier(mem_flags::mem_none);
        //threadgroup_barrier(mem_flags::mem_device);
        //threadgroup_barrier(mem_flags::mem_threadgroup);
        threadgroup_barrier(mem_flags::mem_device_and_threadgroup);
    }

    if(local_id == 0)
        output[group_id.x] = input[global_id.x];
}
