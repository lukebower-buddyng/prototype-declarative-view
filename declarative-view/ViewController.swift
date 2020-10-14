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
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func react(to state: State) -> VirtualView {
        return V(
                    id: "container",
                    props: VProps(width: 200, height: 200, color: state.color),
                    children: [
                        V(id: "one", props: VProps(width: 100, height: 200, color: .cyan), children: [
                            VB(id: "button", props: VBProps(action: {
                                self.store.dispatch(action: .changeColor)
                            }), children: []),
                        ])
                    ]
                )
    }
}
