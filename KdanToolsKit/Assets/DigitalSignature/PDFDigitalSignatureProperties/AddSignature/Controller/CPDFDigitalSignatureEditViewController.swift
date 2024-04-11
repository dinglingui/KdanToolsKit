//
//  CPDFDigitalSignatureEditViewController.swift
//  PDFViewer-Swift
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import UIKit

enum CSignatureCustomType: Int {
    case text = 1
    case draw
    case image
    case none
}

class CPDFDigitalSignatureEditViewController: CPDFSignatureEditViewController {
    
    // MARK: - Viewcontroller Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.fontSettingView?.superview != nil {
            self.fontSettingView?.removeFromSuperview()
        }

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        segmentedControl?.frame = CGRect(x: (view.frame.size.width - 300)/2, y: 10, width: 300, height: 30)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")

        UIViewController.attemptRotationToDeviceOrientation()
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
    // MARK: - Public Methods
    
    func refreshViewController() {
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        if self.segmentedControl?.selectedSegmentIndex == 3 {
            self.segmentedControl?.selectedSegmentIndex = 0
            initDrawSignatureViewProperties()
            customType = .draw
        }

        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    // MARK: - Private Methods
    
    override func initSegmentedControl() {
        let segmmentArray = [NSLocalizedString("Trackpad", comment: ""), NSLocalizedString("Keyboard", comment: ""), NSLocalizedString("Image", comment: ""), NSLocalizedString("None", comment: "")]
        segmentedControl = UISegmentedControl(items: segmmentArray)
        segmentedControl?.selectedSegmentIndex = 0
        segmentedControl?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        segmentedControl?.addTarget(self, action: #selector(segmentedControlValueChanged_singature(_:)), for: .valueChanged)
        if(segmentedControl != nil) {
            self.view.addSubview(segmentedControl!)
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    override func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    // MARK: - Action
    
    override func segmentedControlValueChanged_singature(_ sender: Any) {
        if segmentedControl?.selectedSegmentIndex == 0 {
            initDrawSignatureViewProperties()
            customType = .draw
        } else if segmentedControl?.selectedSegmentIndex == 1 {
            initTextSignatureViewProperties()
            customType = .text
        } else if segmentedControl?.selectedSegmentIndex == 2 {
            initImageSignatureViewProperties()
            customType = .image
        } else if segmentedControl?.selectedSegmentIndex == 3 {
            customType = .none
            delegate?.signatureEditViewController?(self, image: UIImage())
        }
    }
    
    override func buttonItemClicked_Cancel(_ sender: Any) {
        dismiss(animated: false)
        delegate?.signatureEditViewControllerCancel?(self)
    }

}
