from xtore.BaseType cimport i32, u64


cdef class PrimeRingP:
	def __init__(self, list primeNumbers):
		self.numLayers = 1
		self.primeNumbers = primeNumbers
		self.layers = [{}]
		self.nodes = []
		self.maxNodeLayer = primeNumbers[0]

	cdef u64 getNode(self, u64 key):
		cdef i32 layer, index
		for layer in range(self.numLayers):
			index = self.getIndex(key, layer)
			if index in self.layers[layer]:
				return self.layers[layer][index]
		return -1

	cdef u64 getIndex(self, u64 key, i32 layer):
		return key % self.primeNumbers[layer]

	cdef insertNode(self, dict info):
		layer = info['layer']
		nodeID = info['id']
		if len(self.layers[layer]) >= self.primeNumbers[layer]:
			self.insertLayer()
			layer += 1

		self.nodes.append(info)
		self.layers[layer][nodeID] = info

	cdef insertLayer(self):
		self.layers.append({})
		self.numLayers += 1


"""
cdef class PrimeRingP:
	def __init__(self, list primeNumbers):
		self.numLayers = 1
		self.primeNumbers = primeNumbers
		self.layers = [{}]
		self.nodes = []

	cdef u64 getNode(self, u64 key):
		cdef i32 layer = 0
		cdef i32 pathIndex
		cdef dict node

		while layer < self.numLayers:
			pathIndex = key % self.primeNumbers[layer]

			if pathIndex in self.layers[layer]:
				node = self.layers[layer][pathIndex]

				if node["splitNodes"]:
					layer += 1
					continue

				return node["id"]

			return -1

		return -1

	cdef u64 getIndex(self, u64 key, i32 layer):
		return key % self.primeNumbers[layer]

	cdef insertNode(self, i32 nodeID, i32 layer):
		while layer >= self.numLayers:
			self.insertLayer()

		pathIndex = nodeID % self.primeNumbers[layer]

		if pathIndex in self.layers[layer]:
			parentNode = self.layers[layer][pathIndex]

			if layer + 1 >= self.numLayers:
				self.insertLayer()

			parentNode["splitNodes"][nodeID] = self.createNode(nodeID)

		self.layers[layer][pathIndex] = self.createNode(nodeID)
		self.nodes.append(nodeID)

	cdef insertLayer(self):
		if self.numLayers >= len(self.primeNumbers):
			return

		self.layers.append({})
		self.numLayers += 1
"""

cdef class TreeNode:
	def __init__(self, i32 nodeID, i32 layer, i32 prime):
		self.nodeID = nodeID
		self.layer = layer
		self.prime = prime
		self.child = []
	
	cdef addChild(self, TreeNode child):
		self.child.append(child)

cdef list genNode(int parentPrime, int nextLayer):
	cdef list child = []
	for i in range(nextLayer):
		child.append(f"Node i")
	return child

cdef TreeNode initPrimeRing(list primeNumbers):
	cdef int layers = len(primeNumbers)
	cdef TreeNode root = TreeNode("Root", 1, 1)
	cdef list currentLayer = [root]

	for layer in range(0, layers):
		nextLayerPrime = primeNumbers[layer]
		nextLayer = []

		for parentNode in currentLayer:
			child = genNode(parentNode.prime, nextLayerPrime)
			for i, nodeID in enumerate(child):
				childNode = TreeNode(nodeID, layer + 1, primeNumbers[layer])
				parentNode.addChild(childNode)
				nextLayer.append(childNode)

		currentLayer = nextLayer

	return root