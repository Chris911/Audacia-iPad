//
//  ProfileMapsTableCell.m
//  AirHockeyApp
//
//  Created by Chris on 13-03-09.
//
//

#import "ProfileMapsTableCell.h"

@implementation ProfileMapsTableCell

@synthesize mapImageView;
@synthesize ratingImageView;
@synthesize mapNameLabel;
@synthesize lastModifiedLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [mapImageView release];
    [mapNameLabel release];
    [ratingImageView release];
    [lastModifiedLabel release];
    [_deleteImageView release];
    [super dealloc];
}
@end
