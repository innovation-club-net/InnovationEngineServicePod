//
//  PresentedViewController.swift
//  InnovationEngineDemo
//
//  Created by Fred on 28.03.23.
//

import Foundation
import UIKit

class PresentableViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapGestureToView()
    }
    
    private func setupTapGestureToView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        dismiss(animated: false)
    }
    
}
