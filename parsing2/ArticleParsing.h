//
//  ArticleParsing.h
//  parsing2
//
//  Created by Ivan Tsanev on 29/01/2013.
//  Copyright (c) 2013 Ivan Tsanev. All rights reserved.
//


@interface ArticleParsing : NSObject


- (void)doparse:(NSData *)receivedData;
- (ArticleParsing *) initArticleParsing;

@property (nonatomic, strong) NSMutableArray *stories;

@end

