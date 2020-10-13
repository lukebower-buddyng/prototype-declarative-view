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
        
        // init root node
        let rootNode = V(id: "root", type: .view, props: VProps(
            width: view.frame.width, height: view.frame.height, color: .gray),
         children: [])
        nodes[rootNode.id] = rootNode
        
        // init root view
        let rootView = View(id: "root")
        rootView.frame.size = view.frame.size
        rootView.backgroundColor = .gray
        view.addSubview(rootView)
        views[rootView.id] = rootView
        
        // virtual tree state 0
        let v0 = V(
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
        
        render(nextNode: &v1, prevNode: v0)
    }
}

var views = [String: View]()
var nodes = [String: V]()

func render(nextNode: inout V, prevNode: V? = nil, yOrigin: CGFloat? = nil) {
    
    // check for parent
    guard let parentId = nextNode.parentId,
        let parentView = views[parentId] else {
            print("No root")
            return
    }
    
    // update nodes store
    let nodeIdPath = parentId + "." + nextNode.id
    nodes[nodeIdPath] = nextNode
    
    // TODO check if nodes are different
    
    // add new view
    let view = View(id: nextNode.id)
    parentView.addSubview(view)
    views[nodeIdPath] = view
    
    var yOrigin = yOrigin ?? parentView.frame.origin.y
    style(view: view, props: nextNode.props)
    position(parentView: parentView, view: view, yOrigin: yOrigin)
    
    for i in 0..<nextNode.children.count {
        nextNode.children[i].parentId = nodeIdPath // set parent id
        render(nextNode: &nextNode.children[i], yOrigin: yOrigin)
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

struct V {
    let id: String
    let type: VTypes
    let props: VProps
    var children: [V]
    var parentId: String? = "root"
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
