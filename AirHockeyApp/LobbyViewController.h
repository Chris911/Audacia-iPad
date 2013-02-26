//
//  LobbyViewController.h
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-02-22.
//
//

#import <UIKit/UIKit.h>

@interface LobbyViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIView *selectionView;
@property (retain, nonatomic) IBOutlet UIImageView *rightCampView;
@property (retain, nonatomic) IBOutlet UIImageView *leftCampView;
@property (retain, nonatomic) IBOutlet UIImageView *rightProfilePic;
@property (retain, nonatomic) IBOutlet UIImageView *leftProfilePic;
@property (retain, nonatomic) IBOutlet UILabel *rightCampLabel;
@property (retain, nonatomic) IBOutlet UILabel *leftCampLabel;
@property (retain, nonatomic) IBOutlet UIButton *connectButton;
@property (retain, nonatomic) IBOutlet UIView *hiddenRightView;
@property (retain, nonatomic) IBOutlet UIView *hiddenLeftView;

- (IBAction)backPressed:(id)sender;
- (IBAction)connectPressed:(id)sender;


@end
