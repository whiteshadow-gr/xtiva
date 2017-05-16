/**
 * Copyright (C) 2017 HAT Data Exchange Ltd
 *
 * SPDX-License-Identifier: MPL2
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/
 */

import Stripe
import HatForIOS

// MARK: Class

/// Get A hat view controller, used in onboarding of new users
class GetAHATViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, STPAddCardViewControllerDelegate {
    
    // MARK: - Variables
    
    /// Stripe token for this purchase
    private var token: String = ""
    
    /// The hat image
    private var hatImage: UIImage? = nil
    
    /// the available HAT providers fetched from HAT
    private var hatProviders: [HATProviderObject] = []
    
    /// a dark view pop up to hide the background
    private var darkView: UIVisualEffectView? = nil
    
    /// the information of the hat provider cell that the user tapped
    private var selectedHATProvider: HATProviderObject? = nil

    // MARK: - IBOutlets

    /// An IBOutlet for handling the learn more button
    @IBOutlet weak var learnMoreButton: UIButton!
    
    /// An IBOutlet for handling the arrow bar on top of the view
    @IBOutlet weak var arrowBarImage: UIImageView!
    
    /// An IBOutlet for handling the collection view
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - IBActions
    
    /**
     Presents a pop up view showing the user more information about HAT
     
     - parameter sender: The object that called this method
     */
    @IBAction func learnMoreInfoButtonAction(_ sender: Any) {
        
        // set up page controller
        if let popUp = InfoHatProvidersViewController.setUpInfoHatProviderViewControllerPopUp(from: self.storyboard!) {
            
            self.darkView = AnimationHelper.addBlurToView(self.view)
            AnimationHelper.animateView(popUp.view,
                                        duration: 0.2,
                                        animations: { [weak self] () -> Void in
                                            
                                            if let weakSelf = self {
                                                
                                                popUp.view.frame = CGRect(x: weakSelf.view.frame.origin.x + 15, y: weakSelf.view.bounds.origin.y + 150, width: weakSelf.view.frame.width - 30, height: weakSelf.view.bounds.height)
                                            }
                                        },
                                        completion: {_ in return })
            
            // add the page view controller to self
            self.addViewController(popUp)
        }
    }
    
    // MARK: - UIViewController delegate methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // config the arrowBar
        self.arrowBarImage.image = self.arrowBarImage.image!.withRenderingMode(.alwaysTemplate)
        self.arrowBarImage.tintColor = .rumpelDarkGray
        
        self.learnMoreButton.addBorderToButton(width: 1, color: .teal)
        
        // add notification observers
        NotificationCenter.default.addObserver(self, selector: #selector(hidePopUpView), name: NSNotification.Name(Constants.NotificationNames.hideGetAHATPopUp.rawValue), object: nil)
        
        // fetch available hat providers
        HATService.getAvailableHATProviders(succesfulCallBack: refreshCollectionView, failCallBack: {(error) -> Void in return})
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        // reload collection view controller to adjust to the new width of the screen
        self.collectionView?.reloadData()
    }
    
    // MARK: - Refresh collection view
    
    /**
     Refreshes the collection view when the right notification is received
     
     - parameter dataReceived: A callback executed when data received
     */
    private func refreshCollectionView(dataReceived: [HATProviderObject], renewedUserToken: String?) {
        
        self.hatProviders = dataReceived
        self.collectionView.reloadData()
        
        // refresh user token
        if renewedUserToken != nil {
            
            _ = KeychainHelper.SetKeychainValue(key: "UserToken", value: renewedUserToken!)
        }
    }
    
    // MARK: - Hide pop up
    
    /**
     Hides the pop up view controller when the right notification is received
     
     - parameter notification: The norification object that called this method
     */
    @objc private func hidePopUpView(notification: Notification) {
        
        // check if we have an object
        if (notification.object != nil) {
            
            if self.selectedHATProvider?.price == 0 {
                
                self.token = ""
                self.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "stripeSegue", sender: self)
            } else {
                
                // config the STPPaymentConfiguration accordingly
                let config = STPPaymentConfiguration.shared()
                config.requiredBillingAddressFields = .full
                config.smsAutofillDisabled = true
                
                // config the STPAddCardViewController in order to present it to the user
                let addCardViewController = STPAddCardViewController(configuration: config, theme: .default())
                addCardViewController.delegate = self
                
                // STPAddCardViewController must be shown inside a UINavigationController.
                // show the STPAddCardViewController
                let navigationController = UINavigationController(rootViewController: addCardViewController)
                self.present(navigationController, animated: true, completion: nil)
            }
        }
        
        // remove the dark view pop up
        self.darkView?.removeFromSuperview()
    }
    
    // MARK: - UICollectionView methods
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        // create cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellReuseIDs.onboardingTile.rawValue, for: indexPath) as? OnboardingTileCollectionViewCell
        
        let orientation = UIInterfaceOrientation(rawValue: UIDevice.current.orientation.rawValue)!
        
        // format cell
        return OnboardingTileCollectionViewCell.setUp(cell: cell!, indexPath: indexPath, hatProvider: self.hatProviders[indexPath.row], orientation: orientation)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.hatProviders.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
        // create page view controller
        let cell = collectionView.cellForItem(at: indexPath) as! OnboardingTileCollectionViewCell
        
        // save the data we need for later use
        self.hatProviders[indexPath.row].hatProviderImage = cell.hatProviderImage.image
        self.selectedHATProvider = self.hatProviders[indexPath.row]
        self.hatImage = cell.hatProviderImage.image
        
        // set up page controller
        if let pageItemController = GetAHATInfoViewController.setUpInfoHatProviderViewControllerPopUp(from: self.storyboard!, hatProvider: self.hatProviders[indexPath.row]) {
            
            // present a dark pop up view to darken the background view controller
            self.darkView = AnimationHelper.addBlurToView(self.view)
            
            AnimationHelper.animateView(pageItemController.view,
                                        duration: 0.2,
                                        animations: {[weak self] () -> Void in
                                            
                                            if let weakSelf = self {
                                                
                                                pageItemController.view.frame = CGRect(x: weakSelf.view.frame.origin.x + 15, y: weakSelf.view.bounds.origin.y + 150, width: weakSelf.view.frame.width - 30, height: weakSelf.view.bounds.height - 130)
                                            }
                                        },
                                        completion: {_ in return})
            
            // add the page view controller to self
            self.addViewController(pageItemController)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let orientation = UIInterfaceOrientation(rawValue: UIDevice.current.orientation.rawValue)!
        
        // if device in landscape show 3 tiles instead of 2
        if orientation == .landscapeLeft || orientation == .landscapeRight {
            
            return CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
        }
        
        return CGSize(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.width / 2)
    }
    
    // MARK: - Stripe methods
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        
        self.token = token.tokenId
        self.dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "stripeSegue", sender: self)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "stripeSegue" {
            
            let controller = segue.destination as? StripeViewController
            
            controller?.sku = (self.selectedHATProvider?.sku)!
            controller?.token = self.token
            controller?.hatImage = self.hatImage
            controller?.domain = "." + (self.selectedHATProvider?.kind.domain)!
        }
    }
}