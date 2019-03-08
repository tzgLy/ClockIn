//
//  ViewController.m
//  test
//
//  Created by 田智广 on 2019/2/27.
//  Copyright © 2019年 田智广. All rights reserved.
//

#import "ViewController.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

@interface ViewController ()<MAMapViewDelegate,AMapSearchDelegate>

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (nonatomic, strong) MAMapView *mapView;
@property(nonatomic,strong)AMapLocationManager *locationManager;
@property (nonatomic, strong) MAPointAnnotation *ann;
@property (nonatomic, copy)CLLocation *mineLocation;
@property (nonatomic, assign)float la;
@property (nonatomic, assign)float lo;
@property (nonatomic, strong) AMapSearchAPI *search;


    
@end

@implementation ViewController
    
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor whiteColor];
    [self setUpGaoDeMap];
    [self setUpLocation];
    [self addressToCoo];
    
}

#pragma mark-创建高德地图
-(void)setUpGaoDeMap{
    
    self.mapView = [[MAMapView alloc]initWithFrame:self.bgView.bounds];
    self.mapView.mapType=MAMapTypeStandard;
    self.mapView.zoomEnabled=YES;
    self.mapView.showsCompass=NO;//指南针
    self.mapView.showsScale=NO;//比例尺
    self.mapView.scrollEnabled = YES;//允许Scroll
    self.mapView.delegate=self;
    [self.mapView setZoomLevel:18.09000000999];//小数点很重要
    [self.bgView addSubview:self.mapView];
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    
}

-(void)viewDidLayoutSubviews{
    
    [super viewDidLayoutSubviews];
    
    self.mapView.frame=self.bgView.bounds;
}


#pragma mark-画圆
//绘制区域图形的相关属性配置 可以是矩形 多边形 圆形
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay{
    
    if ([overlay isKindOfClass:[MACircle class]]) {
        
        MACircleRenderer * polygonRenderer = [[MACircleRenderer alloc]initWithCircle:overlay];
        polygonRenderer.lineWidth   = 0.1f;
        //polygonRenderer.strokeColor = [UIColor redColor];
        polygonRenderer.fillColor = [UIColor colorWithRed:144/255.0 green:144/255.0 blue:144/255.0 alpha:0.5];
        return polygonRenderer;
    }
    
    return nil;
}

#pragma mark-去掉蓝圈
- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    
    MAAnnotationView *view = views[0];
    // 放到该方法中用以保证userlocation的annotationView已经添加到地图上了。
    if ([view.annotation isKindOfClass:[MAUserLocation class]]){
        
        MAUserLocationRepresentation *r = [[MAUserLocationRepresentation alloc] init];
        r.showsAccuracyRing = false;///精度圈是否显示，默认YES
        [self.mapView updateUserLocationRepresentation:r];
    }
}


#pragma mark-定位
-(void)setUpLocation{
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
        
        
        NSString *message=[NSString stringWithFormat:@"请前往设置－隐私 打开定位服务，获取经纬度，以便消费者获取商户地址"];
        
        UIAlertController *alertVC=[UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action1=[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:nil];
        
        [alertVC addAction:action1];
        
        [self presentViewController:alertVC animated:YES completion:nil];
        
        
        return;
    }
   
    self.locationManager=[[AMapLocationManager alloc]init];
    // 带逆地理信息的一次定位（返回坐标和地址信息）
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    
    self.locationManager.locationTimeout =10;
    // 逆地理请求超时时间，最低2s，此处设置为3s
    self.locationManager.reGeocodeTimeout =10;
    
    // 带逆地理（返回坐标和地址信息）。将下面代码中的YES改成NO，则不会返回地址信息。
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        
        if (error){
            
            if (kCLAuthorizationStatusNotDetermined == status||kCLAuthorizationStatusRestricted==status||kCLAuthorizationStatusDenied==status){
                
                
            }else{
                
                //除去以上三种情,只可能是高德自己的问题了,再次定位
                //[self setUpLocation];
                
            }
            
            return ;
            
        }
        
        self.mineLocation=location;
        
        //[self reverseGeocoderWith:location.coordinate.latitude Lo:location.coordinate.longitude]; NSLog(@"^^^^^%f^^^^^^%f",location.coordinate.latitude,location.coordinate.longitude);
        
        
    }];
    
    
}

#pragma mark-地址转坐标
-(void)addressToCoo{
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
    geo.address = self.address;
    [self.search AMapGeocodeSearch:geo];
    
}

- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response{
    
    if (response.geocodes.count == 0){
        return;
    }
    
    //解析response获取地理信息，具体解析见 Demo
    for (AMapGeocode *c in response.geocodes) {
        
        if (c!=nil) {
            
            AMapGeoPoint *p=c.location;
            
            self.la=p.latitude;
            self.lo=p.longitude;
            
            CLLocationCoordinate2D coo=CLLocationCoordinate2DMake(p.latitude, p.longitude);
            self.mapView.centerCoordinate=coo;
            //大头针
            self.ann = [[MAPointAnnotation alloc] init];
            self.ann.coordinate = coo;
            [self.mapView addAnnotation:self.ann];
            
            //构造圆
            MACircle *circle = [MACircle circleWithCenterCoordinate:coo radius:[self.distance floatValue]];
            //在地图上添加圆
            [self.mapView addOverlay: circle];
            
            NSLog(@"^^^^^^%@^^^^%f^^^^%f",c.formattedAddress,p.latitude,p.longitude);
            
        }
  
        return;
        
    }

}

- (IBAction)btnClick:(UIButton *)sender {
    
    //公司坐标
    CLLocation *company=[[CLLocation alloc] initWithLatitude:self.la  longitude:self.lo];
    //计算距离
    CLLocationDistance meters=[self.mineLocation distanceFromLocation:company];
    
    NSString *message=@"";
    if (meters>[self.distance floatValue]) {
        
        message=@"您不在规定范围内不允许签到";
        
    }else{
        
        message=@"签到成功";
        [sender setTitle:@"已签到" forState:UIControlStateNormal];
        sender.userInteractionEnabled=NO;
        
    }
    
    UIAlertController *alertVC=[UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1=[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:action1];
    [self presentViewController:alertVC animated:YES completion:nil];

   
}


-(void)dealloc{
    
    self.mapView.showsUserLocation = NO;
    self.mapView.delegate = nil;
    [self.mapView removeFromSuperview];
    self.mapView=nil;
    
    
}

//反地理编码
-(void)reverseGeocoderWith:(CGFloat)la Lo:(CGFloat)lo{
    
    //初始化检索对象
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    
    //构造AMapReGeocodeSearchRequest对象
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = [AMapGeoPoint locationWithLatitude:la longitude:lo];
    regeo.radius = 10000;
    regeo.requireExtension = YES;
    
    
    //发起逆地理编码
    [_search AMapReGoecodeSearch: regeo];
}

//实现逆地理编码的回调函数/
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    
    
    if(response.regeocode != nil)
    {
        
        
        NSString *result3 = [NSString stringWithFormat:@"%@", response.regeocode.formattedAddress];
        
        NSLog(@"*********%@",result3);
        
    }
}

@end
