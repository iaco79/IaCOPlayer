#import "VideoLink.h"
#import "ICOVideoLink.h"
@interface VideoLink ()

// Private interface goes here.

@end

@implementation VideoLink

// Custom logic goes here.

-(void) updateWithICOVideoLink: (ICOVideoLink*) icoVideoLink
{
    self.videoIcon = icoVideoLink.linkIcon;
    self.videoDescription = icoVideoLink.linkDescription;
    self.videoFavorite = [NSNumber numberWithInteger: icoVideoLink.linkFavorite];
    self.videoOrder =  [NSNumber numberWithInteger: icoVideoLink.linkOrder];
    self.videoUrl  = icoVideoLink.linkURL;
    

}
@end
