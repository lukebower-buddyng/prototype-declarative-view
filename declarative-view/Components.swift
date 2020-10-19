//
//  React.swift
//  declarative-view
//
//  Created by Buddyng on 14/10/2020.
//  Copyright © 2020 Luke Ellis Bower. All rights reserved.
//

import UIKit
import MaterialComponents
import MaterialComponents.MaterialButtons_Theming

let defaultStyle = Style(width: 100, height: 100, color: .black)

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

protocol VirtualView {
    var id: String { get }
    var parentId: String? { get set }
    var children: [VirtualView] { get set }
    var childrenIds: [String: VirtualView] { get set }
    func create(parentView: UIView, yOrigin: CGFloat) -> UIView
    func update(view: UIView, parentView: UIView, prevNode: VirtualView?, yOrigin: CGFloat)
}


class View: UIView {
    init(id: String) {
        super.init(frame: CGRect())
        self.id = id
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.id = ""
    }
}

struct Style {
    let width: CGFloat
    let height: CGFloat
    let color: UIColor
}

class V: VirtualView {
    var parentId: String? = "root"
    let id: String
    let style: Style
    var children = [VirtualView]()
    var childrenIds = [String: VirtualView]()
    init(parentId: String? = nil, id: String, style: Style = defaultStyle, children: [VirtualView] = []) {
        self.id = id
        self.children = children
        self.style = style
        for child in children {
            childrenIds[child.id] = child
        }
        if let parentId = parentId {
            self.parentId = parentId
        }
    }
    func create(parentView: UIView, yOrigin: CGFloat) -> UIView  {
        let view = View(id: id)
        style(view: view, props: style)
        position(parentView: parentView, view: view, yOrigin: yOrigin)
        return view
    }
    func update(view: UIView, parentView: UIView, prevNode: VirtualView? = nil, yOrigin: CGFloat) {
        if let prevNode = prevNode as? V {
            updateStyle(view: view, prevNode: prevNode, nextNode: self)
        }
        position(parentView: parentView, view: view, yOrigin: yOrigin)
    }
    func style(view: UIView, props: Style) {
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
        if prevNode.style.height != nextNode.style.height {
            view.frame.size.height = nextNode.style.height
        }
        if prevNode.style.width != nextNode.style.width {
            view.frame.size.width = nextNode.style.width
        }
        if prevNode.style.color != nextNode.style.color {
            view.backgroundColor = nextNode.style.color
        }
    }
    func updatePosition() {}
}


class Text: UILabel {
    init(id: String) {
        super.init(frame: CGRect())
        self.id = id
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.id = ""
    }
}

struct TProps {
    let text: String
}

class T: V {
    var props: TProps
    
    init(parentId: String? = nil, id: String, props: TProps, style: Style = defaultStyle, children: [VirtualView] = []) {
        self.props = props
        super.init(parentId: parentId, id: id, style: style, children: children)
    }
    
    override func create(parentView: UIView, yOrigin: CGFloat) -> UIView {
        let view = Text(id: id)
        view.text = props.text
        view.textColor = .black
        view.frame.size.width = 100
        view.frame.size.height = 30
        return view
    }
    
    override func update(view: UIView, parentView: UIView, prevNode: VirtualView?, yOrigin: CGFloat) {
        let view = view as! Text
        view.text = props.text
        view.textColor = .black
        view.frame.size.width = 100
        view.frame.size.height = 30
    }
}


class Button: MDCButton {
    init(id: String) {
        super.init(frame: CGRect())
        self.id = id
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.id = ""
    }
    
    var action: ()->() = {}
    
    @objc func run() {
        action()
    }
}

struct VBProps {
    let action: ()->()
}

class VB: V {
    var props: VBProps
    
    init(parentId: String? = nil, id: String, props: VBProps, style: Style = defaultStyle, children: [VirtualView] = []) {
        self.props = props
        super.init(parentId: parentId, id: id, style: style, children: children)
    }
    
    override func create(parentView: UIView, yOrigin: CGFloat) -> UIView {
        let button = Button(id: id)
        button.applyContainedTheme(withScheme: containerScheme)
        button.frame.size.width = 150
        button.frame.size.height = 60
        button.setTitle("Button", for: .normal)
        button.action = props.action
        button.addTarget(button, action: #selector(Button.run), for: .touchUpInside)
        return button
    }
    
    override func update(view: UIView, parentView: UIView, prevNode: VirtualView?, yOrigin: CGFloat) {
        // TODO add checks to only update if virtual node changed
//        let button = view as! Button
//        button.frame.size.width = 100
//        button.frame.size.height = 30
//        button.action = props.action
//        button.addTarget(button, action: #selector(Button.run), for: .touchUpInside)
    }
}


struct VCProps {
    let color: UIColor
    let width: CGFloat
    let height: CGFloat
}
class Card: MDCCard {
    init(id: String) {
        super.init(frame: CGRect())
        self.id = id
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.id = ""
    }
}

class VC: V {
    var props: VCProps
    init(parentId: String? = nil, id: String, props: VCProps, style: Style = defaultStyle, children: [VirtualView] = []) {
        self.props = props
        super.init(parentId: parentId, id: id, style: style, children: children)
    }
    override func create(parentView: UIView, yOrigin: CGFloat) -> UIView {
        let card = Card(id: id)
        card.applyTheme(withScheme: containerScheme)
        card.backgroundColor = props.color
        card.frame.size.width = props.width
        card.frame.size.height = props.height
        return card
    }
    override func update(view: UIView, parentView: UIView, prevNode: VirtualView?, yOrigin: CGFloat) {
        //let card = view as! Card
    }
}
