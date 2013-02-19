//
//  Section.h
//  parsing2
//
//  Created by Ivan Tsanev on 18/02/2013.
//  Copyright (c) 2013 Ivan Tsanev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Story;

@interface Section : NSManagedObject

@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * savedTitle;
@property (nonatomic, retain) NSString * savedRssPath;
@property (nonatomic, retain) NSSet *stories;
@end

@interface Section (CoreDataGeneratedAccessors)

- (void)addStoriesObject:(Story *)value;
- (void)removeStoriesObject:(Story *)value;
- (void)addStories:(NSSet *)values;
- (void)removeStories:(NSSet *)values;

@end
