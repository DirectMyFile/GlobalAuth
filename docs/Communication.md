# Connection

The protocol's way of communicating is through a socket. Once a web socket
connection is established, it must invoke the "Auth" action to perform any other
action available on the server.

# Socket data

All data is transmitted in UTF-8 encoding and each message is delimited by
a carriage return line feed.

# Performing requests

Requests are sent and received through JSON. All names are case sensitive.
All requests and responses are handled synchronously.

## Request layout

```json
{
  "action": "",
  "params": {}
}
```

* Action - Name of the action to invoke.
* Params - Parameters the action takes, can be omitted if the action
           requires no parameters.

## Response layout

```json
{
  "results": {},
  "error": "",
  "status": 0
}
```

* Results - Results from action invocation. Omitted on error.
* Error - An error description. Omitted on success.
* Status - 0 is always a success, Any other is a failure and varies depending on the action.
           Any negative constants, including 0, are reserved by the protocol. Any
           positive constants, starting with 1, are free to be defined by the action.
  * 0 - Success
  * -1 - JSON parsing error
  * -2 - Internal server error
  * -3 - Undefined action
  * -4 - Missing parameter (optional parameters can be defined by the action)
