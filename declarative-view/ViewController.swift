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
        view.backgroundColor = .white
        let rootView = View(id: "root")
        rootView.frame.size = view.frame.size
        
        let vd0 = V(
            id: "container",
            type: .view,
            props: VProps(width: 200, height: 200, color: .green),
            children: []
        )
        
        let vd1 = V(
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
        
        view.addSubview(render(nextNode: vd1, parentView: rootView))
    }
}

struct V {
    let id: String
    let type: VTypes
    let props: VProps
    let children: [V]
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

func render(nextNode: V, parentView: View, yOrigin: CGFloat = 0) -> View {
    let view = View(id: nextNode.id)
    // TODO add view to dict
    view.frame.size.width = nextNode.props.width
    view.frame.size.height = nextNode.props.height
    view.backgroundColor = nextNode.props.color
    
    //    switch data.type {
    //    case .view:
    //    case .text:
    //    }
    
    func position(parentView: View, view: View) {
        let parentWidth = parentView.frame.width
        let viewWidth = view.frame.width
        let insetWidth = (parentWidth - viewWidth) / 2
        view.frame.origin.x = insetWidth
        view.frame.origin.y = yOrigin
    }
    position(parentView: parentView, view: view)
    
    var yOrigin = parentView.frame.origin.y
    for child in nextNode.children {
        let childView = render(nextNode: child, parentView: view, yOrigin: yOrigin)
        view.addSubview(childView)
        yOrigin = childView.frame.origin.y + childView.frame.height
    }
    
    return view
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
