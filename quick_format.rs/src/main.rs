use std::io::prelude::*;
use std::io::stdin;
use std::net::TcpStream;
use std::path::Path;
use std::fs;

fn main() -> std::io::Result<()> {
    let formatter_exs = find_formatter_exs()?;
    let mut stream = TcpStream::connect("127.0.0.1:8090")?;

    stream.write(&formatter_exs.into_bytes())?;
    stream.write(&"\0\n".to_string().into_bytes())?;

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

fn find_formatter_exs() -> std::io::Result<String> {
    let path = fs::canonicalize(Path::new("."))?
        .ancestors()
        .map(|dir| dir.join(".formatter.exs"))
        .find(|candidate| candidate.exists());

    match path {
        None => Ok("[]".to_string()),
        Some(path) => fs::read_to_string(path),
    }
}
