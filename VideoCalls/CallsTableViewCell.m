//
//  CallsTableViewCell.m
//  VideoCalls
//
//  Created by Ivan Sein on 19.07.17.
//  Copyright © 2017 struktur AG. All rights reserved.
//

#import "CallsTableViewCell.h"

NSString *const kCallCellIdentifier = @"CallCellIdentifier";
NSString *const kCallsTableCellNibName = @"CallsTableViewCell";

@implementation CallsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
