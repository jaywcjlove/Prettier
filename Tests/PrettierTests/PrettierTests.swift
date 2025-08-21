import Testing
@testable import Prettier

@Test func testSpecialCharacters() async throws {
    let formatter = try PrettierFormatter()
    let unformattedCSS = """
    .class::before{content:"Hello 'world'\\aNew line\\9Tab";color:red;}
    """
    let formatterCSS = """
    .class::before {
      content: "Hello 'world'\\aNew line\\9Tab";
      color: red;
    }
    """
    let formattedCSS = try formatter.format(unformattedCSS, parser: .css)
    #expect(formatterCSS == formattedCSS.trimmingCharacters(in: .whitespacesAndNewlines))
    #expect(formattedCSS.contains(".class::before"))
    #expect(formattedCSS.contains("content:"))
    #expect(formattedCSS.contains("color: red"))
}

@Test func testBasicFormatting() async throws {
    let formatter = try PrettierFormatter()
    let unformattedCSS = """
    @media (max-width: 480px) {
      .bd-examples {margin-right: -.75rem;margin-left: -.75rem
      }
      
     .bd-examples>[class^="col-"]  {
        padding-right: .75rem;
        padding-left: .75rem;
      }
    }
    """
    let formatterCSS = """
    @media (max-width: 480px) {
      .bd-examples {
        margin-right: -0.75rem;
        margin-left: -0.75rem;
      }
    
      .bd-examples > [class^="col-"] {
        padding-right: 0.75rem;
        padding-left: 0.75rem;
      }
    }
    """
    let formattedCSS = try formatter.format(unformattedCSS, parser: .css)
    #expect(formatterCSS == formattedCSS.trimmingCharacters(in: .whitespacesAndNewlines))
}
