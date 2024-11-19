cdef class StorageUnit:
    cdef str key
    cdef str subnode_id
    cdef int replica_id

cdef class RingNode:
    cdef int node_id
    cdef object node_child
    cdef StorageUnit* storage_unit

cdef class RingLayer:
    cdef int layer_id
    cdef int prime_number
    cdef RingNode** nodes

cdef class PrimeRing:
    cdef int total_layers
    cdef RingLayer** layers
    cdef int total_nodes

