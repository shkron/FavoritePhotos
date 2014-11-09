//
//  PhotoViewController.m
//  FavoritePhotos
//
//  Created by Alex on 11/6/14.
//  Copyright (c) 2014 Alexey Emelyanov. All rights reserved.
//

#import "PhotoViewController.h"
@import MessageUI;

@interface PhotoViewController () <UICollectionViewDataSource, UICollectionViewDelegate, MFMailComposeViewControllerDelegate>

@property NSMutableArray *favoritesArray;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self load];
//    [self.collectionView reloadData];

   
}

-(void)viewWillAppear:(BOOL)animated
{
    [self load];
    [self.collectionView reloadData];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.favoritesArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageWithData:self.favoritesArray[indexPath.item][@"imgData"]];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    [self sendEmail:self.favoritesArray[indexPath.item][@"imgData"]];
//    [self.favoritesArray removeObjectAtIndex:indexPath.item];
//
//    [self.collectionView reloadData];
//
//    NSLog(@"Removed object. Array count = %lu", (unsigned long)self.favoritesArray.count);
//    NSURL *plistURL = [[self documentsDirectory]URLByAppendingPathComponent:@"fovorites.plist"];
//    [self.favoritesArray writeToURL:plistURL atomically:YES];
}



-(NSURL *)documentsDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    return url;
}

-(void)load
{
    NSURL *plistURL = [[self documentsDirectory] URLByAppendingPathComponent:@"fovorites.plist"];
    self.favoritesArray = [NSMutableArray arrayWithContentsOfURL:plistURL];
    if (self.favoritesArray == nil)
    {
        self.favoritesArray = [NSMutableArray array];
    }
}

//MARK: email send methods

-(void)sendEmail:(NSData *)data
{
    // From within your active view controller
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;        // Required to invoke mailComposeController when send

        [mailCont setSubject:@"Check this pic"];
        [mailCont setToRecipients:[NSArray arrayWithObject:@"emelyanoff@gmail.com"]];
        [mailCont setMessageBody:@"It's from Instagram" isHTML:NO];
        [mailCont addAttachmentData:data mimeType:@"image/jpg" fileName:@"pic"];

        [self presentViewController:mailCont animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if (error)
    {
        [self networkAlertWindow:error.localizedDescription];
    }
    else
    {
    [controller dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)networkAlertWindow:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Ahtung!" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"😭 Mkay..." style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
