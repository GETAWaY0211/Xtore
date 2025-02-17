from xtore.BaseType cimport i32, u64

cdef class PrimeRingP:
	cdef list layers
	cdef list nodes
	cdef i32 numLayers
	cdef list primeNumbers
	cdef i32 maxNodeLayer

	cdef u64 getNode(self, u64 key)
	cdef u64 getIndex(self, u64 key, i32 layer)
	cdef insertNode(self, dict info)
	cdef insertLayer(self)
	
"""
cdef class PrimeRingP:
	cdef list layers
	cdef list primeNumbers
	cdef i32 numLayers
	cdef list nodes

	cdef dict createNode(self, i32 nodeID)
	cdef i32 getNode(self, u64 key)
	cdef i32 getIndex(self, u64 key, i32 layer)
	cdef insertNode(self, i32 nodeID, i32 layer)
	cdef insertLayer(self)
"""

cdef class TreeNode:
	cdef i32 nodeID
	cdef i32 prime
	cdef i32 port
	cdef list child

	cdef addChild(self, TreeNode child)