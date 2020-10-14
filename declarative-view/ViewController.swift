//
//  ViewController.swift
//  declarative-view
//
//  Created by Buddyng on 12/10/2020.
//  Copyright © 2020 Luke Ellis Bower. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let reflex = Screen1()
        addViewController(reflex)
        reflex.view.frame.size = view.frame.size
    }
}

class Screen1: Reflex {
    override func react(to state: State) -> V {
        return V(
                    id: "container",
                    type: .view,
                    props: VProps(width: 200, height: 200, color: .green),
                    children: []
                )
    }
}
