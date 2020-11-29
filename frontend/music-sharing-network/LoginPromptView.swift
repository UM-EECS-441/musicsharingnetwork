//
//  LoginPromptView.swift
//  music-sharing-network
//
//  Created by Joe Zawisa on 11/28/20.
//

import UIKit

@IBDesignable
class LoginPromptView: UIView {
    // MARK: - Variables
    
    let nibName = "LoginPromptView"
    var contentView: UIView?
    
    weak var parentVC: UIViewController?
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        contentView = view
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginChanged), name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    // MARK: - Event Handlers
    
    @objc func loginChanged() {
        if SharedData.logged_in {
            self.removeFromSuperview()
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let loginNavController = storyBoard.instantiateViewController(withIdentifier: "LoginNavigationController")
        self.parentVC?.present(loginNavController, animated: true, completion: nil)
    }
}
