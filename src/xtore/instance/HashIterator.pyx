from xtore.instance.HashStorage cimport HashStorage
from xtore.instance.HashNode cimport HashNode
from xtore.instance.LinkedPageIterator cimport LinkedPageIterator
from xtore.BaseType cimport i32, i64

from libc.stdlib cimport malloc, free

cdef i32 BUFFER_SIZE = 8


cdef class HashIterator:
	def __init__(self, HashStorage storage):
		self.storage = storage
		self.iterator = LinkedPageIterator(self.storage.pageStorage)
		self.buffer = <char *> malloc(BUFFER_SIZE)
	
	def __dealloc__(self):
		free(self.buffer)
	
	cdef start(self):
		self.iterator.start()

	cdef bint getNext(self, HashNode node):
		cdef bint hasNext = self.iterator.getNextValue(self.buffer)
		if not hasNext: return False
		cdef i64 position = (<i64 *> self.buffer)[0]
		cdef HashNode stored = self.storage.readNodeKey(position, node)
		self.storage.readNodeValue(stored)
		node.position = position
		return True
		