//
//  PrettierOptions.swift
//  Prettier
//
//  Created by wong on 8/21/25.
//


/// Prettier parser types
public enum PrettierParser: String, CaseIterable, Identifiable {
    public var id: String { rawValue }
    case babel = "babel"
    case babelFlow = "babel-flow"
    case babelTs = "babel-ts"
    case flow = "flow"
    case typescript = "typescript"
    case acorn = "acorn"
    case espree = "espree"
    case meriyah = "meriyah"
    case css = "css"
    case less = "less"
    case scss = "scss"
    case json = "json"
    case json5 = "json5"
    case jsonStringify = "json-stringify"
    case graphql = "graphql"
    case markdown = "markdown"
    case mdx = "mdx"
    case vue = "vue"
    case yaml = "yaml"
    case glimmer = "glimmer"
    case html = "html"
    case angular = "angular"
    case lwc = "lwc"
}

/// Quote properties options
public enum QuoteProps: String, CaseIterable, Identifiable {
    public var id: String { rawValue }
    /// Only add quotes around object properties where required
    case asNeeded = "as-needed"
    /// If at least one property in an object requires quotes, quote all properties
    case consistent = "consistent"
    /// Respect the input use of quotes in object properties
    case preserve = "preserve"
}

/// Trailing comma options
public enum TrailingComma: String, CaseIterable, Identifiable {
    public var id: String { rawValue }
    /// No trailing commas
    case none = "none"
    /// Trailing commas where valid in ES5 (objects, arrays, etc.)
    case es5 = "es5"
    /// Trailing commas wherever possible (including function arguments)
    case all = "all"
}

/// Arrow function parentheses options
public enum ArrowParens: String, CaseIterable, Identifiable {
    public var id: String { rawValue }
    /// Omit parentheses when possible (x => x)
    case avoid = "avoid"
    /// Always include parentheses ((x) => x)
    case always = "always"
}

/// End of line options
public enum EndOfLine: String, CaseIterable, Identifiable {
    public var id: String { rawValue }
    /// Maintain existing line endings (mixed values within one file are normalised by looking at what's used after the first line)
    case auto = "auto"
    /// Line Feed only (\n), common on Linux and macOS as well as inside git repos
    case lf = "lf"
    /// Carriage Return + Line Feed characters (\r\n), common on Windows
    case crlf = "crlf"
    /// Carriage Return character only (\r), used very rarely
    case cr = "cr"
}

/// Prose wrap options
public enum ProseWrap: String, CaseIterable, Identifiable {
    public var id: String { rawValue }
    /// Wrap prose if it exceeds the print width
    case always = "always"
    /// Do not wrap prose
    case never = "never"
    /// Wrap prose as-is
    case preserve = "preserve"
}

/// HTML whitespace sensitivity options
public enum HTMLWhitespaceSensitivity: String, CaseIterable, Identifiable  {
    public var id: String { rawValue }
    /// Respect the default value of CSS display property
    case css = "css"
    /// All whitespaces are considered significant
    case strict = "strict"
    /// All whitespaces are considered insignificant
    case ignore = "ignore"
}

/// Embedded language formatting options
public enum EmbeddedLanguageFormatting: String, CaseIterable, Identifiable {
    public var id: String { rawValue }
    /// Format embedded code if Prettier can automatically identify it
    case auto = "auto"
    /// Never automatically format embedded code
    case off = "off"
}

/// Comprehensive Prettier options
public struct PrettierOptions {
    /// Specify which parser to use
    public var parser: PrettierParser
    
    /// The line length where Prettier will try wrap (default: 80)
    public var printWidth: Int
    
    /// Number of spaces per indentation level (default: 2)
    public var tabWidth: Int
    
    /// Indent with tabs instead of spaces (default: false)
    public var useTabs: Bool
    
    /// Print semicolons at the ends of statements (default: true)
    public var semi: Bool
    
    /// Use single quotes instead of double quotes (default: false)
    public var singleQuote: Bool
    
    /// Change when properties in objects are quoted (default: "as-needed")
    public var quoteProps: QuoteProps
    
    /// Use single quotes in JSX (default: false)
    public var jsxSingleQuote: Bool
    
    /// Print trailing commas wherever possible when multi-line (default: "es5")
    public var trailingComma: TrailingComma
    
    /// Print spaces between brackets in object literals (default: true)
    public var bracketSpacing: Bool
    
    /// Put the `>` of a multi-line HTML (HTML, JSX, Vue, Angular) element at the end of the last line
    /// instead of being alone on the next line (does not apply to self closing elements, default: false)
    public var bracketSameLine: Bool
    
    /// Include parentheses around a sole arrow function parameter (default: "always")
    public var arrowParens: ArrowParens
    
    /// Which end of line characters to apply (default: "lf")
    public var endOfLine: EndOfLine
    
    /// Format only a segment of a file - start offset (default: 0)
    public var rangeStart: Int
    
    /// Format only a segment of a file - end offset (default: Number.POSITIVE_INFINITY)
    public var rangeEnd: Int
    
    /// Prettier can restrict itself to only format files that contain a special comment, called a pragma, at the top of the file.
    /// This is very useful when gradually transitioning large, unformatted codebases to prettier. (default: false)
    public var requirePragma: Bool
    
    /// Prettier can insert a special @format marker at the top of files specifying that
    /// the file has been formatted with prettier. This works well when used in tandem with
    /// the --require-pragma option. If there is already a docblock at the top of
    /// the file then this option will add a newline to it with the @format marker. (default: false)
    public var insertPragma: Bool
    
    /// By default, Prettier will wrap markdown text as-is since some services use a linebreak-sensitive renderer.
    /// In some cases you may want to rely on editor/viewer soft wrapping instead, so this option allows you to opt out. (default: "preserve")
    public var proseWrap: ProseWrap
    
    /// How to handle whitespaces in HTML (default: "css")
    public var htmlWhitespaceSensitivity: HTMLWhitespaceSensitivity
    
    /// Whether or not to indent the code inside <script> and <style> tags in Vue files (default: false)
    public var vueIndentScriptAndStyle: Bool
    
    /// Enforce single attribute per line in HTML, Vue and JSX (default: false)
    public var singleAttributePerLine: Bool
    
    /// Control whether Prettier formats quoted code embedded in the file (default: "auto")
    public var embeddedLanguageFormatting: EmbeddedLanguageFormatting
    
    public init(
        parser: PrettierParser,
        printWidth: Int = 80,
        tabWidth: Int = 2,
        useTabs: Bool = false,
        semi: Bool = true,
        singleQuote: Bool = false,
        quoteProps: QuoteProps = .asNeeded,
        jsxSingleQuote: Bool = false,
        trailingComma: TrailingComma = .es5,
        bracketSpacing: Bool = true,
        bracketSameLine: Bool = false,
        arrowParens: ArrowParens = .always,
        endOfLine: EndOfLine = .lf,
        rangeStart: Int = 0,
        rangeEnd: Int = Int.max,
        requirePragma: Bool = false,
        insertPragma: Bool = false,
        proseWrap: ProseWrap = .preserve,
        htmlWhitespaceSensitivity: HTMLWhitespaceSensitivity = .css,
        vueIndentScriptAndStyle: Bool = false,
        singleAttributePerLine: Bool = false,
        embeddedLanguageFormatting: EmbeddedLanguageFormatting = .auto
    ) {
        self.parser = parser
        self.printWidth = printWidth
        self.tabWidth = tabWidth
        self.useTabs = useTabs
        self.semi = semi
        self.singleQuote = singleQuote
        self.quoteProps = quoteProps
        self.jsxSingleQuote = jsxSingleQuote
        self.trailingComma = trailingComma
        self.bracketSpacing = bracketSpacing
        self.bracketSameLine = bracketSameLine
        self.arrowParens = arrowParens
        self.endOfLine = endOfLine
        self.rangeStart = rangeStart
        self.rangeEnd = rangeEnd
        self.requirePragma = requirePragma
        self.insertPragma = insertPragma
        self.proseWrap = proseWrap
        self.htmlWhitespaceSensitivity = htmlWhitespaceSensitivity
        self.vueIndentScriptAndStyle = vueIndentScriptAndStyle
        self.singleAttributePerLine = singleAttributePerLine
        self.embeddedLanguageFormatting = embeddedLanguageFormatting
    }
}
