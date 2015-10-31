//
//  main.m
//  Metal
//
//  Created by Marrony Neris on 10/29/15.
//  Copyright © 2015 Marrony Neris. All rights reserved.
//

#import <Metal/Metal.h>

id<MTLLibrary> get_library(id<MTLDevice> device) {
    NSError *error;
    
    NSString* source = [NSString stringWithContentsOfFile: @"Kernels.metal"
                                              encoding: NSUTF8StringEncoding
                                                 error: &error];

    if(source != nil) {
        return [device newLibraryWithSource: source options: nil error: &error];
    }
    
    return [device newDefaultLibrary];
}

int main(int argc, const char * argv[]) {
    NSError *error;
    
    int values[] = {1, 2, 3, 4,
                    5, 6, 7, 8,
                    9, 10, 11, 12,
                    13, 14, 15, 16};
    int num_elements = sizeof(values) / sizeof(int);
    
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    id<MTLLibrary> defaultLibrary = get_library(device);
    id<MTLCommandQueue> commandQueue = [device newCommandQueue];
    id<MTLFunction> kernel = [defaultLibrary newFunctionWithName: @"kernel_reduce"];
    id<MTLComputePipelineState> computePipeline = [device newComputePipelineStateWithFunction: kernel error: &error];
    
    id<MTLBuffer> inputBuffer = [device newBufferWithBytes: values length: sizeof(values) options: 0];
    id<MTLBuffer> outputBuffer = [device newBufferWithLength: sizeof(values) options: 0];
    
    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
    id<MTLComputeCommandEncoder> commandEncoder = [commandBuffer computeCommandEncoder];
    [commandEncoder setComputePipelineState: computePipeline];
    [commandEncoder setBuffer: inputBuffer offset: 0 atIndex: 0];
    [commandEncoder setBuffer: outputBuffer offset: 0 atIndex: 1];
    
    MTLSize numThreadgroups = {16, 1, 1};
    MTLSize threadsGroup = {1, 1, 1};
    [commandEncoder dispatchThreadgroups: threadsGroup threadsPerThreadgroup: numThreadgroups];
    [commandEncoder endEncoding];
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];

    int* contents = (int*)[outputBuffer contents];

    for(int i = 0; i < num_elements; i++)
        printf("%d ", contents[i]);
    printf("\n");
    
    return 0;
}
