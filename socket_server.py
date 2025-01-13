import sys
from socket import socket, AF_INET, SOCK_STREAM

def start_server(port):
    server = socket(AF_INET, SOCK_STREAM)
    server.bind(('localhost', port))
    server.listen(5)
    print(f"Server running on port {port}")
    while True:
        client, address = server.accept()
        print(f"Connection from {address}")
        # Handle client connection
        client.close()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python socket_server.py <port>")
        sys.exit(1)

    port = int(sys.argv[1])
    start_server(port)
