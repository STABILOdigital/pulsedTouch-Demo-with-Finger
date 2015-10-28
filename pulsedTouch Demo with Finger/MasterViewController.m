//
//  SIDMasterViewController.m
//  PulsedTouch Demo with Finger
//
//  Created by Peter Kämpf on 04.04.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

@interface MasterViewController ()
@property (strong, nonatomic) IBOutlet UILabel *lineWidthLabel;
@property (strong, nonatomic) IBOutlet UILabel *alphaValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *lineBrightLabel;
@property (strong, nonatomic) IBOutlet UILabel *speedLabel;
@property (strong, nonatomic) IBOutlet UILabel *frameRateLabel;
@property (strong, nonatomic) IBOutlet UIButton *filterSwitchButton;
@property (strong, nonatomic) IBOutlet UIButton *analyzerSwitchButton;
@property (strong, nonatomic) IBOutlet UIButton *tRecSelectButton;
@property (strong, nonatomic) IBOutlet UISlider *paramsSlider;
@property (strong, nonatomic) NSTimer *displayTimer;
@property (assign, nonatomic) NSUInteger paramsIndex;
@property (strong, nonatomic) NSArray *pickerStrings;
@property (strong, nonatomic) NSMutableArray *paramsArray;
@end

@implementation MasterViewController

#pragma mark - Setup

// Initialize the window

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.preferredContentSize = self.view.bounds.size;
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    // Launch a timer for frameRate updates. Since viewDidLoad is called twice, we need to check
    // whether the timer runs already.
    if (!self.displayTimer) {
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateDisplayValues:) userInfo:nil repeats:YES];
        self.displayTimer = timer;
    }
    self.paramsIndex    =    0;
    self.paramsArray    = [[NSMutableArray alloc] initWithCapacity:8];
    self.paramsArray[0] =   @5.0;        // speedLimitFactor
    self.paramsArray[1] =   @5.5;        // maxOffTimeFactor
    self.paramsArray[2] =   @4.0;        // sensitivity
    self.paramsArray[3] = @200.0;        // minimumSpeed
    self.paramsArray[4] =  @50.0;        // xMarginForHitTesting
    self.paramsArray[5] =  @25.0;        // yMarginForHitTesting
    self.paramsArray[6] =   @0.15;       // penModeErrorLimit
    self.paramsArray[7] =   @0.4;        // timeBetweenSameLines
    self.paramsSlider.minimumValue =  0.0;
    self.paramsSlider.maximumValue = 30.0;
    float newParameter    = [self.paramsArray[self.paramsIndex] floatValue];
    self.paramsEntry.text = [NSString stringWithFormat:@"%.2f", newParameter];
    [self.paramsSlider setValue:newParameter animated:NO];
    self.pickerStrings    = [[NSArray alloc] initWithObjects:@"speedLimitFactor", @"maxOffTimeFactor", @"sensitivity", @"minimumSpeed", @"xMarginForHitTesting", @"yMarginForHitTesting", @"penModeErrorLimit", @"timeBetweenSameLines", nil];
    
    self.paramsPicker.delegate   = self;
    self.paramsPicker.dataSource = self;
    self.paramsEntry.delegate    = self;
}

// Number of spinwheels of the paramsPicker:

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// Number of entries of the paramsPicker:

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.pickerStrings count];
}

// Give back the entry string for the row row of the paramsPicker:

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.pickerStrings[row];
}

#pragma mark - IB Actions

// Action after the line width slider has been changed:

- (IBAction)lineWidthSliderChanged:(UISlider *)sender {
    [self.detailViewController.linePresets setWidth:sender.value];
    self.lineWidthLabel.text = [NSString stringWithFormat:@"%.1f", sender.value];
}

// Action after the transparency slider has been changed:

- (IBAction)alphaSliderChanged:(UISlider *)sender {
    [self.detailViewController.linePresets setAlphaValue:sender.value];
    self.alphaValueLabel.text = [NSString stringWithFormat:@"%.2f", sender.value];
}

// Action after the line brightness slider has been changed:

- (IBAction)brightSliderChanged:(UISlider *)sender {
    [self.detailViewController.linePresets setBright:0.01*sender.value];
    self.lineBrightLabel.text = [NSString stringWithFormat:@"%.0f", sender.value];
}

// Action when the Show Rects button has been selected.

- (IBAction)toggleRectDisplaySwitch:(UISwitch *)sender {
    [self.detailViewController.pvData setRectDisplay:sender.isOn];
}

// Action to switch between the touchRecognizer and the touchAnalyzer

- (IBAction)toggleFilterButtonTapped:(UIButton *)sender {
    
    if ([sender.titleLabel.text isEqualToString:@"touchRecognizer"]) {
        [self.detailViewController.pvData setTouchAnalyzer:YES];
        [sender setTitle:@"touchAnalyzer" forState:UIControlStateNormal];
        
        // If we had v8 active, reset the options switch:
        if (self.detailViewController.pvData.v8tRec > 0) {
            [self.tRecSelectButton setTitle:@"iOS8" forState:UIControlStateNormal];
            self.tRecSelectButton.titleLabel.text  = @"iOS8";
        }
        self.detailViewController.tRec.enabled = NO;
    } else {
        
        [self.detailViewController.pvData setTouchAnalyzer:NO];
        [sender setTitle:@"touchRecognizer" forState:UIControlStateNormal];
        
        // Re-establish the selection in the tRec button:
        if (self.detailViewController.pvData.v8tRec > 0) {
            [self.tRecSelectButton setTitle:@"iOS8 with finger" forState:UIControlStateNormal];
            self.tRecSelectButton.titleLabel.text = @"iOS8 with finger";
            
        } else if (self.detailViewController.pvData.v8tRec == 2) {
            [self.tRecSelectButton setTitle:@"iOS8, only pen" forState:UIControlStateNormal];
            self.tRecSelectButton.titleLabel.text = @"iOS8, only pen";
        }
        self.detailViewController.tRec.enabled = YES;
        
        // Depending on the selected touchRecognizer, switch Finger on or off.
        [self.detailViewController switchMode];
    }
}

// Action when the Pen mode button has been selected.

- (IBAction)togglePenModeButtonTapped:(UIButton *)sender {
    
    if ([sender.titleLabel.text isEqualToString:@"SMART up default"]) {
        [sender setTitle:@"SMART up expert" forState:UIControlStateNormal];
        self.analyzerSwitchButton.titleLabel.text = @"SMART up expert";
        [self.detailViewController.tRec setPenModeSwitch:3];
        
    } else if ([sender.titleLabel.text isEqualToString:@"SMART up expert"]) {
        [sender setTitle:@"SMART junior" forState:UIControlStateNormal];
        self.analyzerSwitchButton.titleLabel.text = @"SMART junior";
        [self.detailViewController.tRec setPenModeSwitch:1];
        
    } else {
        [sender setTitle:@"SMART up default" forState:UIControlStateNormal];
        self.analyzerSwitchButton.titleLabel.text = @"SMART up default";
        [self.detailViewController.tRec setPenModeSwitch:2];
    }
}

// Action when the Recording button has been selected.

- (IBAction)startRecTapped:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:(@"Start")]) {
        [sender setTitle: @"Stop" forState: UIControlStateNormal];
        [sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    } else {
        [sender setTitle: @"Start" forState: UIControlStateNormal];
        [sender setTitleColor:nil forState:UIControlStateNormal];
    }
    [self.detailViewController startRecording];
}

// Action when the SelectTouchRecognizer button has been selected.

- (IBAction)tRecSelectionButtonTapped:(UIButton *)sender {
    
    // First variant: The touchRecognizer is running:
    if (!self.detailViewController.pvData.touchAnalyzer) {
        
        // Update the value of the v8tRec variable and the UI:
        switch (self.detailViewController.pvData.v8tRec) {
            case 0:
                [self.detailViewController.pvData setV8tRec:1];
                [sender setTitle:@"iOS8 with finger" forState:UIControlStateNormal];
                self.tRecSelectButton.titleLabel.text = @"iOS8 with finger";
                
                // Update the UI
                if (self.paramsIndex == 0) {
                    self.paramsArray[0]            = @5.0;        // speedLimitFactor
                    self.paramsSlider.maximumValue = 30.0;
                    self.paramsEntry.text          = [NSString stringWithFormat:@"%.2f", 5.0];
                    [self.paramsSlider setValue:5.0 animated:YES];
                }
                break;
                
            case 1:
                [self.detailViewController.pvData setV8tRec:2];
                [sender setTitle:@"iOS8, only pen" forState:UIControlStateNormal];
                self.tRecSelectButton.titleLabel.text = @"iOS8, only pen";
                
                // Update the UI
                if (self.paramsIndex == 0) {
                    self.paramsArray[0]            = @5.0;        // speedLimitFactor
                    self.paramsSlider.maximumValue = 30.0;
                    self.paramsEntry.text          = [NSString stringWithFormat:@"%.2f", 5.0];
                    [self.paramsSlider setValue:5.0 animated:YES];
                }
                break;
                
            default:
                [self.detailViewController.pvData setV8tRec:0];
                [sender setTitle:@"iOS7" forState:UIControlStateNormal];
                self.tRecSelectButton.titleLabel.text = @"iOS7";
                
                // Update the UI
                if (self.paramsIndex == 0) {
                    self.paramsArray[0]            = @40.0;        // speedLimitFactor
                    self.paramsSlider.maximumValue =  80.0;
                    self.paramsEntry.text          = [NSString stringWithFormat:@"%.2f", 40.0];
                    [self.paramsSlider setValue:40.0 animated:YES];
                }
                break;
        }
        
        // touchAnalyzer is active: Different selection!
    } else {
        if (self.detailViewController.pvData.v8tRec == 0) {
            [self.detailViewController.pvData setV8tRec:1];
            [sender setTitle:@"iOS8" forState:UIControlStateNormal];
            self.tRecSelectButton.titleLabel.text = @"iOS8";
            
            // Update the UI
            if (self.paramsIndex == 0) {
                self.paramsArray[0]            = @5.0;        // speedLimitFactor
                self.paramsSlider.maximumValue = 30.0;
                self.paramsEntry.text          = [NSString stringWithFormat:@"%.2f", 5.0];
                [self.paramsSlider setValue:5.0 animated:YES];
            }
            
        } else {
            [self.detailViewController.pvData setV8tRec:0];
            [sender setTitle:@"iOS7" forState:UIControlStateNormal];
            self.tRecSelectButton.titleLabel.text = @"iOS7";
            
            // Update the UI
            if (self.paramsIndex == 0) {
                self.paramsArray[0]            = @40.0;        // speedLimitFactor
                self.paramsSlider.maximumValue =  80.0;
                self.paramsEntry.text          = [NSString stringWithFormat:@"%.2f", 40.0];
                [self.paramsSlider setValue:40.0 animated:YES];
            }
        }
    }
    
    // Now tell the detailViewController to acknowledge the changes.
    [self.detailViewController switchMode];
}

// Action after a parameter has been selected for editing:

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    self.paramsIndex = row;
    
    switch (row) {
        case 0:
            self.paramsSlider.minimumValue =  0.0;
            if (self.detailViewController.pvData.v8tRec) {
                self.paramsSlider.maximumValue = 30.0;
            } else {
                self.paramsSlider.maximumValue = 80.0;
            }
            break;
            
        case 1:
            self.paramsSlider.minimumValue =  1.0;
            self.paramsSlider.maximumValue = 12.0;
            break;
            
        case 2:
            self.paramsSlider.minimumValue =  1;
            self.paramsSlider.maximumValue = 24;
            break;
            
        case 3:
            self.paramsSlider.minimumValue =   0.0;
            self.paramsSlider.maximumValue = 500.0;
            break;
            
        case 4:
            self.paramsSlider.minimumValue =   0.0;
            self.paramsSlider.maximumValue = 120.0;
            break;
            
        case 5:
            self.paramsSlider.minimumValue =   0.0;
            self.paramsSlider.maximumValue = 120.0;
            break;
            
        case 6:
            self.paramsSlider.minimumValue =   0.01;
            self.paramsSlider.maximumValue =   0.5;
            break;
            
        default:
            self.paramsSlider.minimumValue =   0.01;
            self.paramsSlider.maximumValue =   2.5;
    }
    
    // Only now can the slider be correctly set:
    float newParameter    = [self.paramsArray[row] floatValue];
    self.paramsEntry.text = [NSString stringWithFormat:@"%.2f", newParameter];
    [self.paramsSlider setValue:newParameter animated:YES];
}

// Action after a new value has been edited for the selected parameter:

- (IBAction)paramsEdited:(UITextField *)sender {
    float newParameter = [sender.text floatValue];
    self.paramsArray[self.paramsIndex] = [NSNumber numberWithFloat:(newParameter)];
    [self.paramsSlider setValue:newParameter animated:YES];
    switch (self.paramsIndex) {
        case 0:
            self.detailViewController.tRec.speedLimitFactor     = newParameter;
            break;
        case 1:
            self.detailViewController.tRec.maxOffTimeFactor     = newParameter;
            break;
        case 2:
            self.detailViewController.tRec.sensitivity          = newParameter;
            break;
        case 3:
            self.detailViewController.tRec.minimumSpeed         = newParameter;
            break;
        case 4:
            self.detailViewController.tRec.xMarginForHitTesting = newParameter;
            break;
        case 5:
            self.detailViewController.tRec.yMarginForHitTesting = newParameter;
            break;
        case 6:
            self.detailViewController.tRec.penModeErrorLimit    = newParameter;
            break;
        default:
            self.detailViewController.tRec.timeBetweenSameLines = newParameter;
    }
}

// Fold away the screen keyboard when Return is typed:

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

// Action when the parameter slider moves:

- (IBAction)paramsSliderMoved:(UISlider *)sender {
    self.paramsArray[self.paramsIndex] = [NSNumber numberWithFloat:(sender.value)];
    self.paramsEntry.text = [NSString stringWithFormat:@"%.2f", sender.value];
    switch (self.paramsIndex) {
        case 0:
            self.detailViewController.tRec.speedLimitFactor     = sender.value;
            break;
        case 1:
            self.detailViewController.tRec.maxOffTimeFactor     = sender.value;
            break;
        case 2:
            self.detailViewController.tRec.sensitivity          = sender.value;
            break;
        case 3:
            self.detailViewController.tRec.minimumSpeed         = sender.value;
            break;
        case 4:
            self.detailViewController.tRec.xMarginForHitTesting = sender.value;
            break;
        case 5:
            self.detailViewController.tRec.yMarginForHitTesting = sender.value;
            break;
        case 6:
            self.detailViewController.tRec.penModeErrorLimit    = sender.value;
            break;
        default:
            self.detailViewController.tRec.timeBetweenSameLines = sender.value;
    }
}

// Action when the Erase button has been selected.

- (IBAction)eraseButtonTapped:(UIButton *)sender {
    [self.detailViewController eraseButton];
    self.speedLabel.text     = [NSString stringWithFormat:@"%.2f", self.detailViewController.lineSpeed];
    self.frameRateLabel.text = [NSString stringWithFormat:@"%.2f", 0.0];
}

// Recalculate frame rate, called by timer every 500 ms.

- (void)updateDisplayValues:(NSNotification *)notification {
    
    self.speedLabel.text = [NSString stringWithFormat:@"%.2f", self.detailViewController.lineSpeed];
    CGFloat frameRate    = [self.detailViewController calculateFrameRate];
    if (frameRate > 0.01) {
        self.frameRateLabel.text = [NSString stringWithFormat:@"%.2f", frameRate];
    }
}

#pragma mark - other stuff

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
    }
}

- (void)dealloc {
}

@end
