//
//  ToDetailSegue.swift
//  BCD
//
//  Created by Liuliet.Lee on 10/11/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit

class ToDetailSegue: UIStoryboardSegue {
    
    override func perform() {
        guard let sourceVC = self.source as? ImageViewController else { return }
        guard let destinationVC = self.destination as? DetailViewController else { return }
        
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        let originFrame = sourceVC.imageView.bounds
        let imgHeight = originFrame.size.height
        
        UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [.curveEaseOut], animations: {
            sourceVC.imageView.frame = CGRect(x: 0.0, y: 0.5 * (screenHeight - imgHeight), width: screenWidth, height: imgHeight)
        }) { (isFinished) in
            if isFinished {
                sourceVC.present(destinationVC, animated: false, completion: {
                    sourceVC.imageView.frame = originFrame
                })
            }
        }
    }

}
