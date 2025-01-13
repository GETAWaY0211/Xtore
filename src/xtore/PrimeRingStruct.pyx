cdef class StorageUnit:
    def __init__(self, str key, str node_id, int replica_id=0):
        self.key = key
        self.node_id = node_id
        self.replica_id = replica_id

cdef class RingLayer:
    def __init__(self, int layer_id, int prime_number, int total_nodes):
        self.layer_id = layer_id
        self.prime_number = prime_number
        self.total_nodes = total_nodes
        self.nodes = []

    cdef add_node(self, StorageUnit node):
        if len(self.nodes) < self.prime_number:
            self.nodes.append(node)
        else:
            raise ValueError('Layer is fulled')

    cdef is_fulled(self):
        return len(self.nodes) >= self.total_nodes

cdef class PrimeRing:
    def __init__(self, list prime_numbers):
        self.layers = []
        self.prime_numbers = prime_numbers
        self.add_layer()

    cdef add_layer(self):
        int total_nodes
        layer_id = len(self.layers)
        if layer_id < len(self.prime_numbers):
            prime_number = self.prime_numbers[layer_id]
            for i in range(0, layer_id)
                total_nodes = prime_number[i]*total_nodes
            new_layer = RingLayer(layer_id, prime_number, total_nodes)
            self.layers.append(new_layer)
        else:
            raise ValueError('Reached node')

    cdef add_node(self, StorageUnit node):
        for layer in self.layers:
            if not layer.is_fulled():
                layer.add_node(node)
                return

        self.add_layer()
        self.layers[-1].add_node(node)

    cdef print_str(self):
        result = []
        for layer in self.layers:
            result.append(f'Layer {layer.layer_id}: {len(layer.nodes)}/{layer.prime_number} nodes')
        return "\n".join(result)
