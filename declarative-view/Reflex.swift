//
//  Reflex.swift
//  declarative-view
//
//  Created by Buddyng on 14/10/2020.
//  Copyright © 2020 Luke Ellis Bower. All rights reserved.
//

import UIKit

let globalStore = Store(state: State(), reducer: reducer)

struct State {
    var color = UIColor.darkGray
}

class Store {
    var reducer: (inout State, Action) -> State
    var state: State
    
    init(state: State, reducer: @escaping (inout State, Action) -> State) {
        self.reducer = reducer
        self.state = state
    }
    
    public func dispatch(action: Action) {
        let nextState = reducer(&state, action)
        state = nextState
        NotificationCenter.default.post(name: Notification.Name("StateUpdated"), object: nil)
    }
}

enum Action {
    case changeColor
}

func reducer(state: inout State, action: Action) -> State {
    switch action {
    case .changeColor:
        if state.color == UIColor.darkGray {
            state.color = .black
        } else {
            state.color = UIColor.darkGray
        }
        return state
    }
}

class Reflex: UIViewController {
    
    let store: Store
   
    var views = [String: View]()
    var rootView = View(id: "root")
    
    var prevNode: VirtualView? = nil
    var nextNode: VirtualView = V(id: "container", props: VProps(width: 0, height: 0, color: .clear), children: [])
    
    init() {
        self.store = globalStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.store = globalStore
        super.init(coder: coder)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(reflex), name: Notification.Name("StateUpdated"), object: nil)
        // init root view
        rootView.frame.size = view.frame.size
        rootView.backgroundColor = .gray
        view.addSubview(rootView)
        views[rootView.id] = rootView
        
        reflex()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(true)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("StateUpdated"), object: nil)
    }
    
    func add(_ reflex: UIViewController) {
        super.addViewController(reflex)
    }
    
    @objc func reflex() {
        prevNode = nextNode
        nextNode = react(to: store.state)
        render(views: &views, nextNode: &nextNode, prevNode: prevNode, yOrigin: 30)
    }
    
    /// Override this function to respond to changes in state
    func react(to state: State) -> VirtualView {
        return V(id: "0", props: VProps(width: 0, height: 0, color: .clear), children: [])
    }
    
}

extension UIViewController {
    func addViewController(_ child: UIViewController) {
        addChild(child)
        child.didMove(toParent: self)
        view.addSubview(child.view)
    }
}
