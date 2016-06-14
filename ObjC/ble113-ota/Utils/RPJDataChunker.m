//
// Created by Suresh Joshi on 15-03-07.
// Copyright (c) 2015 Robot Pajamas. All rights reserved.
//

#import "RPJDataChunker.h"

@interface RPJDataChunker()

/*
 * The internally backing storage for the data chunker
 */
@property(strong, nonatomic) NSData *data;


@end

@implementation RPJDataChunker

- (instancetype)initWithData:(NSData *)aData
                 chunkLength:(NSUInteger)aChunkLength {
    if (self = [super init]) {
        [self setData:aData];
        _chunkLength = aChunkLength;
        _length = [aData length];

        // Pointers that will continually need updating
        _currentChunk = 0;
        _remainingLength = _length;

        // Calculate how many chunks will be needed
        _totalChunks = _length / _chunkLength;
        _remainderChunkLength = _length % _chunkLength;
    }

    return self;
}

- (NSData *)next {
    NSUInteger rangeStart = _currentChunk * _chunkLength;
    if (rangeStart + _chunkLength > _length) {
        return nil;
    }

    // Update pointers
    ++_currentChunk;
    _remainingLength -= _chunkLength;

    return [self.data subdataWithRange:NSMakeRange(rangeStart, _chunkLength)];
}

- (BOOL)hasNext {
    return _remainingLength > 0;
}

- (void)reset {
    _currentChunk = 0;
    _remainingLength = _length;
}

@end