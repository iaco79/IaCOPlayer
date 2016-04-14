//
//  ICOFavoritesViewController
//  ICOPlayer
//
//  Created by Othon Cruz on 4/9/16.
//  Copyright © 2016 Othon Cruz. All rights reserved.
//

#import "ICOFavoriteCell.h"
#import "ICODBManager.h"
#import "ICOVIdeoManager.h"

#import "ICOFavoritesViewController.h"
#import "LXReorderableCollectionViewFlowLayout.h"

@interface ICOFavoritesViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
{
    float _menuItemsHight;
    bool _hasChangedOrder;
    bool _isLarge;
    
}


@property (nonatomic) NSMutableArray* videoLinks;


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;



@end

@implementation ICOFavoritesViewController



//initialize videoLink sorted by videoLink order
- (NSMutableArray *)initializevideoLinks {
 
 
    ICOVideoManager* manager = [ICOVideoManager new];
    NSArray* links = [manager getFavorites];
    
    //sort by linkOrder
    NSSortDescriptor* sorting = [NSSortDescriptor sortDescriptorWithKey: @"linkOrder" ascending:true];
    NSMutableArray* sortedvideoLinks = [NSMutableArray arrayWithArray: [links sortedArrayUsingDescriptors:@[sorting]]];
    
    _hasChangedOrder = false;
    
    return sortedvideoLinks;
}



- (void) didMoveToParentViewController:(UIViewController *)parent
{
    
    
    [super didMoveToParentViewController:parent];
    
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"ICOFavoriteCell" bundle:nil]forCellWithReuseIdentifier:@"ICOFavoriteCell"];
  
    
    [self.collectionView setDelegate:self];
    
    [self.collectionView setDataSource:self];

   
}
- (void) viewWillAppear:(BOOL)animated
{

    [super viewWillAppear: animated];
    [self registerForUIEvents:true];
    
    
    self.videoLinks = [self initializevideoLinks];
    [self.collectionView reloadData];
    
    
    LXReorderableCollectionViewFlowLayout*  flowLayout = (LXReorderableCollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    
    CGSize itemSize = flowLayout.itemSize;
    CGRect viewSize = self.view.bounds;
    itemSize.width =  (viewSize.size.width - 16.0f)/2.0f;

    flowLayout.itemSize = itemSize;
    

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidDisappear:(BOOL)animated
{
    [self registerForUIEvents:false];
    
    
    [super viewDidDisappear:animated];
    
}


//launch selected videoLink
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    
    
    
    NSInteger selectedIndex = [indexPath row];
    
   
    ICOVideoLink* videoLink= [self.videoLinks objectAtIndex:selectedIndex];
    
  
   
    if(videoLink !=nil)
    {
       //start the videoLink
     
        [[self navigator] performNavigatorAction:ICONavigatorActionPresentCenter withParams:@{@"linkurl":videoLink}];
    
    }
    
    
}



#pragma mark <UICollectionViewDataSource>


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    if(self.videoLinks == nil)
        return 0;
    
    return self.videoLinks.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"ICOFavoriteCell";

    ICOVideoLink *videoLink = self.videoLinks[indexPath.item];
    ICOFavoriteCell *cell = (ICOFavoriteCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell setVideoLink: videoLink];

    
    return cell;
}

#pragma mark - LXReorderableCollectionViewDataSource methods

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    ICOVideoLink *videoLink = self.videoLinks[fromIndexPath.item];
    
    [self.videoLinks removeObjectAtIndex:fromIndexPath.item];
    [self.videoLinks insertObject:videoLink atIndex:toIndexPath.item];

    _hasChangedOrder = true;
    
  

}

//update videoLink order and save to local DB
- (void) updatevideoLinksOrder
{
    
    int order=1;
   
    for(ICOVideoLink* videoLink in self.videoLinks )
    {
        videoLink.linkOrder = order;
        [videoLink update];
        order++;
  
    }

    [[ICODBManager sharedInstance] saveContext];
    
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath {
    
    return YES;
    
}




#pragma mark - LXReorderableCollectionViewDelegateFlowLayout methods

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
 }

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(_hasChangedOrder)
    {
        [self updatevideoLinksOrder];
        
    }

    _hasChangedOrder = false;

    
}


-(void) onUIEvent:(ICOUIEvent)event withParams:(NSDictionary *)params
{

}



@end
