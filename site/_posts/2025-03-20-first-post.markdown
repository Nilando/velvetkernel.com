---
layout: post
title:  "I made a Lexer in Rust"
date:   2025-03-19 12:00:00 -0800
categories: compilers
---
Over the past few months, I’ve been working on building a scripting language in 
Rust as a hobby project. This project has taught me a lot about both the Rust 
language and the design and components of compilers. I started this blog as a 
way to share what I’m learning and, hopefully, to reinforce my understanding 
through writing.

I thought I would make the first blog post be about the first component I wrote
for my scripting language—the lexer.

A lexer (sometimes called a scanner or tokenizer) is a fundamental component of a parser that breaks down a source file 
into logical pieces, usually called tokens. The lexer gets its name from the 
fact that it defines the languages lexicon, which is the set of meaningful 
tokens of the language.

A lexer might take the following input...
{% highlight rust %}
fn double(n) {
    return n * 2;
}
{% endhighlight %}

And return a sequence of tokens...

```
Token::KeyWord(KeyWord::Fn), 
Token::Identifier("Double"), 
Token::Ctrl(Ctrl::LeftParen), 
Token::Identifier("n"), 
Token::Ctrl(Ctrl::RightParen), 
...
```

#### Why turn the input into tokens?

Tokens help abstract the process of reading individual bytes from the source 
file. When the lexer sends tokens to the parser, the parser only needs to focus 
on verifying their order—essentially checking whether the program has valid 
syntax.

Writing a lexer by hand is essentially like constructing a giant 
non-deterministic finite automaton (NFA), where each character read transitions 
the lexer into a new state. If the NFA reaches an accepting state, it may 
successfully recognize a valid token.

I find the lexer to be one of the simpler components of a compiler. I was able 
to write mine by hand in just [500 lines of code](https://github.com/Nilando/nilang/blob/main/src/parser/lexer.rs), 
and I could have likely reduced that by more than half if I had used a prebuilt 
lexer crate like [logos](https://github.com/maciejhirsz/logos).

Also a key feature of the lexer I wrote is that it pairs tokens to where it 
found them in the source file. This is critical if you want to display useful 
errors that explain exactly where something went wrong.

### Performance

Since the lexer must process every character in a source file, its methods tend 
to run hot. Even for small files, the lexer may execute its tokenizing functions 
hundreds of times.

While the lexer is likely one of the fastest components of a compiler due to its 
relatively simple task, it’s crucial that it runs efficiently since it is 
invoked so frequently during compilation.

I’m not very experienced with benchmarking, but I have used [Criterion](https://bheisler.github.io/criterion.rs/book/) 
a few times and found it to be a great framework. To measure my lexer’s 
performance, I set up a simple Criterion benchmark to test its throughput while 
parsing some example files from start to finish.

The criterion results showed my lexer to parse source files at a rate of about 
200 Mib/s - not that bad!

My lexer is probably relatively slow in terms of how fast lexers can get and yet 
is still plenty fast for my hobby project. One thing that is probably slowing 
it down significantly is that it accepts utf8 encoded input as opposed to just 
ascii. Each utf8 encoded char is needs to be processed as 4 bytes as opposed to
ascii where each char is just a byte. 

It could be an interesting exercise to try and speed this up. 
I've heard that SIMD instructions can greatly speed up lexing, maybe that could 
make a good blog post for another time.

### Summary

Lexers are cool and used in parsing. You might want to use one if you're 
going to make a parser. 
