//
//  React.swift
//  declarative-view
//
//  Created by Buddyng on 14/10/2020.
//  Copyright © 2020 Luke Ellis Bower. All rights reserved.
//

import UIKit

struct VB: VirtualView {
    var id: String
    var parentId: String? = "root"
    var children: [VirtualView]
    var childrenIds = [String : VirtualView]()
    var props: VBProps
    init(parentId: String? = nil, id: String, props: VBProps, children: [VirtualView]) {
        self.id = id
        self.props = props
        self.children = children
        for child in children {
            childrenIds[child.id] = child
        }
        if let parentId = parentId {
            self.parentId = parentId
        }
    }
    func create(parentView: UIView, yOrigin: CGFloat) -> UIView {
        let button = Button()
        button.id = id
        button.frame.size.width = 100
        button.frame.size.height = 30
        button.setTitle("Button", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .purple
        button.action = props.action
        button.addTarget(button, action: #selector(Button.run), for: .touchUpInside)
        return button
    }
    func update(view: UIView, parentView: UIView, prevNode: VirtualView?, yOrigin: CGFloat) {
        // TODO add checks to only update if virtual node changed
        let button = view as! Button
        button.frame.size.width = 100
        button.frame.size.height = 30
        button.setTitle("Button", for: .normal)
        button.setTitleColor(.black, for: .normal)
    }
}
struct VBProps {
    let action: ()->()
}

struct V: VirtualView {
    let id: String
    let props: VProps
    var children: [VirtualView]
    var parentId: String? = "root"
    var childrenIds = [String: VirtualView]()
    init(parentId: String? = nil, id: String, props: VProps, children: [VirtualView]) {
        self.id = id
        self.props = props
        self.children = children
        for child in children {
            childrenIds[child.id] = child
        }
        if let parentId = parentId {
            self.parentId = parentId
        }
    }
    func create(parentView: UIView, yOrigin: CGFloat) -> UIView  {
        let view = UIView()
        view.id = id
        style(view: view, props: props)
        position(parentView: parentView, view: view, yOrigin: yOrigin)
        return view
    }
    func update(view: UIView, parentView: UIView, prevNode: VirtualView? = nil, yOrigin: CGFloat) {
        if let prevNode = prevNode as? V {
            updateStyle(view: view, prevNode: prevNode, nextNode: self)
        }
        position(parentView: parentView, view: view, yOrigin: yOrigin)
    }
    func style(view: UIView, props: VProps) {
        view.frame.size.width = props.width
        view.frame.size.height = props.height
        view.backgroundColor = props.color
    }
    func position(parentView: UIView, view: UIView, yOrigin: CGFloat) {
        let parentWidth = parentView.frame.width
        let viewWidth = view.frame.width
        let insetWidth = (parentWidth - viewWidth) / 2
        view.frame.origin.x = insetWidth
        view.frame.origin.y = yOrigin
    }
    func updateStyle(view: UIView, prevNode: V, nextNode: V) {
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
}
struct VProps {
    let width: CGFloat
    let height: CGFloat
    let color: UIColor
}

protocol VirtualView {
    var id: String { get }
    var parentId: String? { get set }
    var children: [VirtualView] { get set }
    var childrenIds: [String: VirtualView] { get set }
    func create(parentView: UIView, yOrigin: CGFloat) -> UIView
    func update(view: UIView, parentView: UIView, prevNode: VirtualView?, yOrigin: CGFloat)
}

func render(views: inout [String: UIView], nextNode: inout VirtualView, prevNode: VirtualView? = nil, yOrigin: CGFloat? = nil) {
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
        let view = nextNode.create(parentView: parentView, yOrigin: yOrigin)
        parentView.addSubview(view)
        views[nodeIdPath] = view
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
    }
    else {
        // apply updates compared to previous tree
        let view = views[nodeIdPath]!
        nextNode.update(view: view, parentView: parentView, prevNode: prevNode, yOrigin: yOrigin)
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.black.cgColor
        // prune dead leaves (garbage collection)
        for subView in view.subviews {
            if nextNode.childrenIds[subView.id ?? ""] == nil { // view is not needed in next time step
                subView.removeFromSuperview()
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
        render(views: &views, nextNode: &nextNode.children[i], prevNode: prevChild, yOrigin: yOrigin)
        if let childView = views[nodeIdPath + "." + nextNode.children[i].id] {
            yOrigin = childView.frame.origin.y + childView.frame.height // update start position
        }
    }
}

extension UIView {
    var id: String? {
        get {
            return self.accessibilityIdentifier
        }
        set {
            self.accessibilityIdentifier = newValue
        }
    }
    func view(withId id: String) -> UIView? {
        if self.id == id {
            return self
        }
        for view in self.subviews {
            if let view = view.view(withId: id) {
                return view
            }
        }
        return nil
    }
}

class Button: UIButton {
    var action: ()->() = {}
    @objc func run() {
        action()
    }
}
