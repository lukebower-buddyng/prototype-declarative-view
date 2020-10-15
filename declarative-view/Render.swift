//
//  Render.swift
//  declarative-view
//
//  Created by Buddyng on 15/10/2020.
//  Copyright © 2020 Luke Ellis Bower. All rights reserved.
//

import UIKit

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
