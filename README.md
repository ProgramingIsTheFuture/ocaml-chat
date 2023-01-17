# Simple one on one chat

### OCaml version

The ocaml version used is 4.14.0 with Lwt and Logs libraries.

### Build:

`dune build`

### Execution:

`./_build/default/main.exe <option>`

`option` can be one of the following: 
`s` or `server`; `c` or `client`

### Functionalities

A client can read and write text messages. 
Besides the basic functionality, 
it can choose the server address to connect.

A server can see when a user is connecting, 
when the user disconnects, 
and it can also read and send text messages.

The sender always receives messages of this type:
`System: Message received | Time: 0.000440`
After it, we confirmed that the message was received and took this time to complete.

### Common

`common.ml` contains common functions used 
in both the client and the server.
