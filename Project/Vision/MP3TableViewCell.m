//
//  MP3TableViewCell.m
//  Vision
//
//  Created by zhao liang on 15/3/23.
//  Copyright (c) 2015年 Patrick Piemonte. All rights reserved.
//

#import "MP3TableViewCell.h"

@implementation MP3TableViewCell

- (void)awakeFromNib {
    // Initialization code
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.playBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 10, 60, 40)];
        self.playBtn.backgroundColor = [UIColor redColor];
        [self.playBtn setTitle:@"播放" forState:UIControlStateNormal];
        [self.playBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [self.playBtn addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.playBtn];
        
        self.titleBtn = [[UIButton alloc]initWithFrame:CGRectMake(80, 10, 200, 40)];
        [self.titleBtn setTitle:@"喜欢你" forState:UIControlStateNormal];
        [self.titleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.titleBtn.backgroundColor = [UIColor yellowColor];
//        [self.titleBtn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.titleBtn];

        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
