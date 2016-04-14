//
//  ICOFavoriteCell
//  ICOPlayer
//
//  Created by Othon Cruz on 4/9/16.
//  Copyright © 2016 Othon Cruz. All rights reserved.
//

#import "ICOFavoriteCell.h"
#import "ICOFileHelper.h"



@interface ICOFavoriteCell ()

@property (weak, nonatomic) IBOutlet UILabel *lblProgram;
@property (weak, nonatomic) IBOutlet UILabel *lblSchedule;
@property (weak, nonatomic) IBOutlet UIImageView *cellImage;
@property (weak) ICOVideoLink* currentLink;



@end

@implementation ICOFavoriteCell
{
    
}



- (void)setVideoLink:(ICOVideoLink *)videoLink
{
    
    self.currentLink= videoLink;
    NSString* iconimage = [NSString stringWithFormat:@"%@", videoLink.linkIcon];
    NSString* otherInfo= @"";
    NSString* showDescription = videoLink.linkDescription;
    
    
    if ([iconimage hasPrefix:@"ICOIMG"])
    {
        ICOFileHelper* fh = [ICOFileHelper new];
        NSString* imagePath = [fh getFilePath:iconimage];
       [self.cellImage setImage: [UIImage imageWithContentsOfFile: imagePath]];
        
    }
    else
        [self.cellImage setImage: [UIImage imageNamed: iconimage]];
    
    
    self.lblProgram.text = showDescription;
    self.lblSchedule.text = otherInfo;

    
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.cellImage.alpha = highlighted ? 0.75f : 1.0f;
}


- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        
    }
    
    return self;
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
