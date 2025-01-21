from xtore.common.ClientHandler cimport ClientHandler
from xtore.test.People cimport People
from xtore.common.Buffer cimport Buffer, initBuffer, releaseBuffer, getBytes
from xtore.BaseType cimport i32

from libc.stdlib cimport malloc
from cpython cimport PyBytes_FromStringAndSize
from faker import Faker
from argparse import RawTextHelpFormatter
import os, sys, argparse, json, traceback, random, time

cdef str __help__ = ''
cdef bint IS_VENV = sys.prefix != sys.base_prefix
cdef i32 BUFFER_SIZE = 1 << 16

def run():
	cdef ClientTestCLI service = ClientTestCLI()
	service.run(sys.argv[1:])

cdef class ClientTestCLI :
	cdef dict config
	cdef object parser
	cdef object option
	cdef ClientHandler handler
	cdef Buffer stream

    def __init__(self):
		initBuffer(&self.stream, <char *> malloc(BUFFER_SIZE), BUFFER_SIZE)

	def __dealloc__(self):
		releaseBuffer(&self.stream)

	cdef run(self, list argv) :
		self.getParser(argv)
		self.getConfig()
		self.checkPath()
		cdef bytes message = self.CreateMessage()
		self.handler = ClientHandler(self.config["node"][0])
		self.handler.send(message)
	
	cdef bytes CreateMessage(self, BasicStorage storage) :
		cdef object fake = Faker()
        cdef list peopleList = []
		cdef People people = People()
		cdef int i
		cdef int n = 1
		for i in range(n):
			people = People()
			people.position = -1
			people.ID = random.randint(1_000_000_000_000, 9_999_999_999_999)
			people.name = fake.first_name()
			people.surname = fake.last_name()
            people.write(&self.stream)
			peopleList.append(people)
            print(people)
		for people in peopleList:
			storage.set(people)
		return PyBytes_FromStringAndSize(self.stream.buffer, self.stream.position)

    cdef list writePeople(self, BasicStorage storage):
		cdef list peopleList = []
		cdef People people
		cdef int i
		cdef int n = 1
		cdef object fake = Faker()
		cdef double start = time.time()
		for i in range(n):
			people = People()
			people.position = -1
			people.ID = random.randint(1_000_000_000_000, 9_999_999_999_999)
			people.name = fake.first_name()
			people.surname = fake.last_name()
			peopleList.append(people)
            print(people)
		for people in peopleList:
			storage.set(people)
		return peopleList

	cdef getParser(self, list argv) :
		self.parser = argparse.ArgumentParser(description=__help__, formatter_class=RawTextHelpFormatter)
		self.option = self.parser.parse_args(argv)

	cdef getConfig(self) :
		cdef str configPath = os.path.join(sys.prefix, "etc", "xtore", "XtoreNetwork.json")
		cdef object fd
		with open(configPath, "rt") as fd :
			self.config = json.loads(fd.read())
			fd.close()

	cdef checkPath(self) :
		cdef str resourcePath = self.getResourcePath()
		if not os.path.isdir(resourcePath): os.makedirs(resourcePath)

	cdef str getResourcePath(self) :
		if IS_VENV: return os.path.join(sys.prefix, "var", "xtore")
		else: return os.path.join('/', "var", "xtore")