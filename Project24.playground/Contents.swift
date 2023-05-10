import UIKit

// MARK: STRINGS ARE NOT ARRAYS

// One of the things that confuses learners is that Swift’s strings look like arrays of letters, but that’s not really true.

// Sure, we can loop over them like this:
let name = "Taylor"

for letter in name {
    print("Give me a \(letter)")
}

// However, we can’t read individual letters from the string. So, this kind of code won’t work:

// print(name[3])

// The reason for this is that letters in a string aren’t just a series of alphabetical characters – they can contain accents such as á, é, í, ó, or ú, they can contain combining marks that generate wholly new characters by building up symbols, or they can even be emoji.

// Because of this, if you want to read the fourth character of name you need to start at the beginning and count through each letter until you come to the one you’re looking for:
let letter = name[name.index(name.startIndex, offsetBy: 3)]


// Apple could change this easily enough by adding a rather complex extension like this:
extension String {
    
    // subscript is a special kind of method, that reads into values like arrays, strings, and dictionaries
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}

// With that in place, we can now read name[3] just fine.
let letter2 = name[3]


// However, it creates the possibility that someone might write code that loops over a string reading individual letters, which they might not realize creates a loop within a loop (outer loop - going through letters, and the inner loop - "offsetBy: i" which is counting through characters every time they want to read a single letter) so it has the potential to be slow.

// Similarly, reading name.count isn’t a quick operation: Swift literally needs to go over every letter counting up however many there are, before returning that. As a result, it’s always better to use someString.isEmpty rather than someString.count == 0 if you’re looking for an empty string.





// MARK: WORKING WITH STRINGS

// We’ve used strings in lots of the projects so far, and I’ve tried to introduce you to a handful of important properties and methods as we go. Here, though, I’m going to run through some of those, plus a few more, while also looking at how we can write extensions to make strings a little more useful.

// First, there are methods for checking whether a string starts with or ends with a substring: hasPrefix() and hasSuffix().
let password = "12345"
password.hasPrefix("123")
password.hasSuffix("456")


// We can add extension methods to String to extend the way prefixing and suffixing works:
extension String {
    func deletingPrefix(_ prefix: String) -> String {
        // If we don't have prefix, go ahead and return ourselves as we are.
        guard self.hasPrefix(prefix) else { return self }
        
        // But if we do have the prefix, we'll drop the prefix from the string, and we'll send that back
        return String(self.dropFirst(prefix.count))
    }
        
        // Remove a suffix if it exists.
    func deletingSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
    
// That uses the dropFirst() and dropLast() method of String, which removes a certain number of letters from either end of the string.
}

password.deletingPrefix("1")
password.deletingSuffix("345")



// We’ve used lowercased() and uppercased() in previous projects, but there’s also the capitalized property that gives the first letter of each word a capital letter.
let weather = "it's going to rain"
print(weather.capitalized)


// We could add our own specialized capitalization that uppercases only the first letter in our string:
extension String {
    var capitalizedFirst: String {
        // If string has no first letter, just bail out immediately an empty string, couse the string is empty.
        guard let firstLetter = self.first else { return "" }
        
        // Make the first uppercase, and append the rest as they were.
        return firstLetter.uppercased() + self.dropFirst()
    }
}
// One thing you can’t see in that is an interesting subtlety of working with strings: individual letters in strings aren’t instances of String, but are instead instances of Character – a dedicated type for holding single-letters of a string.

// So, that uppercased() method is actually a method on Character rather than String. However, where things get really interesting is that Character.uppercased() actually returns a string, not an uppercased Character. The reason is simple: language is complicated, and although many languages have one-to-one mappings between lowercase and uppercase characters, some do not.

// For example, in English “a” maps to “A”, “b” to “B”, and so on, but in German “ß” becomes “SS” when uppercased. “SS” is clearly two separate letters, so uppercased() has no choice but to return a string.




// One last useful method of strings is contains(), which returns true if it contains another string. So, this will return true:
let input = "Swift is like Objective-C without the C"
input.contains("Swift")

// So, contains() takes a string parameter and returns true or false depending on whether that parameter exists in the string. That will also return true, because arrays have a contains() method that returns true or false depending on whether they contain the element you were looking for.
let languages = ["Python", "Ruby", "Swift"]
languages.contains("Swift")


// Now for the part that confuses people – brace yourself!

// We have an array of strings (["Python", "Ruby", "Swift"]) and we have an input string ("Swift is like Objective-C without the C"). How can we check whether any string in our array exists in our input string?

// Well, we might start writing an extension on String like this:
extension String {
    func containsOfAny(of array: [String]) -> Bool {
        for item in array {
            if self.contains(item) {
                return true
            }
        }
        
        return false
    }
}

// We can now run our check like this:
input.containsOfAny(of: languages)


// That certainly works, but it’s not elegant – and Swift has a better solution built right in.

// You see, arrays have a second contains() method called contains(where:). This lets us provide a closure that accepts an element from the array as its only parameter and returns true or false depending on whatever condition we decide we want. This closure gets run on all the items in the array until one returns true, at which point it stops.

// Now let’s put together the pieces:

    // When used with an array of strings, the contains(where:) method wants to call a closure that accepts a string and returns true or false.
    // The contains() method of String accepts a string as its parameter and returns true or false.
    // Swift massively blurs the lines between functions, methods, closures, and more.

// So, what we can actually do is pass one function directly into the other, like this:
languages.contains(where: input.contains)


// Don’t feel bad if you need to read that single line of code several times – it’s not easy! Let’s break it down.

// contains(where:) will call its closure once for every element in the languages array until it finds one that returns true, at which point it stops.

// In that code we’re passing input.contains as the closure that contains(where:) should run. This means Swift will call input.contains("Python") and get back false, then it will call input.contains("Ruby") and get back false again, and finally call input.contains("Swift") and get back true – then stop there.

// So, because the contains() method of strings has the exact same signature that contains(where:) expects (take a string and return a Boolean), this works perfectly – do you see what I mean about how Swift blurs the lines between these things?





// MARK: FORMATTING STRINGS WITH NSATTRIBUTEDSTRING

// Swift’s strings are plain text, which works fine in the vast majority of cases we work with text. But sometimes we want more – we want to be able to add formatting like bold or italics, select from different fonts, or add some color, and for those jobs we have a new class called NSAttributedString.

// Attributed strings are made up of two parts: a plain Swift string, plus a dictionary containing a series of attributes that describe how various segments of the string are formatted. In its most basic form you might want to create one set of attributes that affect the whole string, like this:
let string = "This is the a string"

let attributes: [NSAttributedString.Key: Any] = [
    .foregroundColor: UIColor.white,
    .backgroundColor: UIColor.red,
    .font: UIFont.systemFont(ofSize: 36)
]

let attributedString = NSAttributedString(string: string, attributes: attributes)

// It’s common to use an explicit type annotation when making attributed strings, because inside the dictionary we can just write things like .foregroundColor for the key rather than NSAttributedString.Key.foregroundColor.

// The values of the attributes dictionary are of type Any, because NSAttributedString attributes can be all sorts of things: numbers, colors, fonts, paragraph styles, and more.

// If you look in the output panel of your playground, you should be able to click on the box next to where it says “This is a test string” to get a live preview of how our string looks – you should see large, white text with a red background.

// Of course, we could get the same effect with a regular string placed inside a UILabel: change the font and colors, and it would look the same. But what labels can’t do is add formatting to different parts of the string.

// To demonstrate this we’re going to use NSMutableAttributedString, which is an attributed string that you can modify:

let attributedString2 = NSMutableAttributedString(string: string)

attributedString2.addAttribute(.font, value: UIFont.systemFont(ofSize: 8), range: NSRange(location: 0, length: 4))
attributedString2.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 5, length: 2))
attributedString2.addAttribute(.font, value: UIFont.systemFont(ofSize: 24), range: NSRange(location: 8, length: 1))
attributedString2.addAttribute(.font, value: UIFont.systemFont(ofSize: 32), range: NSRange(location: 10, length: 4))

// When you preview that you’ll see the font size get larger with each word – something a regular Swift string certainly can’t do even with help from UILabel.

// There are lots of formatting options for attributed strings, including:

// Set .underlineStyle to a value from NSUnderlineStyle to strike out characters.
// Set .strikethroughStyle to a value from NSUnderlineStyle (no, that’s not a typo) to strike out characters.
// Set .paragraphStyle to an instance of NSMutableParagraphStyle to control text alignment and spacing.
// Set .link to be a URL to make clickable links in your strings.

// And that’s just a subset (podzbiór) of what you can do.

// You might be wondering how useful all this knowledge is, but here’s the important part: UILabel, UITextField, UITextView, UIButton, UINavigationBar, and more all support attributed strings just as well as regular strings. So, for a label you would just use attributedText rather than text, and UIKit takes care of the rest.






// MARK: CHALLENGES

// 1. Create a String extension that adds a withPrefix() method. If the string already contains the prefix it should return itself; if it doesn’t contain the prefix, it should return itself with the prefix added. For example: "pet".withPrefix("car") should return “carpet”.

extension String {
    func withPrefix(_ prefix: String) -> String {
        guard !self.contains(prefix) else { return self }
        return prefix + self
    }
}

let example = "pet"
example.withPrefix("car")


// 2. Create a String extension that adds an isNumeric property that returns true if the string holds any sort of number. Tip: creating a Double from a String is a failable initializer.

extension String {
    var isNumeric: Bool {
        !(self.isEmpty) && self.contains(where: { $0.isNumber })
    }
}

let example2 = "pet9"
example2.isNumeric


// 3. Create a String extension that adds a lines property that returns an array of all the lines in a string. So, “this\nis\na\ntest” should return an array with four elements.

extension String {
    var lines: [String] {
        // .newlines property works the same as the "\n" break line.
        self.components(separatedBy: .newlines)
    }
}

let example3 = "this\nis\na\ntest"
example3.lines
