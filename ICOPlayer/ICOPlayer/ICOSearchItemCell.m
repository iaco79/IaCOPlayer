//
//  ICOSearchItemCell.m
//  ICOPlayer
//
//  Created by Othon Cruz on 4/12/16.
//  Copyright © 2016 Othon Cruz. All rights reserved.
//

#import "ICOSearchItemCell.h"
#import "ICOFileHelper.h"

@interface  ICOSearchItemCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageIcon;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIView *linkContainer;
@property (weak, nonatomic) IBOutlet UIImageView *imgFavorite;

@property (weak, nonatomic) IBOutlet UILabel *linkLabel;
@end


@implementation ICOSearchItemCell





- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        

        
    }
    
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
    if(selected)
    {
        UIView * selectedBackgroundView = [[UIView alloc] init];
        [selectedBackgroundView setBackgroundColor:[UIColor darkGrayColor]];
        [self setSelectedBackgroundView:selectedBackgroundView];
        
    }
    else
    {
    
        UIView * selectedBackgroundView = [[UIView alloc] init];
        [selectedBackgroundView setBackgroundColor:[UIColor blackColor]];
        [self setSelectedBackgroundView:selectedBackgroundView];

        
    }
    
}


-(void) setVideoLink :(ICOVideoLink*) videoLink
{
    
    CGRect labelFrame = CGRectMake(0,0, self.linkContainer.frame.size.width, self.linkContainer.frame.size.height);
    
    self.title.text  = videoLink.linkDescription;
    self.linkLabel.text = videoLink.linkURL;
    self.linkLabel.frame = labelFrame;
    [self.linkLabel sizeToFit];
    
    NSString* iconimage = [NSString stringWithFormat:@"%@", videoLink.linkIcon];
    
    if ([iconimage hasPrefix:@"ICOIMG"])
    {
        ICOFileHelper* fh = [ICOFileHelper new];
        NSString* imagePath = [fh getFilePath:iconimage];
        [self.imageIcon setImage: [UIImage imageWithContentsOfFile: imagePath]];
        
    }
    else
    {
        [self.imageIcon setImage: [UIImage imageNamed: iconimage]];
    }

    
    if (videoLink.linkFavorite == 1)
        [self.imgFavorite setImage:[UIImage imageNamed: @"ic_favs"]];
    else
        [self.imgFavorite setImage:[UIImage imageNamed: @"ic_favs_inactive"]];
    
}

@end
