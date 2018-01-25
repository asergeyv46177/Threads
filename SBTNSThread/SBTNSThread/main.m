//
//  main.m
//  SBTNSThread
//
//  Created by Sergey Altukhov on 14.01.2018.
//  Copyright © 2018 Sergey Altukhov. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool
    {
        NSCondition *condition = [NSCondition new];
        NSUInteger parallelTasksCount = [[NSProcessInfo processInfo] activeProcessorCount];
        NSArray <NSNumber *> *collection;
        NSArray *templateCollection = @[@(1),@(2),@(3),@(4),@(5),@(6),@(7),@(8),@(9),@(10),@(11),@(12),@(13),@(14),@(15)];
        NSUInteger multiplier = 10000;
        NSMutableArray *tmp = [[NSMutableArray alloc] initWithCapacity:templateCollection.count*multiplier];
        for (NSUInteger i=0; i<=multiplier; ++i)
        {
            [tmp addObjectsFromArray:templateCollection];
        }
        collection = [tmp copy];
        __block NSInteger totalsSum = 0;
        __block NSUInteger predicate = 0;
        NSTimeInterval startTime = [NSDate new].timeIntervalSince1970;
        for (int i = 0; i < parallelTasksCount; ++i)
        {
            NSThread *thread = [[NSThread alloc] initWithBlock:^{
                @autoreleasepool
                {
                    NSUInteger addition = collection.count%parallelTasksCount;
                    
                    NSUInteger length = collection.count/parallelTasksCount;
                    NSUInteger step = collection.count/parallelTasksCount;
                    
                    if ( addition!=0 && i==(parallelTasksCount-1) )
                    {
                        length = length+addition;
                    }
                    
                    NSRange range = NSMakeRange(i*step, length);
                    
                    NSUInteger sum = 0;
                    for (NSUInteger i=range.location; i<(range.location+range.length); ++i)
                    {
                        sum = sum + collection[i].integerValue;
                    }
                    
                    [condition lock];
                    totalsSum+=sum;
                    predicate++;
                    if (predicate == parallelTasksCount)
                    {
                        [condition signal];
                    }
                    [condition unlock];
                }
            }];
            [thread start];
        }
        [condition wait];
        NSTimeInterval endTime = [NSDate new].timeIntervalSince1970;
        NSLog(@"Totals sum: %li", totalsSum);
        NSLog(@"Totals sum: %f", endTime - startTime);
    }
    return 0;
}
