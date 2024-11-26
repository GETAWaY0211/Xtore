cdef class StorageUnit:
    def __init__(self, str key, str node_id, int replica_id=0):
        self.key = key
        self.node_id = node_id
        self.replica_id = replica_id

cdef class RingLayer:
    def __init__(self, int layer_id, int prime_number):
        self.layer_id = layer_id
        self.prime_number = prime_number
        self.nodes = []

    def add_node(self, StorageUnit node):
        if len(self.nodes) < self.prime_number:
            self.nodes.append(node)
        else:
            raise ValueError('Layer is fulled')

    def is_full(self):
        return len(self.nodes) >= self.prime_number

cdef class PrimeRing:
    def __init__(self, list prime_numbers):
        self.layers = []
        self.prime_numbers = prime_numbers

        # Initialize the first layer
        self._add_layer()

    def _add_layer(self):
        layer_id = len(self.layers)
        if layer_id < len(self.prime_numbers):
            prime_number = self.prime_numbers[layer_id]
            new_layer = RingLayer(layer_id, prime_number)
            self.layers.append(new_layer)
        else:
            raise ValueError('Reached node')

    def add_node(self, StorageUnit node):
        for layer in self.layers:
            if not layer.is_full():
                layer.add_node(node)
                return

        self._add_layer()
        self.layers[-1].add_node(node)

    def __str__(self):
        result = []
        for layer in self.layers:
            result.append(f"Layer {layer.layer_id}: {len(layer.nodes)}/{layer.prime_number} nodes")
        return "\n".join(result)
