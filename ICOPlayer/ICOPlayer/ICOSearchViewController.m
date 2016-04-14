//
//  ICOSearchViewController.m
//  ICOPlayer
//
//  Created by Othon Cruz on 4/12/16.
//  Copyright © 2016 Othon Cruz. All rights reserved.
//

#import "ICOSearchViewController.h"
#import "ICOSearchItemCell.h"
#import "ICOVIdeoManager.h"




@interface ICOSearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray* filtered;
@property (strong, nonatomic) UIActivityIndicatorView  *indicator;

@end

@implementation ICOSearchViewController
{

    bool _firstTime;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _firstTime=true;
    
    self.filtered =nil;
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ICOSearchItemCell" bundle:nil] forCellReuseIdentifier: @"ICOSearchItemCell"];
    
    [self.tableView setDelegate:self];
    
    [self.tableView setDataSource:self];
    
    
    //search searchField t text color
    UITextField *searchField = [self.searchBar valueForKey:@"searchField"];
    searchField.textColor = [UIColor lightGrayColor];
  
    self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicator.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];
    [self.view addSubview:self.indicator];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void) viewWillAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
 
    [super viewWillAppear:animated];
    
}

-(void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.indicator.center = CGPointMake(self.view.bounds.size.width/2,
                                        self.view.bounds.size.height/2);
    
    

}

-(void) didMoveToParentViewController:(UIViewController *)parent
{
    if(parent!=nil && _firstTime )
    {
        [self handleSearch: nil];

    }
    _firstTime=false;


}
-(void) viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    
    
    
}


-(void) handleSearch : (NSString*) filter
{

    ICOVideoManager* manager = [ICOVideoManager new];
    
    
    bool hasSync = [manager getFlag:ICOFLag_Sync];
    
    
    //this will take time
    if(!hasSync)
        [self.indicator startAnimating];

    
    [manager searchLinksWithFilter:filter completion:^(NSArray *links) {
     
        
        if(!hasSync)
            [self.indicator stopAnimating];
        
        
        self.filtered = links;
        
        [self.tableView reloadData];
        
        
        
    }];
    
     
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark search delegate

// called when text ends editing
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{

    [self handleSearch:searchBar.text];
    
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self handleSearch:searchText];
    
}

// called when keyboard search button pressed

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{

    [self handleSearch:searchBar.text];
    
}
#pragma mark table view

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    ICOVideoLink *videoLink = self.filtered[indexPath.row];

    
    
    if(videoLink !=nil)
    {
        //start the videoLink
        if ([self.searchBar isFirstResponder])
        {
            [self.searchBar endEditing:true];
        }

        [[self navigator] performNavigatorAction:ICONavigatorActionPresentCenter withParams:@{@"linkurl":videoLink}];
        
    }
    

}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(self.filtered==nil)
        return 0;
    
    return self.filtered.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ICOVideoLink *link = self.filtered[indexPath.row];
    
    ICOSearchItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ICOSearchItemCell"];
  
    [cell setVideoLink: link];
    
     return cell;
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    if ([self.searchBar isFirstResponder])
    {
        [self.searchBar endEditing:true];
    }
}


@end
