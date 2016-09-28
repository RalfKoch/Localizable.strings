//
//  IOSLocalizationFile.swift
//  Localizabler
//
//  Created by Cristian Baluta on 02/10/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class IOSLocalizationFile: LocalizationFile {
	
	var url: URL?
	var hasChanges: Bool = false
	fileprivate var lines = [Line]()
	fileprivate var terms = [String: String]()// term: value
	fileprivate var translations = [String: String]()// term: translation
    // Regex to validate a line containing term and translation
	fileprivate let lineRegex = try? NSRegularExpression(pattern: "^(\"|[ ]*\")(.+?)\"(^|[ ]*)=(^|[ ]*)\"(.*?)\"(;|;[ ]*)$",
	                                                     options: NSRegularExpression.Options())
    fileprivate let separatorRegex = try? NSRegularExpression(pattern: "\"(^|[ ]*)=(^|[ ]*)\"",
                                                              options: NSRegularExpression.Options())
	
    required init (url: URL) throws {
		self.url = url
        if let data = try? Data(contentsOf: url) {
            if let fileContent = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String {
                self.parseContent(fileContent)
            }
            else if let fileContent = NSString(data: data, encoding: String.Encoding.unicode.rawValue) as? String {
                self.parseContent(fileContent)
            }
        } else {
            throw(LocalizationFileError.fileNotFound(url: url))
        }
    }
	
	required init (content: String) {
		self.parseContent(content)
	}
	
	// Set
	func updateTerm (_ term: String, newValue: String) {
		terms[term] = newValue
		hasChanges = true
	}
    
    func updateTranslationForTerm (_ term: String, newValue: String) {
        translations[term] = newValue
		hasChanges = true
    }
	
	func addLine (_ line: Line) {
		lines.append(line)
		terms[line.term] = line.term
        translations[line.term] = line.translation
        hasChanges = true
	}
    
    func removeTerm(_ term: TermData) {
        if let lineIndex = lines.index( where: { $0.term == term.value || $0.term == term.newValue } ) {
            print(lines[lineIndex])
            lines.remove(at: lineIndex)
        }
        terms.removeValue(forKey: term.value)
        translations.removeValue(forKey: term.value)
        if let newValue = term.newValue {
            terms.removeValue(forKey: newValue)
            translations.removeValue(forKey: newValue)
        }
        hasChanges = true
    }
	
	// Get
	func allLines() -> [Line] {
		return lines
	}
	
	func allTerms() -> [String] {
		return Array(terms.keys)
	}
	
	func translationForTerm (_ term: String) -> String {
		return translations[term] ?? ""
	}
	
	func content() -> String {
		
		var string = ""
		
		// Iterate over lines and put them back in the string with the new translations
        var i = 0
		for line in lines {
			if line.isComment {
				string += line.translation
			}
			else {
				string += "\"\(terms[line.term]!)\" = \"\(translationForTerm(line.term))\";"
			}
            i += 1
            if i < lines.count {
                string += "\n"
            }
		}
		
		return string
	}
}

extension IOSLocalizationFile {
	
	fileprivate func parseContent (_ content: String) {
		
		let lines = content.components(separatedBy: CharacterSet.newlines)
		for line in lines {
			parseLine(line)
		}
	}
	
	@inline(__always) func parseLine (_ lineContent: String) {
		
		if isValidLine(lineContent) {
			addLine(splitLine(lineContent))
		} else {
			lines.append((term: "", translation: lineContent, isComment: true))
		}
	}
	
	@inline(__always) func isValidLine (_ lineContent: String) -> Bool {
        
		return lineRegex!.numberOfMatches(in: lineContent,
		                                  options: NSRegularExpression.MatchingOptions(),
		                                  range: NSMakeRange(0, lineContent.characters.count)) == 1
	}
	
	@inline(__always) func splitLine (_ lineContent: String) -> Line {
		
		// TODO: Better splitting
        let separator = separatorRegex!.firstMatch(in: lineContent,
                                                   options: NSRegularExpression.MatchingOptions(),
                                                   range: NSMakeRange(0, lineContent.characters.count))
        let nsString = lineContent as NSString?
        let newLineContent = nsString?.replacingCharacters(in: separator!.range, with: "::separator::")
		let comps = newLineContent!.components(separatedBy: "::separator::")
		
		return (term:			String(comps.first!.trim().characters.dropFirst()),
				translation:	String(comps.last!.trim().characters.dropLast().dropLast()),
				isComment:		false)
	}
}
