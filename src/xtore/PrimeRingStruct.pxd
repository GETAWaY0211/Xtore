from libc.stdint cimport int64_t
from xtore.BaseType cimport i32, i64

cdef class StorageUnit:
    cdef str key
    cdef str subnode_id
    cdef int replica_id

cdef class RingLayer:
    cdef int layer_id
    cdef int prime_number
    cdef list nodes
    cdef int total_nodes
    cdef add_node(self, StorageUnit node)
    cdef is_fulled(self)
 
cdef class PrimeRing:
    cdef list layers             
    cdef list prime_numbers 
    cdef add_layer(self)
    cdef add_node(self, StorageUnit node)
    cdef print_str(self)

