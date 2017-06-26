//
//  Tokenizer.swift
//  LootGen
//
//  Created by Harry Culpan on 6/24/17.
//  Copyright © 2017 Harry Culpan. All rights reserved.
//

import Foundation

extension String {
    
    var length: Int {
        return self.characters.count
    }
    
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func foundIn(for regex: String, in text: String) -> Bool {
        return matches(for: regex, in: text).count > 0
    }
    
    subscript (i: Int) -> String {
        return self[Range(i ..< i + 1)]
    }
    
    func substring(from: Int) -> String {
        return self[Range(min(from, length) ..< length)]
    }
    
    func substring(to: Int) -> String {
        return self[Range(0 ..< max(0, to))]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return self[Range(start ..< end)]
    }
    
}

enum TokenType {
    case tokenTable
    case tokenDieRoll
    case tokenPlus
    case tokenMultiply
    case tokenNumber
    case tokenString
    case tokenEnd
    case tokenOpenParen
    case tokenCloseParen
}

class Tokenizer {
    let expr: String
    
    var currIndex = 0
    
    init(_ expression: String) {
        self.expr = expression
    }
    
    func evaluateToken(_ token: String) -> (tokenType: TokenType, token: String) {
        if token.foundIn(for: "\\d+[d,D]\\d+", in: token) {
            return (TokenType.tokenDieRoll, token)
        } else {
            return (TokenType.tokenString, token)
        }
    }
    
    public func nextToken() -> (tokenType: TokenType, token: String) {
        var result = (TokenType.tokenEnd, "")
        var doneCurrentToken = false
        var currentToken: String = ""
        while !doneCurrentToken {
            
            switch expr[currIndex] {
            case " ":
                if !currentToken.isEmpty {
                    doneCurrentToken = true
                    result = evaluateToken(currentToken)
                }
                currIndex += 1
            case "(":
                if !currentToken.isEmpty {
                    result = evaluateToken(currentToken)
                } else {
                    result = (TokenType.tokenOpenParen, "(")
                    currIndex += 1
                }
                doneCurrentToken = true
            case ")":
                if !currentToken.isEmpty {
                    result = evaluateToken(currentToken)
                } else {
                    result = (TokenType.tokenCloseParen, ")")
                    currIndex += 1
                }
                doneCurrentToken = true
            case "+":
                if !currentToken.isEmpty {
                    result = evaluateToken(currentToken)
                } else {
                    result = (TokenType.tokenPlus, "+")
                    currIndex += 1
                }
                doneCurrentToken = true
            case "*":
                if !currentToken.isEmpty {
                    result = evaluateToken(currentToken)
                } else {
                    result = (TokenType.tokenMultiply, "*")
                    currIndex += 1
                }
                doneCurrentToken = true
            case "]":
                result = (TokenType.tokenTable, currentToken[1..<currentToken.length])
                currIndex += 1
                doneCurrentToken = true
            default:
                currentToken += expr[currIndex]
                currIndex += 1
            }
            
            if currIndex >= expr.characters.count {
                break;
            }
        }
        
        return result
    }
}
