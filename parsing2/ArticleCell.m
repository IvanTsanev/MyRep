//
//  ArticleCell.m
//  MyCoreData
//


#import "ArticleCell.h"
#import <QuartzCore/QuartzCore.h>

#define FONT_SIZE 14.0f

@implementation ArticleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.label = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.label setLineBreakMode:NSLineBreakByCharWrapping];
        [self.label setMinimumScaleFactor:FONT_SIZE];
        [self.label setNumberOfLines:0];
        [self.label setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        [[self.label layer] setBorderWidth:2.0f];
        [[self contentView] addSubview:self.label];
        

    }
    
    return self;
}

@end
