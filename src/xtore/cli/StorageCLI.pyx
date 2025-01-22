from xtore.common.ServerHandler cimport ServerHandler
from xtore.test.People cimport People
from xtore.common.Buffer cimport Buffer, initBuffer, releaseBuffer
from xtore.BaseType cimport i32, u64
from xtore.common.StreamIOHandler cimport StreamIOHandler
from xtore.instance.HashIterator cimport HashIterator
from xtore.instance.BasicStorage cimport BasicStorage
from xtore.test.PeopleHashStorage cimport PeopleHashStorage

from libc.stdlib cimport malloc
from libc.string cimport memcpy
from argparse import RawTextHelpFormatter
import os, sys, argparse, json, traceback, random, time

cdef str __help__ = ""
cdef bint IS_VENV = sys.prefix != sys.base_prefix
cdef i32 BUFFER_SIZE = 1 << 16

def run():
	cdef StorageCLI service = StorageCLI()
	service.run(sys.argv[1:])

cdef class StorageCLI:
	cdef dict config
	cdef object parser
	cdef object option
	cdef ServerHandler handler
	cdef Buffer stream

	def __init__(self):
		initBuffer(&self.stream, <char *> malloc(BUFFER_SIZE), BUFFER_SIZE)

	def __dealloc__(self):
		releaseBuffer(&self.stream)

	def getParser(self, list argv):
		self.parser = argparse.ArgumentParser(description=__help__, formatter_class=RawTextHelpFormatter)
		self.option = self.parser.parse_args(argv)

	def run(self, list argv):
		print("Start server...")
		self.getParser(argv)
		self.checkPath()
		self.getConfig()
		self.handler = ServerHandler(self.config["node"][0])
		self.handler.run(self.handle)

	async def handle(self, reader: object, writer: object) -> None:
		print("Client connection received")
		message: bytes = await reader.read(1024)
		print("Received message:", message)
		cdef i32 length = len(message)
		memcpy(self.stream.buffer, <char *> message, length)
		cdef People people = People()
		people.readKey(0, &self.stream)
		print("People key read:", people)
		self.stream.position += 4
		people.readValue(0, &self.stream)
		print("People value read:", people)
		print(people)
		# self.store_people([people])
		writer.write(message)
		
		cdef str resourcePath = self.getResourcePath()
		cdef str path = f'{resourcePath}/PeopleTest.Hash.bin'
		cdef StreamIOHandler io = StreamIOHandler(path)
		cdef PeopleHashStorage storage = PeopleHashStorage(io)
		cdef bint isNew = not os.path.isfile(path)
		io.open()
		try:
			storage.enableIterable()
			if isNew: storage.create()
			else: storage.readHeader(0)
			peopleList = self.setPeople(storage, people)
			print("People set in storage:", peopleList)
			storedList = self.readPeople(storage, peopleList)
			print("Stored People List:", storedList)
			self.comparePeople(peopleList, storedList)
			if isNew: self.iteratePeople(storage, peopleList)
			storage.writeHeader()
		except:
			print(traceback.format_exc())
		io.close()
		
		print('success')
		await writer.drain()
		writer.close()
		await writer.wait_closed()

	cdef list setPeople(self, BasicStorage storage, People people):
		cdef list peopleList = []
		cdef int i
		cdef int n = 1
		for i in range(n):
			peopleList.append(people)
		for people in peopleList:
			storage.set(people)
		return peopleList

	cdef list readPeople(self, BasicStorage storage, list peopleList):
		cdef list storedList = []
		cdef People stored
		cdef double start = time.time()
		for people in peopleList:
			stored = storage.get(people, None)
			storedList.append(stored)
		return storedList

	cdef comparePeople(self, list referenceList, list comparingList):
		cdef People reference, comparing
		for reference, comparing in zip(referenceList, comparingList):
			try:
				assert reference.ID == comparing.ID
				assert reference.name == comparing.name
				assert reference.surname == comparing.surname
			except Exception as error:
				print(reference, comparing)
				raise error

	cdef iteratePeople(self, PeopleHashStorage storage, list referenceList):
		cdef HashIterator iterator
		cdef People entry = People()
		cdef People comparing
		cdef int i
		cdef int n = len(referenceList)
		cdef double start = time.time()
		cdef double elapsed
		if storage.isIterable:
			iterator = HashIterator(storage)
			iterator.start()
			while iterator.getNext(entry):
				continue
			elapsed = time.time() - start
			print(f'>>> People Data of {n} are iterated in {elapsed:.3}s ({(n/elapsed)} r/s)')

			i = 0
			iterator.start()
			while iterator.getNext(entry):
				comparing = referenceList[i]
				try:
					assert entry.ID == comparing.ID
					assert entry.name == comparing.name
					assert entry.surname == comparing.surname
				except Exception as error:
					print(entry, comparing)
					raise error
				i += 1
			elapsed = time.time() - start
			print(f'>>> People Data of {n} are checked in {elapsed:.3}s')

	cdef checkPath(self):
		cdef str resourcePath = self.getResourcePath()
		if not os.path.isdir(resourcePath):
			os.makedirs(resourcePath)

	cdef str getResourcePath(self):
		if IS_VENV:
			return f'{sys.prefix}/var/xtore'
		else:
			return '/var/xtore'

	cdef getConfig(self):
		cdef str configPath = os.path.join(sys.prefix, "etc", "xtore", "XtoreNetwork.json")
		with open(configPath, "rt") as fd:
			self.config = json.loads(fd.read())
