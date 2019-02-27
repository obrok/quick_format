use std::io::prelude::*;
use std::io::stdin;
use std::net::TcpStream;

fn main() -> std::io::Result<()> {
    let mut stream = TcpStream::connect("127.0.0.1:8090")?;

    let stdin = stdin();
    let locked = &mut stdin.lock();
    let mut input = String::new();
    locked.read_line(&mut input)?;

    stream.write(&input.into_bytes())?;
    let mut result = String::new();
    stream.read_to_string(&mut result)?;

    println!("{}", result);

    Ok(())
}
