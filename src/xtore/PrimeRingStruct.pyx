cdef class StorageUnit:
    def __init__(self, str key = NULL, str subnode_id, int replica_id = 0):
        self.key = key
        self.node_id = node_id
        self.replica_id = replica_id

cdef class RingNode:
    def __init__(self, int node_id, object node_child = NULL, StorageUnit* storage_unit):
        self.node_id = node_id
        self.child_ring = child_ring
        self.storage_unit = storage_unit

cdef class RingLayer:
    def __init__(self, int layer_id, int prime_number):
        self.layer_id = layer_id
        self.prime_number = prime_number
        self.nodes = <RingNode**>malloc(self.prime_number * sizeof(RingNode*))
        if self.nodes is NULL:
            print("failed")

        for i in range(self.prime_number):
            self.nodes[i] = NULL

    def add_node(self, int node_id, object node_chile = NULL, StorageUnit* storage_unit = NULL):
        if 0 <= node_id < self.prime_number:
            self.nodes[node_id] = RingNode(node_id, child_ring, storage_unit)
        else:
            print("failed")

    def __dealloc__(self):
        if self.nodes:
            for i in range(self.prime_number):
                if self.nodes[i]:
                    del self.nodes[i]
            free(self.nodes)

cdef class PrimeRing:
    def __init__(self, int total_layers):
        self.total_layers = total_layers
        self.layers = <RingLayer**>malloc(self.total_layers * sizeof(RingLayer*))
        if self.layers is NULL:
            raise MemoryError("Failed to allocate memory for ring layers.")

        # Initialize layers to NULL
        for i in range(self.total_layers):
            self.layers[i] = NULL

        self.total_nodes = 0

    def create_layer(self, int layer_id, int prime_number):
        if 0 <= layer_id < self.total_layers:
            if self.layers[layer_id] is not NULL:
                raise ValueError(f"Layer {layer_id} already exists.")
            self.layers[layer_id] = RingLayer(layer_id, prime_number)
        else:
            raise ValueError("Invalid layer ID.")

    def calculate_total_nodes(self):
        """
        Calculate the total number of members across all layers
        as defined by the formula in the image.
        """
        self.total_nodes = 0
        cdef int i, j
        for j in range(1, self.total_layers + 1):
            layer_product = 1
            for i in range(1, j + 1):
                if self.layers[i - 1] is not NULL:
                    layer_product *= self.layers[i - 1].prime_number
            self.total_nodes += layer_product
        return self.total_nodes

    def __dealloc__(self):
        # Free memory for layers
        if self.layers:
            for i in range(self.total_layers):
                if self.layers[i]:
                    del self.layers[i]
            free(self.layers)