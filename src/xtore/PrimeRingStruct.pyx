cdef class StorageUnit:
    def __init__(self, str key = NULL, str subnode_id, int replica_id = 0):
        self.key = key
        self.node_id = node_id
        self.replica_id = replica_id
   
cdef class RingNode:
    def __init__(self, int node_id, object node_child = NULL, StorageUnit* storage_unit):
        self.node_id = node_id
        self.node_child = node_child
        self.storage_unit = storage_unit

cdef class RingLayer:
    def __init__(self, int layer_id, int prime_number):
        self.layer_id = layer_id
        self.prime_number = prime_number
        self.nodes = <RingNode**>malloc(self.prime_number * sizeof(RingNode*))
        for i in range(self.prime_number):
            self.nodes[i] = NULL

    def add_node(self, int node_id, object node_chile = NULL, StorageUnit* storage_unit = NULL):
        if 0 <= node_id < self.prime_number:
            self.nodes[node_id] = RingNode(node_id, node_child, storage_unit)
        else:
            print("failed")

cdef class PrimeRing:
    def __init__(self, int total_layers):
        self.total_layers = total_layers
        self.layers = <RingLayer**>malloc(self.total_layers * sizeof(RingLayer*))
        self.layers[layer_id] = RingLayer(layer_id, prime_number)
        for i in range(self.total_layers):
            self.layers[i] = NULL
        self.total_nodes = 0

    def add_layer(self, int layer_id, int prime_number):
        self.total_layer += 1
        self.layers[layer_id] = RingLayer(layer_id, prime_number)

    def cal_nodes(self):