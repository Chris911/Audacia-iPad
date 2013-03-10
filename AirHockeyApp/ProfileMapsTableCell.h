//
//  ProfileMapsTableCell.h
//  AirHockeyApp
//
//  Created by Chris on 13-03-09.
//
//

#import <UIKit/UIKit.h>

@interface ProfileMapsTableCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *mapImageView;
@property (retain, nonatomic) IBOutlet UIImageView *ratingImageView;

@property (retain, nonatomic) IBOutlet UILabel *mapNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *lastModifiedLabel;


@end
