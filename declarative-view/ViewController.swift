//
//  ViewController.swift
//  declarative-view
//
//  Created by Buddyng on 12/10/2020.
//  Copyright © 2020 Luke Ellis Bower. All rights reserved.
//

import UIKit
import MaterialComponents

let containerScheme = MDCContainerScheme()
let colorScheme = MDCSemanticColorScheme(defaults: .material201804)

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let reflex = Screen1()
        addViewController(reflex)
        reflex.view.frame.size = view.frame.size
        view.backgroundColor = .white
        
        containerScheme.colorScheme = colorScheme
    }
}

class Screen1: ReflexRender {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func react(to state: State) -> VirtualView {
        return V(
                 id: "container",
                 style: Style(width: view.frame.width, height: view.frame.height, color: state.color),
                    children: [
                        VC(
                           id: "one",
                           props: VCProps(color: .lightGray, width: 400, height: 200),
                           children: [
                                VB(
                                   id: "button",
                                   props: VBProps(action: { self.store.dispatch(action: .changeColor) }),
                                   style: Style(width: 100, height: 100, color: .black),
                                   children: []
                                ),
                                T(id: "text", props: TProps(text: "Hello World"), style: Style(width: 200, height: 100, color: .orange),  children: []),
                                T(id: "text2", props: TProps(text: "Hello World"), style: Style(width: 200, height: 100, color: .orange),  children: [])
                        ])
                    ]
                )
    }
}

let globalStore = Store(state: State(), reducer: reducer)

struct State {
    var color = UIColor.white
}

enum Action {
    case changeColor
}

func reducer(state: inout State, action: Action) -> State {
    switch action {
    case .changeColor:
        if state.color == UIColor.white {
            state.color = .lightGray
        } else {
            state.color = UIColor.white
        }
        return state
    }
}
