//typealias Parser<A> = (String) -> A

struct Parser<A> {
//  let run: (String) -> A?
//  let run: (String) -> (match: A?, rest: String)
//  let run: (inout String) -> A?
  let run: (inout Substring) -> A?

  func run(_ str: String) -> (match: A?, rest: Substring) {
    var str = str[...]
    let match = self.run(&str)
    return (match, str)
  }
}

let int = Parser<Int> { str in
  let prefix = str.prefix(while: { $0.isNumber })
  guard let int = Int(prefix) else { return nil }
  str.removeFirst(prefix.count)
  return int
}


//Substring


int.run("42")
int.run("42 Hello World")
int.run("Hello World")


do { // 1
    let char = Parser<Character> { str in
        guard let match = str.first else { return nil }
        str.removeFirst()
        return match
    }

    char.run("abc")
    char.run("")
}

do { // 2
    let ws = Parser<Void> { str in
        let prefix = str.prefix(while: { $0.isWhitespace })
        guard prefix.count > 0 else { return nil }
        str.removeFirst(prefix.count)
        return ()
    }

    ws.run("  abc")
    ws.run("abc")
    ws.run(" \n \tabc")
}

do { // 3, 5
    struct Token {
        let value: String
        var parser: Parser<String> {
            let parser = Parser<String> { str in
                if str.hasPrefix(self.value) {
                    str.removeFirst(self.value.count)
                } else { return nil }
                return self.value
            }
            return parser
        }
    }

    let int = Parser<Int> { str in
        let sign = Token(value: "-")
        let mult = sign.parser.run(&str) != nil ? -1 : +1

        let prefix = str.prefix(while: { $0.isNumber })
        guard let int = Int(prefix) else { return nil }
        str.removeFirst(prefix.count)
        return int * mult
    }

    int.run("42")
    int.run("42 Hello World")
    int.run("Hello World")
    int.run("-42")

    "42" |> int.run
    let sign = Token(value: "-")
    String(("-42" |> sign.parser.run).rest) |> int.run
}

do { // 6



}
