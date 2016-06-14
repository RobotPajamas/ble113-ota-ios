//
// Created by Suresh Joshi on 15-03-07.
// Copyright (c) 2015 Robot Pajamas. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface RPJDataChunker : NSObject

/*
 * Returns the length of the internal backing data
 */
@property(readonly, nonatomic) NSUInteger length;

/*
 * Returns the length remaining in the backing data
 */
@property(readonly, nonatomic) NSUInteger remainingLength;

/*
 * The desired size of each chunk
 */
@property(readonly, nonatomic) NSUInteger chunkLength;

/*
 * The number of full chunks, based on chunkLength and data length
 * This excludes the partial remainderChunkLength, if any
 */
@property(readonly, nonatomic) NSUInteger totalChunks;

/*
 * This is the leftover data and will be smaller than chunkLength
 */
@property(readonly, nonatomic) NSUInteger remainderChunkLength;

/*
 * Which chunk we're currently on
 */
@property(readonly, nonatomic) NSUInteger currentChunk;

/**
* Initializes DataChunker with NSData and chunk length
* @param aData instance of NSData to load into chunker
* @param aChunkLength the desired length to chunk up the data into
* @return Initialized DataChunker Instance pre-loaded with NSData
*/
- (instancetype)initWithData:(NSData *)aData
                 chunkLength:(NSUInteger)aChunkLength;

/**
* Returns the 'next' chunk of data
* @return NSData representing the subsequent chunk of data
*/
- (NSData *)next;

/**
* Returns whether or not there is any data to transfer
* @return Boolean indicating if there is any more data to transfer
*/
- (BOOL)hasNext;

/**
* Resets the chunk pointer to the beginning of the internal data
*/
- (void)reset;

@end