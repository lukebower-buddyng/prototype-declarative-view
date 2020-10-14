//
//  Reflex.swift
//  declarative-view
//
//  Created by Buddyng on 14/10/2020.
//  Copyright © 2020 Luke Ellis Bower. All rights reserved.
//

import UIKit

let globalStore = Store(state: State(), reducer: reducer)

struct State {}

enum Action {
    case action1
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

func reducer(state: inout State, action: Action) -> State {
    return state
}

class Reflex: UIViewController {
    
    let store: Store
   
    var views = [String: View]()
    var rootView = View(id: "root")
    
    var prevNode: V? = nil
    var nextNode = V(id: "container", type: .view, props: VProps(width: 0, height: 0, color: .clear), children: [])
    
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
        render(nextNode: &nextNode, prevNode: prevNode, yOrigin: 30)
    }
    
    /// Override this function to respond to changes in state
    func react(to state: State) -> V {
        return V(id: "1", type: .view, props: VProps(width: 0, height: 0, color: .clear), children: [])
    }
    
    func render(nextNode: inout V, prevNode: V? = nil, yOrigin: CGFloat? = nil) {
        // check for parent
        guard let parentId = nextNode.parentId,
            let parentView = views[parentId] else {
                print("No root")
                return
        }
        let nodeIdPath = parentId + "." + nextNode.id
        var yOrigin = yOrigin ?? parentView.frame.origin.y
        
        // check if node exists
        if views[nodeIdPath] == nil || prevNode == nil {
            // add new view if doesn't exist
            let view = View(id: nextNode.id)
            parentView.addSubview(view)
            views[nodeIdPath] = view
            // configure from scratch
            style(view: view, props: nextNode.props)
            position(parentView: parentView, view: view, yOrigin: yOrigin)
            view.layer.borderWidth = 2
            view.layer.borderColor = UIColor.white.cgColor
        }
        else {
            // apply updates compared to previous tree
            let view = views[nodeIdPath]!
            updateStyle(view: view, prevNode: prevNode!, nextNode: nextNode)
            position(parentView: parentView, view: view, yOrigin: yOrigin)
            view.layer.borderWidth = 2
            view.layer.borderColor = UIColor.black.cgColor
            // prune dead leaves (garbage collection)
            for subView in view.subviews {
                let childView = subView as! View
                if nextNode.childrenIds[childView.id] == nil { // view is not needed in next time step
                    childView.removeFromSuperview()
                }
            }
        }
        
        // render current nodes
        for i in 0 ..< nextNode.children.count {
            nextNode.children[i].parentId = nodeIdPath // set parent id
            if i == 0 {
                yOrigin = 0 // reset yOrigin for first child (to position it at the top of the parent container)
            }
            let prevChild = prevNode?.childrenIds[nextNode.children[i].id]
            render(nextNode: &nextNode.children[i], prevNode: prevChild, yOrigin: yOrigin)
            if let childView = views[nodeIdPath + "." + nextNode.children[i].id] {
                yOrigin = childView.frame.origin.y + childView.frame.height // update start position
            }
        }
    }
    
}

extension UIViewController {
    func addViewController(_ child: UIViewController) {
        addChild(child)
        child.didMove(toParent: self)
        view.addSubview(child.view)
    }
}