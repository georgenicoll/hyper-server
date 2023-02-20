use std::net::SocketAddr;
use std::env;

use hyper::{Request, Body, Response, Method, StatusCode, server::conn::Http, service::service_fn};
use tokio::net::TcpListener;

//service handler
async fn echo(req: Request<Body>) -> Result<Response<Body>, hyper::Error> {
    match (req.method(), req.uri().path()) {
        //Server some instructions at /
        (&Method::GET, "/") => {
            Ok(Response::new(Body::from("Try posting some data to /echo or /echo/reversed")))
        },

        //Simple echo back to the client
        (&Method::POST, "/echo") => {
            Ok(Response::new(req.into_body()))
        },

        (&Method::POST, "/echo/reversed") => {
            let whole_body = hyper::body::to_bytes(req.into_body()).await?;
            let reversed_body = whole_body.iter().rev().cloned().collect::<Vec<u8>>();
            Ok(Response::new(Body::from(reversed_body)))
        },

        _ => {
            println!("Unknown path: {}", req.uri().path());
            let mut not_found = Response::default();
            *not_found.status_mut() = StatusCode::NOT_FOUND;
            Ok(not_found)
        },
    }
}

const PORT: u16 = 3000;

#[tokio::main(flavor = "current_thread")]
async fn main() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let args = env::args().collect::<Vec<_>>();
    let port = match args.len() {
        0 | 1 => PORT,
        _ => args.get(1).map(|arg| arg.parse::<u16>().unwrap()).unwrap(),
    };
    println!("Will try to listen on port {}", port);

    let addr = SocketAddr::from(([0, 0, 0, 0], port));
    let listener = TcpListener::bind(addr).await?;
    println!("Listening on http://{}", addr);

    loop {
        let (stream, _) = listener.accept().await?;
        println!("Connection from {}", stream.peer_addr().map_or("error on peer_addr".to_string(), |peer_addr| peer_addr.to_string()));
        tokio::task::spawn(async move {
            if let Err(err) = Http::new().serve_connection(stream, service_fn(echo)).await {
                println!("Error serving connection: {:?}", err);
            }
        });
    }
}
