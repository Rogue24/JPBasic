//
//  JPResizableImageViewController.m
//  JPBasic_Example
//
//  Created by aa on 2021/12/30.
//  Copyright © 2021 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPResizableImageViewController.h"
#import "JPWebImageManager.h"

@interface JPResizableImageViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation JPResizableImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = JPRandomColor;
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 150, JPScreenWidth - 40, 36)];
    self.imageView.backgroundColor = JPRandomColor;
    [self.view addSubview:self.imageView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [JPProgressHUD show];
    [JPWebImageManager downloadImageWithURL:[NSURL URLWithString:@"https://s4.ax1x.com/2021/12/29/T6bl7T.png"] options:0 progress:nil transform:nil completed:^(UIImage *image, NSError *error, NSURL *imageURL, JPWebImageFromType jp_fromType, JPWebImageStage jp_stage) {
        UIImage *newImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(20, 40, 20, 40) resizingMode:UIImageResizingModeStretch];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [JPProgressHUD dismiss];
            self.imageView.image = newImage;
        });
    }];
}

@end

/*
class TestResizeImageVC: UIViewController {
    var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .gray
        imgView = UIImageView()
        imgView.backgroundColor = .red
//        imgView.clipsToBounds = true
//        imgView.contentMode = .scaleAspectFill
        view.addSubview(imgView)
        
        imgView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(100)
            $0.height.equalTo(300)
        }
        
        let imgStr1 = "https://s4.ax1x.com/2021/12/29/T6bl7T.png"
        let imgStr2 = "http://audiotest.cos.tx.xmcdn.com/storages/04ad-audiotest/A0/3A/CAoVJ7MDwbWqAADl9wAAK3Ac.png"
        let imgURL = URL(string: imgStr1)!
        SDWebImageManager.shared.loadImage(with: imgURL, options: .avoidAutoSetImage, progress: nil) { image, data, error, cacheType, success, url in
            DispatchQueue.main.async {
                self.imgView.image = image //image?.resizableImage(withCapInsets: UIEdgeInsets(top: 20, left: 40, bottom: 20, right: 40), resizingMode: .stretch)
            }
        }
    }
}
*/
