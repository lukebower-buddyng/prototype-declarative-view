//
//  Render.swift
//  declarative-view
//
//  Created by Buddyng on 15/10/2020.
//  Copyright © 2020 Luke Ellis Bower. All rights reserved.
//

import UIKit

let debug = false

func render(views: inout [String: UIView], nextNode: inout VirtualView, prevNode: VirtualView? = nil, yOrigin: CGFloat? = nil) {
    // check for parent
    guard let parentId = nextNode.parentId,
        let parentView = views[parentId] else {
            print("No root")
            return
    }
    let nodeIdPath = parentId + "." + nextNode.id
    
    let yOrigin = yOrigin ?? parentView.frame.origin.y
    
    // check if node exists
    if views[nodeIdPath] == nil || prevNode == nil {
        // add new view if doesn't exist
        let view = nextNode.create(parentView: parentView, yOrigin: yOrigin)
        parentView.addSubview(view)
        views[nodeIdPath] = view
    }
    else {
        // apply updates compared to previous tree
        let view = views[nodeIdPath]!
        nextNode.update(view: view, parentView: parentView, prevNode: prevNode, yOrigin: yOrigin)
        // prune dead leaves (garbage collection)
        for subView in view.subviews {
            if subView.id != nil && nextNode.childrenIds[subView.id!] == nil { // view is not needed in next time step
                subView.removeFromSuperview()
            }
        }
    }
    
    nextNode.layoutChildren(views: &views, nextNode: &nextNode, prevNode: prevNode, nodeIdPath: nodeIdPath, yOrigin: yOrigin)
}
