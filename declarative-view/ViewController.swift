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
        _ = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(changeColor), userInfo: nil, repeats: true)
    }
    @objc func changeColor() {
        store.dispatch(action: .changeColor)
    }
    override func react(to state: State) -> V {
        return V(
                    id: "container",
                    type: .view,
                    props: VProps(width: 200, height: 200, color: state.color),
                    children: [
                        V(id: "one", type: .view, props: VProps(width: 100, height: 200, color: .cyan), children: [])
                    ]
                )
    }
}
