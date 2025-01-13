import socket
import json
import os

def start_server(port, storage_dir):
    # Create storage directory if it doesn't exist
    os.makedirs(storage_dir, exist_ok=True)

    # Initialize the socket server
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind(('localhost', port))
    server.listen(5)
    print(f"Server running on port {port}")

    while True:
        client_socket, client_address = server.accept()
        print(f"Connection from {client_address}")

        # Receive data from client
        data = b""
        while True:
            chunk = client_socket.recv(4096)
            if not chunk:
                break
            data += chunk

        try:
            # Decode JSON data
            json_data = json.loads(data.decode('utf-8'))

            # Save JSON data to a file
            file_path = os.path.join(storage_dir, f"data_{client_address[1]}.json")
            with open(file_path, 'w') as f:
                json.dump(json_data, f, indent=4)

            print(f"Saved JSON data to {file_path}")
            client_socket.send(b"File received and saved successfully.")
        except json.JSONDecodeError:
            print("Received invalid JSON.")
            client_socket.send(b"Invalid JSON format.")
        except Exception as e:
            print(f"Error: {e}")
            client_socket.send(f"Error: {e}".encode('utf-8'))

        # Close the connection
        client_socket.close()

if __name__ == "__main__":
    PORT = 8001
    STORAGE_DIR = "received_files"
    start_server(PORT, STORAGE_DIR)
