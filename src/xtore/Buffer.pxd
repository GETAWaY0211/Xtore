from xtore.BaseType cimport u8, u64
from libc.string cimport memcpy
from libc.stdlib cimport free

DEF __BUFFER_MODULUS__ = 16383
DEF __BUFFER_SHIFT__ = 14

cdef struct Buffer :
	u64 position
	u64 capacity
	char *buffer

ctypedef void (* CapacityChecker) (Buffer *self, u64 length)

cdef inline void initBuffer(Buffer *self, char *buffer, u64 capacity) :
	self.buffer = buffer
	self.capacity = capacity
	self.position = 0

cdef inline void setBuffer(Buffer *self, char *buffer, u64 length) :
	memcpy(self.buffer+self.position, buffer, length)
	self.position += length

cdef inline void setBoolean(Buffer *self, bint data) :
	cdef u8 converted = 1 if data else 0
	setBuffer(self, <char *> &converted, 1)

cdef inline char *getBuffer(Buffer *self, u64 length) :
	cdef char *buffer = self.buffer + self.position
	self.position += length
	return buffer

cdef inline bint getBoolean(Buffer *self) :
	cdef u8 data = (<u8*> getBuffer(self, 1))[0]
	return data > 0

cdef inline releaseBuffer(Buffer *self):
	if self.capacity > 0 and self.buffer != NULL:
		free(self.buffer)
		self.capacity = 0
		self.buffer = NULL