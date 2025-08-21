import Foundation
import JavaScriptCore

/// Prettier errors
public enum PrettierError: Error, CustomStringConvertible {
    case resourceNotFound
    case jsContextInitializationFailed
    case prettierObjectNotFound
    case formattingFailed(String)
    
    public var description: String {
        switch self {
        case .resourceNotFound:
            return "prettier.bundle.min.js resource not found"
        case .jsContextInitializationFailed:
            return "Failed to initialize JavaScript context"
        case .prettierObjectNotFound:
            return "Prettier object not found in JavaScript context"
        case .formattingFailed(let message):
            return "Formatting failed: \(message)"
        }
    }
}

/// Main Prettier formatter class
public class PrettierFormatter {
    private var jsContext: JSContext?
    
    public init() throws {
        try setupJSContext()
    }
    
    /// Format code using specified parser and options (synchronous version)
    public func format(_ code: String, parser: PrettierParser, options: PrettierOptions? = nil) throws -> String {
        guard let jsContext = jsContext else {
            throw PrettierError.jsContextInitializationFailed
        }
        
        // Use RunLoop instead of semaphore, more suitable for single-threaded environment
        var result: Result<String, Error>?
        var isCompleted = false
        
        // Configure options
        let finalOptions = buildOptions(parser: parser, options: options)
        let optionsDict = buildOptionsDict(parser: parser, options: finalOptions)
        
        // Check Prettier availability
        guard jsContext.objectForKeyedSubscript("Prettier")?.isUndefined == false else {
            throw PrettierError.prettierObjectNotFound
        }
        
        // Execute formatting
        let formatScript = """
        (function(code, options) {
            // Clean up previous results
            this._prettierResult = undefined;
            this._prettierError = undefined;
            
            // Set up callback function
            this.notifySwift = function(resultValue, errorValue) {
                if (errorValue) {
                    this._prettierError = errorValue;
                } else {
                    this._prettierResult = resultValue;
                }
                this._swiftCallback && this._swiftCallback();
            };
            
            try {
                var formatResult = Prettier.format(code, options);
                if (formatResult && typeof formatResult.then === 'function') {
                    formatResult.then(function(formatted) {
                        notifySwift(formatted, null);
                    }).catch(function(error) {
                        notifySwift(null, error.message || error.toString());
                    });
                } else {
                    notifySwift(formatResult, null);
                }
            } catch(e) {
                notifySwift(null, e.message || e.toString());
            }
        })
        """
        
        let formatFunction = jsContext.evaluateScript(formatScript)
        
        // Set up Swift callback
        let swiftCallback: @convention(block) () -> Void = {
            let jsResult = jsContext.objectForKeyedSubscript("_prettierResult")
            let jsError = jsContext.objectForKeyedSubscript("_prettierError")
            
            if let errorValue = jsError, !errorValue.isUndefined, !errorValue.isNull {
                let errorMessage = errorValue.toString() ?? "Unknown formatting error"
                result = .failure(PrettierError.formattingFailed(errorMessage))
            } else if let resultValue = jsResult, !resultValue.isUndefined, !resultValue.isNull {
                let formattedCode = resultValue.toString() ?? ""
                result = .success(formattedCode)
            } else {
                result = .failure(PrettierError.formattingFailed("No result received"))
            }
            isCompleted = true
        }
        jsContext.setObject(swiftCallback, forKeyedSubscript: "_swiftCallback" as NSString)
        // Call formatting function
        formatFunction?.call(withArguments: [code, optionsDict])
        
        // Use more efficient waiting method
        let startTime = CFAbsoluteTimeGetCurrent()
        let timeout: CFAbsoluteTime = 10.0
        
        while !isCompleted {
            if CFAbsoluteTimeGetCurrent() - startTime > timeout {
                throw PrettierError.formattingFailed("Formatting operation timed out")
            }
            RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.01))
        }
        
        guard let finalResult = result else {
            throw PrettierError.formattingFailed("No formatting result received")
        }
        
        return try finalResult.get()
    }
    
    /// Helper method: build options
    private func buildOptions(parser: PrettierParser, options: PrettierOptions?) -> PrettierOptions {
        return PrettierOptions(
            parser: parser,
            printWidth: options?.printWidth ?? 80,
            tabWidth: options?.tabWidth ?? 2,
            useTabs: options?.useTabs ?? false,
            semi: options?.semi ?? true,
            singleQuote: options?.singleQuote ?? false,
            quoteProps: options?.quoteProps ?? .asNeeded,
            jsxSingleQuote: options?.jsxSingleQuote ?? false,
            trailingComma: options?.trailingComma ?? .es5,
            bracketSpacing: options?.bracketSpacing ?? true,
            bracketSameLine: options?.bracketSameLine ?? false,
            arrowParens: options?.arrowParens ?? .always,
            endOfLine: options?.endOfLine ?? .lf,
            rangeStart: options?.rangeStart ?? 0,
            rangeEnd: options?.rangeEnd ?? Int.max,
            requirePragma: options?.requirePragma ?? false,
            insertPragma: options?.insertPragma ?? false,
            proseWrap: options?.proseWrap ?? .preserve,
            htmlWhitespaceSensitivity: options?.htmlWhitespaceSensitivity ?? .css,
            vueIndentScriptAndStyle: options?.vueIndentScriptAndStyle ?? false,
            singleAttributePerLine: options?.singleAttributePerLine ?? false,
            embeddedLanguageFormatting: options?.embeddedLanguageFormatting ?? .auto
        )
    }
    
    /// Helper method: build options dictionary
    private func buildOptionsDict(parser: PrettierParser, options: PrettierOptions) -> [String: Any] {
        var optionsDict: [String: Any] = [
            "parser": parser.rawValue,
            "printWidth": options.printWidth,
            "tabWidth": options.tabWidth,
            "useTabs": options.useTabs,
            "semi": options.semi,
            "singleQuote": options.singleQuote,
            "quoteProps": options.quoteProps.rawValue,
            "jsxSingleQuote": options.jsxSingleQuote,
            "trailingComma": options.trailingComma.rawValue,
            "bracketSpacing": options.bracketSpacing,
            "bracketSameLine": options.bracketSameLine,
            "arrowParens": options.arrowParens.rawValue,
            "endOfLine": options.endOfLine.rawValue,
            "rangeStart": options.rangeStart,
            "requirePragma": options.requirePragma,
            "insertPragma": options.insertPragma,
            "proseWrap": options.proseWrap.rawValue,
            "htmlWhitespaceSensitivity": options.htmlWhitespaceSensitivity.rawValue,
            "vueIndentScriptAndStyle": options.vueIndentScriptAndStyle,
            "singleAttributePerLine": options.singleAttributePerLine,
            "embeddedLanguageFormatting": options.embeddedLanguageFormatting.rawValue
        ]
        
        if options.rangeEnd != Int.max {
            optionsDict["rangeEnd"] = options.rangeEnd
        }
        
        return optionsDict
    }
    
    private func setupJSContext() throws {
        // Load Prettier bundle
        guard let bundlePath = Bundle.module.url(forResource: "prettier.bundle.min", withExtension: "js"),
              let bundleContent = try? String(contentsOf: bundlePath) else {
            throw PrettierError.resourceNotFound
        }
        
        // Initialize JavaScript context
        jsContext = JSContext()
        
        // Set up error handling
        jsContext?.exceptionHandler = { context, exception in
            print("JavaScript error: \(exception?.description ?? "Unknown error")")
        }
        
        // Load and execute the Prettier bundle
        guard let context = jsContext else {
            throw PrettierError.jsContextInitializationFailed
        }
        
        // Execute the bundle - don't check return value as it may be undefined for valid bundles
        context.evaluateScript(bundleContent)
        
        // Find Prettier object using a more systematic approach
        let prettierObj = findPrettierObject(in: context)
        guard let prettier = prettierObj else {
            throw PrettierError.prettierObjectNotFound
        }
        
        // Validate format function availability
        try validateFormatFunction(prettier)
    }
    
    /// Find Prettier object in JavaScript context
    private func findPrettierObject(in context: JSContext) -> JSValue? {
        // Priority order for finding Prettier
        let searchPaths = [
            "Prettier",           // Direct global
            "this.Prettier",      // Global this
            "window.Prettier",    // Window object (if exists)
            "globalThis.Prettier" // Modern global reference
        ]
        
        for path in searchPaths {
            if let obj = context.evaluateScript(path), !obj.isUndefined && !obj.isNull {
                return obj
            }
        }
        
        return nil
    }
    
    /// Validate that Prettier object has a working format function
    private func validateFormatFunction(_ prettierObj: JSValue) throws {
        // Check direct format function
        let formatFunction = prettierObj.objectForKeyedSubscript("format")
        let hasDirectFormat = formatFunction?.isUndefined == false
        
        // Check default export format function
        let defaultExport = prettierObj.objectForKeyedSubscript("default")
        let defaultFormatFunction = defaultExport?.objectForKeyedSubscript("format")
        let hasDefaultFormat = defaultFormatFunction?.isUndefined == false
        
        guard hasDirectFormat || hasDefaultFormat else {
            throw PrettierError.formattingFailed("Prettier.format function not found")
        }
        
        // Optional: Test format function with a simple case
        #if DEBUG
        testFormatFunction(prettierObj)
        #endif
    }
    
    /// Test format function with a simple case (Debug only)
    private func testFormatFunction(_ prettierObj: JSValue) {
        let testScript = """
        (function() {
            try {
                var testResult = Prettier.format('const x=1;', {parser: 'babel'});
                return typeof testResult === 'string' || (testResult && typeof testResult.then === 'function');
            } catch(e) {
                return false;
            }
        })()
        """
        
        if let testResult = jsContext?.evaluateScript(testScript), testResult.toBool() {
            print("✅ Prettier format function validated successfully")
        } else {
            print("⚠️  Prettier format function validation failed")
        }
    }
}
