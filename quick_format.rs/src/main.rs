use std::io::prelude::*;
use std::io::stdin;
use std::net::TcpStream;

fn main() -> std::io::Result<()> {
    let mut stream = TcpStream::connect("127.0.0.1:8090")?;

    let stdin = stdin();
    let locked = &mut stdin.lock();

    let mut buffer = Vec::new();
    locked.read_to_end(&mut buffer)?;
    stream.write(&buffer)?;
    stream.write(&"\0\n".to_string().into_bytes())?;

    let mut result = String::new();
    stream.read_to_string(&mut result)?;

    println!("{}", result);

    Ok(())
}
