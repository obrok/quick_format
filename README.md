# QuickFormat

A faster alternative for `mix format`. Works by running an elixir server in the background and
sending data to format to it via TCP. This is faster than just running `mix format`, because it
avoids the cost of starting up BEAM:

```bash
$ time echo "[ ]" | mix format -
[]

real	0m0.633s
user	0m0.559s
sys	0m0.260s

$ time echo "[ ]" | target/release/quick_format
[]

real	0m0.010s
user	0m0.002s
sys	0m0.003s
```

Saving half a second might not matter when reformatting your whole project, but it's significant
if you run format on save as part of your normal workflow.

## Installation

Requires rust and elixir, recommended versions specified in `.tool-versions`. Start the server
by running:

```bash
mix run --no-halt
```

Build the client with:

```bash
cd quick_format.rs
cargo build --release
```

Your formatter is availabled in `quick_format.rs/target/quick_format`:

```bash
$ echo "[ ]" | quick_format.rs/target/release/quick_format
[]
```
