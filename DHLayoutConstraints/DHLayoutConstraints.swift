//
//  DHLayoutConstraints.swift
//  DHLayoutConstraints
//
//  Created by Derrick Ho on 11/22/15.
//  Copyright © 2015 dnthome. All rights reserved.
//

public typealias DHConstraintTuple = Any

enum DHConstraintRelation: String, StringLiteralConvertible {
	case EqualTo = "=="
	case GreaterThanOrEqualTo = ">="
	case LessThanOrEqualTo = "<="
	
	init(stringLiteral value: String) {
		self = DHConstraintRelation(rawValue: value)!
	}
	init(unicodeScalarLiteral value: String) {
		self = DHConstraintRelation(rawValue: value)!
	}
	init(extendedGraphemeClusterLiteral value: String) {
		self = DHConstraintRelation(rawValue: value)!
	}
}

// MARK: - Enable a view for AutoLayout
prefix operator |~| { }
public prefix func |~|(view: UIView) {
	view.translatesAutoresizingMaskIntoConstraints = false
}

postfix operator |~| { }
public postfix func |~|(view: UIView) {
	view.translatesAutoresizingMaskIntoConstraints = false
}

func verifyTuple(tuple: [DHConstraintTuple]) -> (relation: DHConstraintRelation, distance: Int, view: (UIView, heightOrWidth: String)) {
	var relation: DHConstraintRelation = .EqualTo
	var distance: Int = 0
	var view: UIView? = nil
	var viewHeight: (UIView, height: String)? = nil
	var viewWidth: (UIView, width: String)? = nil
	
	switch tuple.count {
	case 1...3:
		tuple.forEach({
			if let r = $0 as? String {
				relation = DHConstraintRelation(rawValue: r) ?? .EqualTo
			} else if let r = $0 as? DHConstraintRelation {
				relation = r
			} else if let d = $0 as? Int {
				distance = d
			} else if let v = $0 as? UIView {
				view = v
			} else if let vh = $0 as? (UIView, height: Int) {
				viewHeight = (vh.0, height: "(\(vh.1))")
			} else if let vw = $0 as? (UIView, width: Int) {
				viewWidth = (vw.0, width: "(\(vw.1))")
			} else {
				assertionFailure("Invalid type")
			}
		})
		
		return
			(relation: relation, distance: distance,
				view:
				(viewWidth != nil)
					? (viewWidth!.0, heightOrWidth: viewWidth!.1)
					: (viewHeight != nil)
					? (viewHeight!.0, heightOrWidth: viewHeight!.1)
					: (view!, heightOrWidth: "")
		)
	default:
		assertionFailure("Illegal tuple Size")
	}
	return ("", Int(), (UIView(), heightOrWidth: ""))
}

// MARK: - HORIZONTAL Leading to Superview
infix operator |-> { associativity left precedence 150 } // 1
public func |->(left: Void, right: [DHConstraintTuple]) -> [NSLayoutConstraint] { // 2
	let tuple = verifyTuple(right)
	let w = tuple.view.heightOrWidth
	let r = tuple.relation.rawValue
	let d = tuple.distance
	let v = tuple.view.0
	return NSLayoutConstraint.constraintsWithVisualFormat("H:|-\(r)\(d)-[v\(w)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["v":v])
}

// MARK: - HORIZONTAL Trailing to SuperView
infix operator <-| { associativity right precedence 150 } // 1
public func <-|(left: [DHConstraintTuple], right: Void) -> [NSLayoutConstraint] { // 2
	let tuple = verifyTuple(left)
	let w = tuple.view.heightOrWidth
	let r = tuple.relation.rawValue
	let d = tuple.distance
	let v = tuple.view.0
	return NSLayoutConstraint.constraintsWithVisualFormat("H:[v\(w)]-\(r)\(d)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["v":v])
}

// MARK: - VERTICAL Top to Superview
infix operator |-^ { associativity left precedence 150 } // 1
public func |-^(left: Void, right: [DHConstraintTuple]) -> [NSLayoutConstraint] { // 2
	let tuple = verifyTuple(right)
	let h = tuple.view.heightOrWidth
	let r = tuple.relation.rawValue
	let d = tuple.distance
	let v = tuple.view.0
	return NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(r)\(d)-[v\(h)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["v":v])
}

// MARK: - VERTICAL Bottom to SuperView
infix operator ^-| { associativity right precedence 150 } // 1
public func ^-|(left: [DHConstraintTuple], right: Void) -> [NSLayoutConstraint] { // 2
	let tuple = verifyTuple(left)
	let h = tuple.view.heightOrWidth
	let r = tuple.relation.rawValue
	let d = tuple.distance
	let v = tuple.view.0
	return NSLayoutConstraint.constraintsWithVisualFormat("V:[v\(h)]-\(r)\(d)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["v":v])
}