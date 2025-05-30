//
//  LoaderButon.swift
//  Toddler Communication App
//
//  Created by Supriyo Dey on 15/04/24.
//

import Foundation
import UIKit

/*To use LoaderButton  --> 
 1) select the class of button to LoaderButton from storyboard
 2) to start loading just set the 'isLoading' - true
 3) to stop set 'isLoading' - false
 */
class LoaderButton: UIButton {
    private var spinner = UIActivityIndicatorView()
    var spinnerColor = UIColor.white
    var isLoading = false {
        didSet {
            // whenever `isLoading` state is changed, update the view
            updateView()
        }
    }
    
    private var title = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        spinner.hidesWhenStopped = true
        spinner.color = spinnerColor
        addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    private func updateView() {
        if isLoading {
            title = currentTitle ?? ""
            setTitle(nil, for: .normal)
            spinner.startAnimating()
            imageView?.alpha = 0
            isEnabled = false
        } else {
            spinner.stopAnimating()
            setTitle(title, for: .normal)
            imageView?.alpha = 0
            isEnabled = true
        }
    }
}
