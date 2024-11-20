cdef class StorageUnit:
    cdef str key
    cdef str subnode_id
    #cdef int replica_id

cdef class RingNode:
    cdef int node_id
    cdef object node_child
    cdef StorageUnit* storage_unit

cdef class RingLayer:
    cdef int layer_id
    cdef int prime_number
    cdef RingNode** nodes
    def add_node(self, int node_id, object node_chile, StorageUnit* storage_unit)

cdef class PrimeRing:
    cdef int total_layers
    cdef RingLayer** layers
    cdef int total_nodes
    def add_layer(self, int layer_id, int prime_number)

