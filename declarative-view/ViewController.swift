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
        
        // init root view
        let rootView = View(id: "root")
        rootView.frame.size = view.frame.size
        rootView.backgroundColor = .gray
        view.addSubview(rootView)
        views[rootView.id] = rootView
        
        // virtual tree state 0
        var v0 = V(
            parentId: "root",
            id: "container",
            type: .view,
            props: VProps(width: 200, height: 200, color: .green),
            children: []
        )
        
        // virtual tree state 1
        var v1 = V(
            parentId: "root",
            id: "container",
            type: .view,
            props: VProps(width: 200, height: 200, color: .green),
            children: [
                V(
                    id: "blue",
                    type: .view,
                    props: VProps(width: 100, height: 100, color: .blue),
                    children: [
                        V(
                            id: "black",
                            type: .view,
                            props: VProps(width: 50, height: 50, color: .black),
                            children: []
                        )
                    ]
                ),
                V(
                    id: "red",
                    type: .view,
                    props: VProps(width: 100, height: 100, color: .red),
                    children: []
                ),

            ]
        )
        
        // virtual tree state 2
               var v2 = V(
                   parentId: "root",
                   id: "container",
                   type: .view,
                   props: VProps(width: 200, height: 200, color: .green),
                   children: [
                        V(
                            id: "red",
                            type: .view,
                            props: VProps(width: 100, height: 100, color: .red),
                            children: []
                        ),
                        V(
                           id: "blue",
                           type: .view,
                           props: VProps(width: 100, height: 100, color: .blue),
                           children: [
                               V(
                                   id: "black",
                                   type: .view,
                                   props: VProps(width: 50, height: 50, color: .black),
                                   children: []
                               )
                           ]
                        ),
                   ]
               )
        
        render(nextNode: &v0, yOrigin: 100)
        render(nextNode: &v1, prevNode: v0, yOrigin: 100)
        render(nextNode: &v2, prevNode: v1, yOrigin: 100)
        
        trees.append(contentsOf: [v0, v1, v2])
        
        var _ = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(renderNext), userInfo: nil, repeats: true)

    }
    
    var trees = [V]()
    var currentTree = 0
    @objc func renderNext() {
        render(nextNode: &trees[(currentTree + 1) % trees.count], prevNode: trees[currentTree % trees.count], yOrigin: 100)
        currentTree += 1
    }
}

var views = [String: View]()

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

func style(view: View, props: VProps) {
    view.frame.size.width = props.width
    view.frame.size.height = props.height
    view.backgroundColor = props.color
}

func position(parentView: View, view: View, yOrigin: CGFloat) {
    let parentWidth = parentView.frame.width
    let viewWidth = view.frame.width
    let insetWidth = (parentWidth - viewWidth) / 2
    view.frame.origin.x = insetWidth
    view.frame.origin.y = yOrigin
}

func updateStyle(view: View, prevNode: V, nextNode: V) {
    if prevNode.props.height != nextNode.props.height {
        view.frame.size.height = nextNode.props.height
    }
    if prevNode.props.width != nextNode.props.width {
        view.frame.size.width = nextNode.props.width
    }
    if prevNode.props.color != nextNode.props.color {
        view.backgroundColor = nextNode.props.color
    }
}
func updatePosition() {}

struct V {
    let id: String
    let type: VTypes
    let props: VProps
    var children: [V]
    var parentId: String? = nil
    var childrenIds = [String: V]()
    init(parentId: String? = nil, id: String, type: VTypes, props: VProps, children: [V]) {
        self.id = id
        self.type = type
        self.props = props
        self.children = children
        for child in children {
            childrenIds[child.id] = child
        }
        if let parentId = parentId {
            self.parentId = parentId
        }
    }
}

enum VTypes {
    case view
    case text
}

struct VProps {
    let width: CGFloat
    let height: CGFloat
    let color: UIColor
}

class View: UIView {
    let id: String
    
    init(id: String) {
        self.id = id
        super.init(frame: CGRect())
    }
    
    required init?(coder: NSCoder) {
        self.id = ""
        super.init(coder: coder)
    }
}
