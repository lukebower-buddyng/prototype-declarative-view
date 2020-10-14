//
//  React.swift
//  declarative-view
//
//  Created by Buddyng on 14/10/2020.
//  Copyright © 2020 Luke Ellis Bower. All rights reserved.
//

import UIKit

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
